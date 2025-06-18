pipeline {
    agent any

    environment {
        WEB_BUILD_DIR = 'build/web'
        REMOTE_DIR = '/root/Courses-frontend'
        FLUTTER_USER = 'flutteruser'
        FLUTTER_PASS = 'Gfhjkm007q..'
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
                    sh '''
                    expect -c "
                    spawn sudo -u ${FLUTTER_USER} flutter --version
                    expect {
                        \\"[sudo] password for\\" { send \\"${FLUTTER_PASS}\\r\"; exp_continue }
                        eof
                    }
                    "
                    '''
                    sh '''
                    expect -c "
                    spawn sudo -u ${FLUTTER_USER} flutter config --enable-web
                    expect {
                        \\"[sudo] password for\\" { send \\"${FLUTTER_PASS}\\r\"; exp_continue }
                        eof
                    }
                    "
                    '''
                    sh '''
                    expect -c "
                    spawn sudo -u ${FLUTTER_USER} flutter doctor -v
                    expect {
                        \\"[sudo] password for\\" { send \\"${FLUTTER_PASS}\\r\"; exp_continue }
                        eof
                    }
                    "
                    '''
                }
            }
        }

        stage('Get Dependencies') {
            steps {
                script {
                    sh '''
                    expect -c "
                    spawn sudo -u ${FLUTTER_USER} flutter pub get
                    expect {
                        \\"[sudo] password for\\" { send \\"${FLUTTER_PASS}\\r\"; exp_continue }
                        eof
                    }
                    "
                    '''
                }
            }
        }

        stage('Build Web') {
            steps {
                script {
                    sh '''
                    expect -c "
                    spawn sudo -u ${FLUTTER_USER} flutter build web --release --web-renderer html
                    expect {
                        \\"[sudo] password for\\" { send \\"${FLUTTER_PASS}\\r\"; exp_continue }
                        eof
                    }
                    "
                    '''
                }
            }
        }

        stage('Prepare Deployment') {
            steps {
                script {
                    sh '''
                    expect -c "
                    spawn sudo -u ${FLUTTER_USER} bash -c 'tar -czf flutter_build.tar.gz -C ${WEB_BUILD_DIR} .'
                    expect {
                        \\"[sudo] password for\\" { send \\"${FLUTTER_PASS}\\r\"; exp_continue }
                        eof
                    }
                    "
                    '''

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
