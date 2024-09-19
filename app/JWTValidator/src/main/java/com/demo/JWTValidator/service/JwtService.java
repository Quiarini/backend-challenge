package com.demo.JWTValidator.service;

public interface JwtService {
    void validateToken(String token) throws Exception;
}