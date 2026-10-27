FROM eclipse-temurin:21-jre-alpine
ARG JAR_FILE_PATH=target/*.jar
COPY ${JAR_FILE_PATH} spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
USER root
RUN curl -fsSLo /usr/local/bin/kubectl \
    https://dl.k8s.io/release/v1.28.15/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl
USER jenkins
