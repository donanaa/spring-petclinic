
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
        stage('Kubernetes Deploy') {
            steps {
                sh '''
                    set -e
                    kubectl apply -f was-deployment.yml -n was
                    kubectl apply -f was-service.yml -n was
                    kubectl apply -f was-ingress.yml -n was
                    kubectl rollout restart deployment/spring-petclinic -n was
                    kubectl rollout status deployment/spring-petclinic -n was --timeout=180s
                '''
            }
        }
    }
}
