 # Stage 1: Maven as base image
 FROM maven:3.6.3-jdk-11 as builder
 RUN git clone https://github.com/bkrrajmali/helloworld.git /app
 WORKDIR /app
 COPY . .
 RUN mvn clean install -Dmaven.test.skip=true

 # Stage 2: Tomcat as the server
 FROM tomcat:latest
 RUN rm -rf webapps
 RUN mv webapps.dist webapps
 COPY --from=builder /app/webapp/target/*.war /usr/local/tomcat/webapps
 WORKDIR /app
 EXPOSE 8080
 CMD ["catalina.sh", "run"]