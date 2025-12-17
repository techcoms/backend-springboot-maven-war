pipeline { 
    agent any
    
    environment {
        DOCKERHUB_REPO = "techcoms/backend-springboot-maven-war"
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "13.235.62.16:8081"
        NEXUS_REPOSITORY = "maven-snapshots"
        NEXUS_CREDENTIAL_ID = "nexusrepo"
    }

    tools {
        // Ensure this name matches EXACTLY what is in "Manage Jenkins -> Global Tool Configuration"
        maven "maven-3.9.11"
    }

    stages {
        stage("Git Checkout") {
            steps {
                // Modified: Changed 'Feature' to 'feature' or 'main' depending on your GitHub
                git branch: 'main', 
                    credentialsId: 'github-creds',
                    url: 'https://github.com/techcoms/backend-springboot-maven-war.git'
            }
        }

        stage("Build Artifacts") {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage("Publish to Nexus") {
            steps {
                script {
                    // Requires "Pipeline Utility Steps" Plugin
                    def pom = readMavenPom file: "pom.xml"
                    def filesByGlob = findFiles(glob: "target/*.${pom.packaging}")
                    
                    if(filesByGlob.length > 0) {
                        def artifactPath = filesByGlob[0].path
                        echo "Uploading Artifact: ${artifactPath}"
                        
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging],
                                [artifactId: pom.artifactId, classifier: '', file: "pom.xml", type: "pom"]
                            ]
                        )
                    } else {
                        error "No artifact found in target/ directory."
                    }
                }
            }
        }

        stage("Docker Build") {
            steps {
                sh "docker build -t ${DOCKERHUB_REPO}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKERHUB_REPO}:${BUILD_NUMBER} ${DOCKERHUB_REPO}:latest"
            }
        }

        stage("Run Docker Container") {
            steps {
                script {
                    // Cleanup: Stop and remove existing container on port 8083 if it exists
                    sh "docker ps -q --filter 'publish=8083' | xargs -r docker stop"
                    sh "docker ps -aq --filter 'publish=8083' | xargs -r docker rm"
                    
                    // Run the new container
                    sh "docker run -d -p 8083:8080 --name backend-app-${BUILD_NUMBER} ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
                }
            }
        }

        stage("Push to DockerHub") {
            steps { 
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) { 
                    sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    sh "docker push ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
                    sh "docker push ${DOCKERHUB_REPO}:latest"
                }
            }
        }
    }

    post {
        always {
            mail to: "jyothiprakashg05@gmail.com",
                 subject: "Jenkins Build ${currentBuild.fullDisplayName}: ${currentBuild.currentResult}",
                 body: "Build Result: ${currentBuild.currentResult}\nProject: ${env.JOB_NAME}\nBuild URL: ${env.BUILD_URL}"
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
