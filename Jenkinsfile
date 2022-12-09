pipeline{ 
      options {
    buildDiscarder(logRotator(numToKeepStr: '2', artifactNumToKeepStr: '6'))
  }
    agent any
    environment {
        ECR_REGISTRY = "894228636591.dkr.ecr.ap-south-1.amazonaws.com/backend-springboot-maven-war"
        GITHUB_URL = "${params.url}"
        BRANCH = "${params.branch}"
    }
    tools{
        maven "maven-3.8.6"
    }
    stages{
        stage("git checkout"){
            steps{
                  git branch: "${BRANCH}", credentialsId: 'github-creds', url: "${GITHUB_URL}"
            }
        }
        stage("build artifacts with maven"){
            steps{
                sh "mvn clean package"
            }
        }
        stage("build docker image"){
            steps {
                sh "docker build -t ${ECR_REGISTRY}:${BUILD_NUMBER} ."
            }
        }
        stage("login to dockerhub and push image"){
            steps { 
                sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 894228636591.dkr.ecr.ap-south-1.amazonaws.com"
                sh "docker push ${ECR_REGISTRY}:${BUILD_NUMBER}"
                      
                  }
             }  
          }
    post{
        changed{
            mail to: "techcomsdevops@gmail.com",
            subject: "jenkins build:${currentBuild.currentResult}: ${env.JOB_NAME}",
            body: "${currentBuild.currentResult}: Job ${env.JOB_NAME}\nMore Info can be found here: ${env.BUILD_URL}"
        }
    }
}
