package com.demo.JWTValidator.controller;

import com.demo.JWTValidator.service.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class JwtController {

    @Autowired
    private JwtService jwtService;

    @PostMapping("/validate")
    public ResponseEntity<String> validateJwt(@RequestBody String token) {
        try {
            jwtService.validateToken(token);
            return ResponseEntity.ok("JWT is valid");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}