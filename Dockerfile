FROM maven

WORKDIR /app

COPY . .

RUN mvn clean package

CMD ["java","-jar","target/java-example-demo-1.0.0.jar"]

#COPY target/java-example-demo-1.0.0.jar app.jar


#CMD ["java", "-jar", "app.jar"]
