FROM maven:3.9.6-eclipse-temurin-17-alpine as dependency
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

FROM dependency as compile
COPY ./src ./src
RUN mvn clean compile

FROM compile as test
RUN mvn test

FROM compile as build
RUN mvn package

FROM openjdk:17-slim as application
WORKDIR /app
COPY --from=build /app/target/*.jar ./app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]