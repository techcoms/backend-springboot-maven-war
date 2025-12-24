pipeline {
    agent any

    tools {
        maven 'maven-3.9.11'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'feature1',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/techcoms/backend-springboot-maven-war.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh '''
                TOMCAT=/var/lib/tomcat10/webapps

                sudo systemctl stop tomcat10
                rm -rf $TOMCAT/myapp*
                cp target/myapp.war $TOMCAT/
                sudo systemctl start tomcat10
                '''
             }
          }
      }
}

