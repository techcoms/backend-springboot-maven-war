FROM tomcat:8.5.47-jdk8-openjdk
WORKDIR /app
EXPOSE 8080
COPY target/mavewebappdemo-0.1.0-SNAPSHOT.war /usr/local/tomcat/webapps/mavewebappdemo-0.1.0-SNAPSHOT.war

