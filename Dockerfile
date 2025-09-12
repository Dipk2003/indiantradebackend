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

# Build the application for minimal memory usage
RUN mvn clean package -DskipTests -Dspring.profiles.active=minimal

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

# Expose port - Render assigns PORT dynamically
EXPOSE 8080

# Set environment variables optimized for Render free tier
ENV SPRING_PROFILES_ACTIVE=minimal
ENV JAVA_OPTS="-Xmx200m -Xms32m -XX:+UseSerialGC -XX:MaxDirectMemorySize=32m -XX:MaxMetaspaceSize=128m -XX:CompressedClassSpaceSize=32m -XX:ReservedCodeCacheSize=32m -XX:+UseCompressedOops -XX:+UseCompressedClassPointers -Djava.awt.headless=true -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Dspring.jmx.enabled=false -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom"

# Health check using PORT environment variable
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/actuator/health || exit 1

# Optimized entrypoint for Render deployment - use PORT env var
CMD ["sh", "-c", "echo 'Starting Indian Trade Mart Backend on Render...' && echo 'Memory limit: 512MB, JVM max heap: 200MB' && echo 'Port: ${PORT:-8080}' && java $JAVA_OPTS -Dspring.profiles.active=minimal -jar app.jar"]
