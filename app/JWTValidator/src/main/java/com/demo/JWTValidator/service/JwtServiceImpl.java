package com.demo.JWTValidator.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import com.demo.jwtvalidator.util.PrimeUtil;

import java.util.Base64;
import java.util.Arrays;
import java.util.List;
import java.util.Iterator;
import java.util.Map;

@Service
public class JwtServiceImpl implements JwtService {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void validateToken(String token) throws Exception {
        String[] chunks = token.split("\\.");
        Base64.Decoder decoder = Base64.getUrlDecoder();

        String header = new String(decoder.decode(chunks[0]));
        String payload = new String(decoder.decode(chunks[1]));

        System.out.println(header);
        System.out.println(payload);

        JsonNode claims = objectMapper.readTree(payload);

        // Validate the number of claims
        if (claims.size() != 3) {
            Iterator<Map.Entry<String, JsonNode>> fields = claims.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> field = fields.next();
                if (!field.getKey().equals("Name") && !field.getKey().equals("Role") && !field.getKey().equals("Seed")) {
                    throw new Exception("Unexpected claim: " + field.getKey());
                }
            }
        }

        // Extract claims
        String name = claims.path("Name").asText(null);
        String role = claims.path("Role").asText(null);
        Integer seed = claims.path("Seed").asInt(-1);

        // Validate individual claims
        if (name == null || role == null || seed == null) {
            throw new Exception("Invalid claims");
        }

        if (name.length() > 256 || name.chars().anyMatch(Character::isDigit)) {
            throw new Exception("Invalid Name claim");
        }

        List<String> validRoles = Arrays.asList("Admin", "Member", "External");
        if (!validRoles.contains(role)) {
            throw new Exception("Invalid Role claim");
        }

        if (!PrimeUtil.isPrime(seed)) {
            throw new Exception("Invalid Seed claim");
        }
    }
}