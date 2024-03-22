# Builder
FROM ghcr.io/graalvm/graalvm-ce:22.2.0 AS builder
COPY  . /root/app/
WORKDIR /root/app
RUN ./mvnw clean install -DskipTests

# Application
FROM ghcr.io/graalvm/graalvm-ce:22.2.0 AS application
COPY --from=builder /root/app/target/*.jar /home/app/
WORKDIR /home/app
RUN chmod 0777 /home/app
EXPOSE 8081
ENTRYPOINT java -jar $JAVA_OPTIONS *.jar 
