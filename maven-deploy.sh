#!/bin/bash

echo "Starting maven deployment automation..."

# Update the apt package
echo "Updating apt..."
sudo apt update

# Install Java, Maven, and Unzip
echo "Installing Java, Maven, and Unzip..."
sudo apt install unzip && sudo apt install openjdk-17-jre-headless -y && sudo apt install maven -y

# Install, unzip, and renaming Tomcat Server
echo "Installing Apache Tomcat from the web..."
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.100/bin/apache-tomcat-8.5.100.tar.gz
tar -xvzf apache-tomcat-8.5.100.tar.gz
mv apache-tomcat-8.5.100 tomcat
rm -rf apache-tomcat-8.5.100.tar.gz

# Install, unzip, and renaming Sonarqube by using wget
echo "Installing sonarqube from the web..."
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.5.0.89998.zip
unzip sonarqube-10.5.0.89998.zip
mv sonarqube-10.5.0.89998 sonarqube
rm -rf sonarqube-10.5.0.89998.zip

# Clone the Helloworld Git Repository
echo "Cloning helloworld repository from Github..."
git clone https://github.com/nikkaalviar/helloworld.git

# Define the project (helloworld) directory
PROJECT_DIRECTORY="/home/ubuntu/helloworld/webapp"

# Define the directory where the built artifact (e.g., WAR file) will be created 
ARTIFACT_DIRECTORY="$PROJECT_DIRECTORY/target"

# Define the name of the built artifact 
ARTIFACT_NAME="webapp.war"

# Define Tomcat's bin directory for starting the server
TOMCAT_BIN_DIRECTORY="/home/ubuntu/tomcat/bin"

# Define the directory where Tomcat's webapps are located 
TOMCAT_WEBAPPS_DIRECTORY="/home/ubuntu/tomcat/webapps"

# Define the directory of sonarqube's bin 
SONARQUBE_LINUX_DIRECTORY="/home/ubuntu/sonarqube/bin/linux-x86-64/"

# Start an infinite loop to continuously watch for file changes 
# When a change is detected, run maven
echo "Change detected. Building the project using mvn clean package..."
cd "$PROJECT_DIRECTORY" || exit
mvn clean package

# Check if Maven build is successfull, then copy project's artifact into Tomcat's webapp directory
if [ $? -eq 0 ]; then
  echo "Maven Build is sucessfull. Copying artifact into Tomcat..."
  cd "$TOMCAT_WEBAPPS_DIRECTORY" || exit
  rm -rf webapp*
  cp "$ARTIFACT_DIRECTORY/$ARTIFACT_NAME" "$TOMCAT_WEBAPPS_DIRECTORY"
  echo "Artifact successfully copied..."
else
  echo "Build failed. Please check your code."
fi

# Starting Tomcat server
echo "Starting tomcat server..."
cd "$TOMCAT_BIN_DIRECTORY" || 
sh startup.sh

# Change into Sonarqube directory, then start sonarqube
echo "Starting sonarqube..."
cd "$SONARQUBE_LINUX_DIRECTORY" || exit
sh sonar.sh start

# Required user generated sonarqube token
echo "Please input the Sonarqube token..."
read SONARQUBE_TOKEN

# Clean and verify the project and sonarqube executes code quality analysis
echo "Cleaning and verifying project. Sonarqube scanning for code quality..."
cd "$PROJECT_DIRECTORY" || exit
mvn clean verify sonar:sonar -Dsonar.projectKey=helloworld \
                           -Dsonar.projectName="helloworld" \
                           -Dsonar.host.url=http://3.147.195.164:9000 \
                           -Dsonar.token="$SONARQUBE_TOKEN"

# $? holds the exit status of last command
# If last command exit status is successfull...
if [ $? -eq 0 ]; then 
  echo "Build successfull and Sonarqube analysis completed."
else 
  echo "Build failed or errors occured during Sonarqube analysis..."
fi

