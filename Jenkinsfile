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
                    set -e
                    sudo systemctl stop tomcat10
                    sudo cp target/mavewebappdemo-0.1.0-SNAPSHOT.war /var/lib/tomcat10/webapps/my-app.war
                    sudo chown tomcat:tomcat /var/lib/tomcat10/webapps/my-app.war
                    sudo systemctl start tomcat10
                '''
             }
          }
      }
}
