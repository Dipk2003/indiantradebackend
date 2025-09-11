# =============================================================================
# Indian Trade Mart Backend - Render Deployment Dockerfile
# =============================================================================
# Stage 1: Build the application
# =============================================================================
FROM maven:3.9.4-eclipse-temurin-21 as builder

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application for production
RUN mvn clean package -DskipTests -Dspring.profiles.active=prod

# =============================================================================
# Stage 2: Runtime image
# =============================================================================
FROM eclipse-temurin:21-jre-jammy

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN useradd -m -u 1001 -s /bin/sh appuser

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/logs /app/uploads && \
    chown -R appuser:appuser /app

# Copy the built JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Simple entrypoint - no external script needed
CMD ["sh", "-c", "echo 'Starting Indian Trade Mart Backend...' && java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
