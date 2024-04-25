FROM maven:3.9.6-eclipse-temurin-17-alpine as dependency
WORKDIR /dependency
COPY pom.xml .
RUN mvn dependency:go-offline

FROM maven:3.9.6-eclipse-temurin-17-alpine as compile
WORKDIR /compile
COPY --from=dependency /root/.m2 /root/.m2 
COPY --from=dependency /dependency .
COPY ./src ./src
RUN mvn clean compile

FROM maven:3.9.6-eclipse-temurin-17-alpine as test
WORKDIR /test
COPY --from=compile /root/.m2 /root/.m2
COPY --from=compile /compile .
RUN mvn test

FROM maven:3.9.6-eclipse-temurin-17-alpine as build
WORKDIR /build
COPY --from=compile /root/.m2 /root/.m2
COPY --from=compile /compile .
RUN mvn package

FROM openjdk:17-slim as application
WORKDIR /app
COPY --from=build /build/target/*.jar ./app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]