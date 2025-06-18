pipeline {
    agent any

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

        stage('Get Dependencies and Build') {
            steps {
                sh '''
                    sudo -u flutteruser flutter pub get
                    sudo -u flutteruser flutter build web --release --web-renderer html
                '''
            }
        }

        stage('Archive Build') {
            steps {
                sh "tar -czf flutter_build.tar.gz -C ${WEB_BUILD_DIR} ."
            }
        }

        stage('Prepare Deployment Script') {
            steps {
                writeFile file: 'deploy.sh', text: """#!/bin/bash
systemctl stop nginx || true
rm -rf ${REMOTE_DIR}/*
mkdir -p ${REMOTE_DIR}
tar -xzf flutter_build.tar.gz -C ${REMOTE_DIR}
systemctl start nginx || true
"""
                sh 'chmod +x deploy.sh'
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
