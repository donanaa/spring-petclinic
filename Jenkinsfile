#pipeline {
#    agent any
#    tools {
#        jdk 'JDK21'
#        maven 'M3'
#    }
#    environment {
#            DOCKERHUB_CRED = credentials('dockerCredentials')
#    }
#    
#    stages {
#        //Github로 부터 소스코드 다운로드 받는 작업
#        stage('Git Clone') {
#            steps {
#                echo 'Git Clone'
#                git url: 'https://github.com/donanaa/spring-petclinic.git',
#                branch: 'main'
#            }
#        }
#        // Maven을 이용한 Build
#        stage('Maven Build') {
#            steps {
#                echo 'Maven Build'
#                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
#            }
#        }
#        // Docker Image 생성
#        stage ('Docker Image Create') {
#            steps {
#            echo 'Docker Image Create'
#            sh '''
#                docker build -t spring-petclinic:${BUILD_NUMBER} .
#                docker tag spring-petclinic:${BUILD_NUMBER} donanaa/spring-petclinic:latest
#            '''
#            }
#        }
#        // Dockerhub Image Push
#        stage('Docker Image Push') {
#            steps { 
#                echo 'Docker Image Push'
#                // Docker Login
#                sh 'echo ${DOCKERHUB_CRED_PSW} | docker login -u $DOCKERHUB_CRED_USR --password-stdin'
#                // Docker Hub Push
#                sh 'docker image push donanaa/spring-petclinic:latest'
#            }
#            post {
#                always {
#                    sh '''
#                    docker rmi -f spring-petclinic:${BUILD_NUMBER}
#                    docker rmi -f donanaa/spring-petclinic:latest
#                    '''
#
#                }
#            }
#        }
#        // Docker Image 삭제
#        // SSH를 이용한 Docker 컨테이너 실행파일 전송
#        stage('SSH Publish') {
#            steps{
#                echo 'SSH Pubilsh'
#                sshPublisher(publishers: [sshPublisherDesc(configName: 'target',
#                 transfers: [sshTransfer(cleanRemote: false,
#                 excludes: '',
#                 execCommand: '''
#                 docker rm -f $(docker ps -aq)
#                 docker rmi -f $(docker images -q) 
#                 docker run -itd -p 80:8080 --name spring-petclinic donanaa/spring-petclinic:latest
#                 '''
#                                          
#
#                 execTimeout: 120000,
#                 flatten: false,
#                 makeEmptyDirs: false,
#                 noDefaultExcludes: false,
#                 patternSeparator: '[, ]+',
#                 remoteDirectory: '',
#                 remoteDirectorySDF: false,
#                 removePrefix: '',
#                 sourceFiles: '.jar')],
#                 usePromotionTimestamp: false,
#                 useWorkspaceInPromotion: false,
#                 verbose: false)])
#    }
#}
#    }
#}

pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    stages {
        stage('Git Clone') {
            steps {
                git url: 'https://github.com/donanaa/spring-petclinic.git',
                    branch: 'main'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }

        stage('Docker Image Create') {
            steps {
                sh 'docker build -t donanaa/spring-petclinic:latest .'
            }
        }

        stage('Docker Hub Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerCredentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh '''
                        set +x
                        printf '%s' "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push donanaa/spring-petclinic:latest
                        docker logout
                    '''
                }
            }
        }
    }
}
