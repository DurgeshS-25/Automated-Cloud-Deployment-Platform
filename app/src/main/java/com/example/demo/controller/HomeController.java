package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Value;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HomeController {

    @Value("${spring.application.name}")
    private String appName;

    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to Cloud Deployment Platform!");
        response.put("application", appName);
        response.put("status", "running");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("environment", System.getenv().getOrDefault("ENVIRONMENT", "local"));
        return response;
    }

    @GetMapping("/api/info")
    public Map<String, Object> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", appName);
        response.put("version", "1.0.0");
        response.put("description", "Production-grade cloud deployment platform demo");
        response.put("author", "Durgesh");
        response.put("timestamp", LocalDateTime.now().toString());
        return response;
    }
}