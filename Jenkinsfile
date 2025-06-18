pipeline {
    agent {
        docker {
            image 'growerp/flutter-sdk-image:latest'  // Используем существующий тег
            args '--platform linux/amd64 -u root -v /usr/bin/chromium:/usr/bin/chromium'
        }
    }

    environment {
        WEB_BUILD_DIR = 'build/web'
        REMOTE_DIR = '/root/Courses-frontend'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Flutter') {
            steps {
                sh 'flutter --version'
                sh 'flutter config --enable-web'
                sh 'flutter doctor -v'
            }
        }

        stage('Get Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Build Web') {
            steps {
                sh 'flutter build web --release --web-renderer html'
            }
        }

        stage('Prepare Deployment') {
            steps {
                script {
                    sh "tar -czf flutter_build.tar.gz -C ${env.WEB_BUILD_DIR} ."
                    
                    writeFile file: 'deploy.sh', text: """#!/bin/bash
systemctl stop nginx || true
rm -rf ${env.REMOTE_DIR}/*
mkdir -p ${env.REMOTE_DIR}
tar -xzf flutter_build.tar.gz -C ${env.REMOTE_DIR}
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
                sh 'rm -f flutter_build.tar.gz deploy.sh'
            }
        }
    }
}