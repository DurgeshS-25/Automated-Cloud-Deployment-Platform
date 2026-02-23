package com.example.demo.health;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        boolean isHealthy = checkApplicationHealth();
        
        if (isHealthy) {
            return Health.up()
                    .withDetail("app", "Cloud Platform Demo")
                    .withDetail("status", "All systems operational")
                    .build();
        } else {
            return Health.down()
                    .withDetail("app", "Cloud Platform Demo")
                    .withDetail("status", "Service degraded")
                    .build();
        }
    }

    private boolean checkApplicationHealth() {
        return true;
    }
}