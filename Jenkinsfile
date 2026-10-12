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
        // SSH를 이용한 실행파일 전송
        stage('SSH Publish') {
            steps{
                echo 'SSH Pubilsh'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'target',
                 transfers: [sshTransfer(cleanRemote: false,
                 excludes: '',
                 execCommand: '''fuser -k 8080/tcp
                export BUILD_ID=Spring-PetClinic
                
                nohup java -jar home/ubuntu/spring-petclinic-4.0.0-SNAPSHOT.jar >> nohup.out 2>&1 &''',
                 execTimeout: 120000,
                 flatten: false,
                 makeEmptyDirs: false,
                 noDefaultExcludes: false,
                 patternSeparator: '[, ]+',
                 remoteDirectory: '',
                 remoteDirectorySDF: false,
                 removePrefix: '',
                 sourceFiles: '.jar')],
                 usePromotionTimestamp: false,
                 useWorkspaceInPromotion: false,
                 verbose: false)])
    }
}
    }
}
