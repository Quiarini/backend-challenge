FROM openjdk:21
ADD target/jwt-validator.jar jwt-validator.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","jwt-validator.jar"]