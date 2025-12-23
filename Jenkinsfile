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
                sshagent(credentials: ['tomcat-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@172.31.27.49 sudo systemctl stop tomcat10
                    ssh ubuntu@172.31.27.49 sudo rm -rf /var/lib/tomcat10/webapps/mavewebappdemo*
                    scp target/*.war ubuntu@172.31.27.49:/tmp/
                    ssh ubuntu@172.31.27.49 sudo mv /tmp/*.war /var/lib/tomcat10/webapps/
                    ssh ubuntu@172.31.27.49 sudo chown tomcat:tomcat /var/lib/tomcat10/webapps/*.war
                    ssh ubuntu@172.31.27.49 sudo systemctl start tomcat10
                    '''
                }
            }
        }
    }
}
