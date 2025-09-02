# iTech Backend - Build System Guide

## Overview

This document describes the comprehensive build system for the iTech Backend project. The build system supports multiple build tools and deployment scenarios.

## Available Build Tools

### 1. PowerShell Build Script (`build.ps1`) - **Recommended for Windows**
The most comprehensive build tool with advanced features and error handling.

```powershell
# Basic usage
.\build.ps1 -Target <target> [-Profile <profile>] [options]

# Examples
.\build.ps1 -Target help                           # Show help
.\build.ps1 -Target full                          # Complete build with tests
.\build.ps1 -Target package -SkipTests            # Quick package
.\build.ps1 -Target run -Profile development      # Run locally
.\build.ps1 -Target docker-run                    # Run with Docker
```

**Available Targets:**
- `clean` - Clean all build artifacts
- `compile` - Compile source code only
- `test` - Run tests only
- `package` - Create JAR package
- `docker` - Build Docker image
- `full` - Complete build (clean + compile + test + package + docker)
- `run` - Run application locally
- `docker-run` - Run with Docker Compose
- `help` - Show help

**Options:**
- `-Profile` - development, production, or test (default: development)
- `-SkipTests` - Skip running tests
- `-CleanDocker` - Clean Docker artifacts during clean
- `-Verbose` - Enable verbose Maven output

### 2. Batch File (`build.bat`) - **Simple Windows builds**
Simplified build script for basic operations.

```batch
REM Basic usage
build.bat [target] [profile]

REM Examples
build.bat help
build.bat package
build.bat run development
build.bat docker-run
```

### 3. Makefile - **Cross-platform builds**
Unix-style builds that work on Windows with WSL/Git Bash.

```bash
# Basic usage
make <target> [PROFILE=<profile>]

# Examples
make help
make full-build
make run PROFILE=development
make docker-run
```

## Quick Start

### Option 1: PowerShell (Recommended)
```powershell
# Full build and run
.\build.ps1 -Target full
.\build.ps1 -Target docker-run
```

### Option 2: Batch File
```batch
# Quick package and run
build.bat package
build.bat docker-run
```

### Option 3: Direct Maven
```bash
# Traditional Maven approach
mvn clean package -DskipTests
mvn spring-boot:run -Dspring.profiles.active=development
```

## Build Targets Explained

### Development Workflow

1. **Quick Development Build:**
   ```powershell
   .\build.ps1 -Target package -SkipTests
   ```

2. **Run Locally:**
   ```powershell
   .\build.ps1 -Target run -Profile development
   ```

3. **Run with Docker (includes database):**
   ```powershell
   .\build.ps1 -Target docker-run
   ```

### Production Workflow

1. **Complete Production Build:**
   ```powershell
   .\build.ps1 -Target full -Profile production
   ```

2. **Deploy with Docker:**
   ```powershell
   .\build.ps1 -Target docker-run -Profile production
   ```

### Testing Workflow

1. **Run Tests Only:**
   ```powershell
   .\build.ps1 -Target test
   ```

2. **Build with Tests:**
   ```powershell
   .\build.ps1 -Target full
   ```

## Application Profiles

### Development Profile (default)
- Uses H2/MySQL for development
- CORS enabled for frontend development
- Debug logging enabled
- Hot reload with DevTools

**Environment Variables:**
```
SPRING_PROFILES_ACTIVE=development
DATABASE_URL=jdbc:mysql://localhost:3306/itech_db
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
```

### Production Profile
- Uses PostgreSQL/MySQL for production
- Security hardened
- Performance optimized
- Monitoring enabled

**Environment Variables:**
```
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=jdbc:postgresql://prod-host:5432/itech_db
```

### Test Profile
- Uses H2 in-memory database
- Mock external services
- Fast test execution

## Prerequisites

### Required Software
- **Java 21+** - Required for Spring Boot 3.5.3
- **Maven 3.6+** - Build tool
- **Docker Desktop** - For containerized builds (optional)

### Verification Commands
```powershell
# Check Java version
java -version

# Check Maven version  
mvn --version

# Check Docker version
docker --version
```

## Project Structure

```
D:\itech-backend\itech-backend\
├── src/                          # Source code
├── target/                       # Build artifacts
├── docker-compose.yml            # Multi-service setup
├── Dockerfile                    # Container definition
├── pom.xml                       # Maven configuration
├── build.ps1                     # PowerShell build script
├── build.bat                     # Batch build script
├── Makefile                      # Cross-platform builds
└── BUILD_GUIDE.md               # This file
```

## Build Artifacts

After successful builds, you'll find:

- **JAR File:** `target/itech-backend-0.0.1-SNAPSHOT.jar`
- **Docker Image:** `itech-backend:latest`
- **Test Reports:** `target/surefire-reports/`
- **Logs:** `target/logs/` or `/app/logs` (in Docker)

## Common Build Scenarios

### Scenario 1: First Time Setup
```powershell
# Clone and build
.\build.ps1 -Target full
.\build.ps1 -Target docker-run
```

### Scenario 2: Daily Development
```powershell
# Quick build and run
.\build.ps1 -Target package -SkipTests
.\build.ps1 -Target run
```

### Scenario 3: Before Commit
```powershell
# Full build with tests
.\build.ps1 -Target clean
.\build.ps1 -Target test
.\build.ps1 -Target package
```

### Scenario 4: Production Deployment
```powershell
# Production build
.\build.ps1 -Target full -Profile production
docker tag itech-backend:latest itech-backend:production
```

## Troubleshooting

### Common Issues

1. **Java Version Mismatch**
   ```
   Error: Java 21 or higher required
   Solution: Install OpenJDK 21 or Oracle JDK 21
   ```

2. **Maven Not Found**
   ```
   Error: Maven not found in PATH
   Solution: Install Maven or use Maven Wrapper (mvnw)
   ```

3. **Docker Build Failed**
   ```
   Error: Docker build failed
   Solution: Ensure Docker Desktop is running
   ```

4. **Port Already in Use**
   ```
   Error: Port 8080 already in use
   Solution: Stop other services or change port
   ```

### Build Logs

Check build logs in:
- Maven logs: Console output
- Application logs: `target/logs/` or Docker logs
- Docker logs: `docker-compose logs`

## Environment Configuration

### Development Environment Variables
```bash
# Database
DATABASE_URL=jdbc:mysql://localhost:3306/itech_db
JDBC_DATABASE_USERNAME=itech_user
JDBC_DATABASE_PASSWORD=itech_password

# Application
SPRING_PROFILES_ACTIVE=development
CORS_ALLOWED_ORIGINS=http://localhost:3000

# JWT
JWT_SECRET=YourSuperSecretJWTKeyForDevelopment
JWT_EXPIRATION=86400000
```

### Production Environment Variables
```bash
# Database (use environment-specific values)
DATABASE_URL=${DATABASE_URL}
JDBC_DATABASE_USERNAME=${DB_USERNAME}
JDBC_DATABASE_PASSWORD=${DB_PASSWORD}

# Application
SPRING_PROFILES_ACTIVE=production
CORS_ALLOWED_ORIGINS=${FRONTEND_URL}

# Security
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRATION=3600000
```

## Integration with IDEs

### IntelliJ IDEA
1. Import as Maven project
2. Set Project SDK to Java 21
3. Configure Run Configuration:
   - Main class: `com.itech.ItechBackendApplication`
   - VM options: `-Dspring.profiles.active=development`
   - Environment variables: See development section above

### VS Code
1. Install Java Extension Pack
2. Open project folder
3. Configure `launch.json` for debugging

### Eclipse
1. Import → Existing Maven Projects
2. Set Java Build Path to Java 21
3. Configure Run Configuration with Spring Boot profile

## Performance Tips

### Faster Builds
```powershell
# Skip tests for faster builds
.\build.ps1 -Target package -SkipTests

# Use parallel builds
mvn clean package -T 1C -DskipTests
```

### Memory Optimization
```bash
# Set Maven memory
export MAVEN_OPTS="-Xmx2g -XX:+UseG1GC"

# Set Java runtime memory
export JAVA_OPTS="-Xmx1g -Xms512m"
```

## CI/CD Integration

The build scripts are designed to work with:
- **GitHub Actions** - Use `build.ps1` or Makefile targets
- **Jenkins** - Use Maven or build scripts
- **Azure DevOps** - PowerShell tasks with `build.ps1`
- **AWS CodeBuild** - Use Dockerfile and build scripts

Example GitHub Actions usage:
```yaml
- name: Build Application
  run: .\build.ps1 -Target package -SkipTests
  
- name: Run Tests
  run: .\build.ps1 -Target test
```

## Next Steps

After setting up the build system:

1. **Test the build:** `.\build.ps1 -Target package`
2. **Run locally:** `.\build.ps1 -Target run`
3. **Set up development database:** `.\build.ps1 -Target docker-run`
4. **Configure your IDE** using the settings above
5. **Start developing** - the build system will handle the rest!

---

*For additional help or issues, check the project documentation or contact the development team.*
