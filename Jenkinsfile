pipeline {
    agent any

    environment {
        FLUTTER_CHANNEL = 'stable'
        FLUTTER_VERSION = '3.22.0'
        WEB_BUILD_DIR = 'build/web'
        REMOTE_DIR = '/root/Courses-frontend'
        FLUTTER_HOME = "${env.WORKSPACE}/flutter"  // Изменено здесь
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Flutter') {
            steps {
                script {
                    if (!fileExists("${env.FLUTTER_HOME}")) {
                        sh """
                        wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${env.FLUTTER_VERSION}-${env.FLUTTER_CHANNEL}.tar.xz
                        tar xf flutter_linux_${env.FLUTTER_VERSION}-${env.FLUTTER_CHANNEL}.tar.xz
                        """
                    }
                    // Добавляем Flutter в PATH
                    env.PATH = "${env.FLUTTER_HOME}/bin:${env.PATH}"
                    sh 'flutter --version'
                    sh 'flutter doctor'
                }
            }
        }

        stage('Get Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Build Web') {
            steps {
                sh """
                flutter config --enable-web
                flutter build web --release --web-renderer html
                """
            }
        }

        stage('Prepare Deployment') {
            steps {
                script {
                    sh "tar -czf flutter_build.tar.gz -C ${env.WEB_BUILD_DIR} ."

                    writeFile file: 'deploy.sh', text: """#!/bin/bash
# Останавливаем nginx (если используется)
systemctl stop nginx || true

# Очищаем старую версию
rm -rf ${env.REMOTE_DIR}/*
mkdir -p ${env.REMOTE_DIR}

# Распаковываем новую версию
tar -xzf flutter_build.tar.gz -C ${env.REMOTE_DIR}

# Запускаем nginx обратно
systemctl start nginx || true
"""
                    sh 'chmod +x deploy.sh'
                }
            }
        }

        stage('Transfer and Deploy') {
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'production-server',
                            transfers: [
                                sshTransfer(
                                    sourceFiles: 'flutter_build.tar.gz,deploy.sh',
                                    remoteDirectory: 'flutter_deploy',
                                    execCommand: '''
                                        cd /root/flutter_deploy
                                        chmod +x deploy.sh
                                        ./deploy.sh
                                        rm -rf /root/flutter_deploy
                                    '''
                                )
                            ],
                            usePromotionTimestamp: false,
                            useWorkspaceInPromotion: false,
                            verbose: true
                        )
                    ]
                )
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    sh 'rm -f flutter_build.tar.gz deploy.sh flutter_linux_*.tar.xz'
                    sh "rm -rf ${env.FLUTTER_HOME}"  // Очищаем Flutter после сборки
                }
            }
        }
    }
}