# =============================================================================
# iTech Backend - Multi-Stage Docker Build for AWS Production
# =============================================================================
# Stage 1: Build the application
# =============================================================================
FROM openjdk:21-jdk-slim as builder

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application for production
RUN mvn clean package -DskipTests -Dspring.profiles.active=production

# =============================================================================
# Stage 2: Runtime image
# =============================================================================
FROM openjdk:21-jdk-slim

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

# Copy startup script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown appuser:appuser /usr/local/bin/docker-entrypoint.sh

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options for production
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication"

# Default profile for AWS
ENV SPRING_PROFILES_ACTIVE=production
ENV SERVER_PORT=8080
ENV DATABASE_URL=
ENV JDBC_DATABASE_USERNAME=
ENV JDBC_DATABASE_PASSWORD=
ENV REDIS_HOST=
ENV REDIS_PORT=6379
ENV JWT_SECRET=
ENV RAZORPAY_KEY_ID=
ENV RAZORPAY_KEY_SECRET=
ENV AWS_S3_BUCKET=
ENV AWS_S3_REGION=
ENV EMAIL_HOST=
ENV EMAIL_USERNAME=
ENV EMAIL_PASSWORD=

# Entry point
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
