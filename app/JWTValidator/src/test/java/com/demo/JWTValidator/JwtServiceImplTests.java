package com.demo.JWTValidator;

import com.demo.JWTValidator.service.JwtServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class JwtServiceImplTests {

    private JwtServiceImpl jwtService;

    @BeforeEach
    public void setUp() {
        jwtService = new JwtServiceImpl();
    }

    @Test
    public void testValidToken() throws Exception {
        String validToken = createToken("John", "Admin", 7);
        assertDoesNotThrow(() -> jwtService.validateToken(validToken));
    }

    @Test
    public void testInvalidNumberOfClaims() {
        String tokenWithExtraClaim = createTokenWithAdditionalClaim();
        assertThrows(Exception.class, () -> jwtService.validateToken(tokenWithExtraClaim),
                "Invalid number of claims");
    }

    @Test
    public void testInvalidNameClaim() {
        String tokenWithInvalidName = createToken("John123", "Admin", 7); // Invalid name with digits
        assertThrows(Exception.class, () -> jwtService.validateToken(tokenWithInvalidName),
                "Invalid Name claim");
    }

    @Test
    public void testInvalidRoleClaim() {
        String tokenWithInvalidRole = createToken("John", "InvalidRole", 7);
        assertThrows(Exception.class, () -> jwtService.validateToken(tokenWithInvalidRole),
                "Invalid Role claim");
    }

    @Test
    public void testInvalidSeedClaim() {
        String tokenWithNonPrimeSeed = createToken("John", "Admin", 4); // 4 is not a prime number
        assertThrows(Exception.class, () -> jwtService.validateToken(tokenWithNonPrimeSeed),
                "Invalid Seed claim");
    }

    @Test
    public void testAdditionalClaim() {
        String tokenWithAdditionalClaim = createTokenWithAdditionalClaim();
        assertThrows(Exception.class, () -> jwtService.validateToken(tokenWithAdditionalClaim),
                "Unexpected claim: ExtraClaim");
    }

    private String createToken(String name, String role, int seed) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("Name", name);
        claims.put("Role", role);
        claims.put("Seed", seed);
        return createTokenWithClaims(claims);
    }

    private String createTokenWithAdditionalClaim() {
        Map<String, Object> claims = new HashMap<>();
        claims.put("Name", "John");
        claims.put("Role", "Admin");
        claims.put("Seed", 7);
        claims.put("ExtraClaim", "ExtraValue"); // Additional claim
        return createTokenWithClaims(claims);
    }

    private String createTokenWithClaims(Map<String, Object> claims) {
        // Create payload JSON from the claims map
        String payload = claims.entrySet().stream()
                .map(entry -> "\"" + entry.getKey() + "\":\"" + entry.getValue() + "\"")
                .collect(Collectors.joining(",", "{", "}"));

        // Base64 encode the payload and header
        String header = "{}"; // Simplified header
        String encodedHeader = Base64.getUrlEncoder().encodeToString(header.getBytes());
        String encodedPayload = Base64.getUrlEncoder().encodeToString(payload.getBytes());

        // Combine header and payload to form the token
        return encodedHeader + "." + encodedPayload;
    }
}