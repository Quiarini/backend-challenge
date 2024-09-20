package com.demo.jwtvalidator.service;

public interface JwtService {
    void validateToken(String token) throws Exception;
}