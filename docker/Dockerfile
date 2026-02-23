# ============================================
# Multi-Stage Docker Build for Spring Boot
# ============================================

# Stage 1: Build Stage
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /build

# Copy the entire app directory
COPY app/ .

# Build the application
RUN if [ -f "./mvnw" ]; then \
      chmod +x ./mvnw && ./mvnw clean package -DskipTests; \
    else \
      apk add --no-cache maven && mvn clean package -DskipTests; \
    fi

# ============================================
# Stage 2: Runtime Stage (Production)
# ============================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install wget for health checks
RUN apk add --no-cache wget curl

# Create non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring

# Copy JAR from builder stage
COPY --from=builder /build/target/*.jar app.jar

# Set ownership
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring:spring

# Expose application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]