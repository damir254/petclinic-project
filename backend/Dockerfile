FROM eclipse-temurin:25-jdk-noble AS build

WORKDIR /app

COPY pom.xml mvnw ./
COPY .mvn/ .mvn/

RUN bash ./mvnw dependency:go-offline -B

COPY . ./

RUN bash ./mvnw clean package



FROM eclipse-temurin:25-jre-noble AS runtime

WORKDIR /app

COPY --from=build /app/target/*.jar ./app.jar

RUN groupadd -r app && useradd -r -g app app 

RUN chown -R app:app /app

EXPOSE 9966

USER app

ENTRYPOINT ["java", "-jar", "app.jar" ]  
