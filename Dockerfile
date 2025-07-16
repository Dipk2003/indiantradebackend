# Multi-stage build for optimal image size
FROM maven:3.9.6-eclipse-temurin-21-jammy AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# Runtime stage
FROM eclipse-temurin:21-jre-jammy

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create app user
RUN addgroup --system appuser && adduser --system --group appuser

# Set working directory
WORKDIR /app

# Copy built JAR from builder stage
COPY --from=builder /app/target/itech-backend-0.0.1-SNAPSHOT.jar app.jar

# Copy startup script
COPY start.sh /app/start.sh

# Create necessary directories and set permissions
RUN mkdir -p uploads logs && \
    chmod +x /app/start.sh && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM options for production
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseStringDeduplication"
ENV SPRING_PROFILES_ACTIVE=production

# Run the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
