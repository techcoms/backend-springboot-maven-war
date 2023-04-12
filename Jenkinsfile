pipeline{ 
      options {
    buildDiscarder(logRotator(numToKeepStr: '2', artifactNumToKeepStr: '6'))
  }
    agent any
    environment {
        DOCKERHUB_REPO = "techcoms/backend-springboot-maven-war"
        GITHUB_URL = "${params.url}"
        BRANCH = "${params.branch}"
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "43.205.142.186:8081"
        NEXUS_REPOSITORY = "maven-snapshots"
        NEXUS_CREDENTIAL_ID = "nexusrepo"
    }
    tools{
        maven"maven-3.9.1"
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
         stage("Publish to Nexus Repository ") {
            steps {
                script{
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "* File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "* File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
        stage("build docker image"){
            steps {
                sh "docker build -t ${DOCKERHUB_REPO}:${BUILD_NUMBER} ."
            }
        }
         stage('run a docker container'){
                steps{
                   sh "docker run -d -p 8083:8080 ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
                }
          }
        stage("login to dockerhub and push image"){
            steps { 
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) { 
                    sh "docker login -u $USERNAME -p $PASSWORD "
                    sh "docker push ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
  
                      }
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
