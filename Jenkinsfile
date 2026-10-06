pipeline {
    agent any
    tools {
        jdk 'JDK21'
        maven 'M3'
    }
    
    stages {
        //Github로 부터 소스코드 다운로드 받는 작업
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/donanaa/spring-petclinic.git',
                branch: 'main'
            }
        }
        // Maven을 이용한 Build
        stage('Maven Build') {
            steps {
                echo 'Maven Build'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }
    }
}
