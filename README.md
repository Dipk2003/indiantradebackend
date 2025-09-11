# Indian Trade Mart Backend

Production-grade Spring Boot backend for the Indian Trade Mart B2B marketplace. Built for scale, security, and maintainability.

- Language: Java 21
- Framework: Spring Boot 3.5.x
- Packaging: Executable JAR (embedded Tomcat)
- Database: MySQL (Prod/Dev), H2 (Tests)
- Build Tool: Maven

## Architecture Overview

- Modular design under `com.itech.itech_backend.modules` with clear separation of concerns:
  - core (auth, users, security)
  - buyer, vendor, product, order, payment, support, analytics, admin, etc.
- Layering: Controller → Service → Repository → Model
- Security: JWT-based authentication, role-based authorization
- Observability: Spring Boot Actuator, Micrometer
- Caching: Caffeine + Redis (optional)
- Messaging/WebSocket: Real-time support for chat and notifications
- Storage: Local filesystem/AWS S3 (via SDK) for file/document handling

## Project Layout

```
src/main/java/com/itech/itech_backend/
  config/        # application-level configs
  controller/    # shared/root controllers
  modules/       # feature modules (admin, buyer, vendor, ...)
  security/      # security configuration & filters
  service/       # shared/root services
  util/          # utilities

src/main/resources/
  application.properties
  application-dev.properties
  application-prod.properties
  logback-spring.xml
  db/migration/ (Flyway)
  openapi/ (specs)
```

## Quick Start (Local)

1) Prerequisites
- Java 21+
- Maven 3.9+
- MySQL 8.0+ running locally

2) Configure database (local dev)
- Update `src/main/resources/application.properties` if needed:
```
spring.datasource.url=jdbc:mysql://localhost:3306/itech_db
spring.datasource.username=root
spring.datasource.password=root
```

3) Build
```
mvn clean install -DskipTests
```

4) Run
```
java -jar target/itech-backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

5) Health
- Actuator: http://localhost:8080/actuator/health

## Environments

- application.properties (base defaults)
- application-dev.properties (developer-friendly; verbose logging, relaxed constraints)
- application-prod.properties (secure defaults; externalized secrets, SSL-ready)

Key overrides for production via environment variables:
- DATABASE_URL, DB_USERNAME, DB_PASSWORD
- JWT_SECRET, ENABLE_SWAGGER
- CORS_ALLOWED_ORIGINS
- FILE_UPLOAD_DIR

## Security

- JWT Access & Refresh tokens
- Role-based endpoints: Buyer, Vendor, Admin, Support, CTO, Data Entry
- CORS configured for web clients
- Password hashing (BCrypt)

## Major Modules & Endpoints

- Authentication (/auth)
  - register, login, role-specific login, OTP login, profile, password flows
- Users (/api/users)
  - admin-only management, lookup, counts
- Buyers (/api/buyers)
  - CRUD, verification (email/phone/KYC), filters, analytics, bulk ops
- Vendors (/api/v1/vendors)
  - CRUD, KYC/verification, status, profile, analytics, search/filters
- Payments (/api/payments)
  - charge, verify, webhooks (Razorpay)
- Support (/api/support)
  - tickets, chat, chatbot
- Admin (/api/admin)
  - dashboard, configuration, analytics

For a full, importable API collection, see API_DOCUMENTATION.json in repository root (compatible with Postman/Thunder Client).

## Building a Release JAR

```
mvn clean install -DskipTests
```
Artifact:
- target/itech-backend-0.0.1-SNAPSHOT.jar

Run with custom options:
```
java -jar target/itech-backend-0.0.1-SNAPSHOT.jar \
  --server.port=8080 \
  --spring.profiles.active=prod \
  --DATABASE_URL=jdbc:mysql://db:3306/itech_db \
  --DB_USERNAME=itech \
  --DB_PASSWORD=*** \
  --JWT_SECRET=***
```

Note: Use environment variables or a secret manager. Do not hardcode secrets.

## OpenAPI / Swagger

If enabled (dev), visit:
- http://localhost:8080/swagger-ui.html
- http://localhost:8080/v3/api-docs

## Observability

- Actuator endpoints (secured in prod) for health, metrics, info
- Micrometer metrics; Prometheus integration supported

## Data Migrations

- Flyway ready
- Place SQL migrations in `src/main/resources/db/migration`
- Enable in properties for controlled rollout

## File Uploads

- Multipart configured; see properties for max sizes
- AWS S3 integration available via AWS SDK dependencies

## Quality & Operations Notes

- Prefer DTOs at controller boundaries; validate with `jakarta.validation`
- Services are transactional; repositories are Spring Data JPA
- Use pagination for any list endpoint
- Keep logging at INFO in production, DEBUG locally
- Avoid exposing sensitive stack traces

## Troubleshooting

- Port conflicts: change `server.port` via CLI flag
- DB auth errors: confirm credentials & connectivity
- JWT issues: ensure `JWT_SECRET` is set and consistent across services

## License & Ownership

Proprietary. All rights reserved to Indian Trade Mart.

