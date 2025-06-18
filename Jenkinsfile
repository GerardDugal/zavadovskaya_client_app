pipeline {
    agent any

    environment {
        WEB_BUILD_DIR = 'build/web'
        REMOTE_DIR = '/root/Courses-frontend'
        FLUTTER_USER = 'flutteruser'
        FLUTTER_PASS = 'Gfhjkm007q..'
    }

    stages {
        stage('Pre-clean') {
            steps {
                sh 'rm -rf .git'
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Fix Permissions') {
            steps {
                // даём flutteruser права на рабочую папку Jenkins
                sh "sudo chown -R ${FLUTTER_USER}:jenkins ${env.WORKSPACE}"
                sh "sudo chmod -R u+rwX ${env.WORKSPACE}"
            }
        }

        stage('Get Dependencies and Build') {
            steps {
                script {
                    sh "sudo -u ${FLUTTER_USER} /home/flutteruser/flutter/bin/flutter pub get"
                    sh "sudo -u ${FLUTTER_USER} /home/flutteruser/flutter/bin/flutter build web --release"
                }
            }
        }

        stage('Prepare Deployment') {
            steps {
                script {
                    sh "sudo -u ${FLUTTER_USER} tar -czf flutter_build.tar.gz -C ${WEB_BUILD_DIR} ."

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
