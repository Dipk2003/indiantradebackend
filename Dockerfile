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
RUN mvn clean package -DskipTests -Dspring.profiles.active=render

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
EXPOSE 10000

# Set environment variables optimized for Render free tier
ENV SPRING_PROFILES_ACTIVE=render
ENV SERVER_PORT=10000
ENV JAVA_OPTS="-Xmx350m -Xms128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseContainerSupport -XX:MaxRAMPercentage=70 -Djava.awt.headless=true -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Dspring.jmx.enabled=false -Dspring.jpa.defer-datasource-initialization=true"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:10000/actuator/health || exit 1

# Optimized entrypoint for Render deployment
CMD ["sh", "-c", "echo 'Starting Indian Trade Mart Backend on Render...' && echo 'Memory limit: 512MB, JVM max heap: 350MB' && java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=render -Dserver.port=10000 -jar app.jar"]
