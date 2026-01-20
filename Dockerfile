FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy JAR built by Jenkins
COPY target/country-chicken-backend-*.jar app.jar

EXPOSE 8080

ENV JAVA_OPTS="-Xms128m -Xmx384m"

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
