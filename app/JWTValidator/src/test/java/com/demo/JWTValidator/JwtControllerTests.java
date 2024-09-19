package com.demo.JWTValidator;

import com.demo.JWTValidator.controller.JwtController;
import com.demo.JWTValidator.service.JwtService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

import java.util.Base64;

import static org.mockito.Mockito.doThrow;

@ExtendWith(SpringExtension.class)
@WebMvcTest(JwtController.class)
public class JwtControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JwtService jwtService;

    @Test
    public void testValidToken() throws Exception {
        String validToken = createToken("John", "Admin", 7);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/validate")
                        .content(validToken)
                        .contentType("application/json"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.content().string("JWT is valid"));
    }

    @Test
    public void testInvalidNumberOfClaims() throws Exception {
        String tokenWithExtraClaim = createTokenWithAdditionalClaim();

        doThrow(new Exception("Invalid number of claims")).when(jwtService).validateToken(tokenWithExtraClaim);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/validate")
                        .content(tokenWithExtraClaim)
                        .contentType("application/json"))
                .andExpect(MockMvcResultMatchers.status().isBadRequest())
                .andExpect(MockMvcResultMatchers.content().string("Invalid number of claims"));
    }

    @Test
    public void testInvalidNameClaim() throws Exception {
        String tokenWithInvalidName = createToken("John123", "Admin", 7);

        doThrow(new Exception("Invalid Name claim")).when(jwtService).validateToken(tokenWithInvalidName);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/validate")
                        .content(tokenWithInvalidName)
                        .contentType("application/json"))
                .andExpect(MockMvcResultMatchers.status().isBadRequest())
                .andExpect(MockMvcResultMatchers.content().string("Invalid Name claim"));
    }

    @Test
    public void testInvalidRoleClaim() throws Exception {
        String tokenWithInvalidRole = createToken("John", "InvalidRole", 7);

        doThrow(new Exception("Invalid Role claim")).when(jwtService).validateToken(tokenWithInvalidRole);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/validate")
                        .content(tokenWithInvalidRole)
                        .contentType("application/json"))
                .andExpect(MockMvcResultMatchers.status().isBadRequest())
                .andExpect(MockMvcResultMatchers.content().string("Invalid Role claim"));
    }

    @Test
    public void testInvalidSeedClaim() throws Exception {
        String tokenWithNonPrimeSeed = createToken("John", "Admin", 4);

        doThrow(new Exception("Invalid Seed claim")).when(jwtService).validateToken(tokenWithNonPrimeSeed);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/validate")
                        .content(tokenWithNonPrimeSeed)
                        .contentType("application/json"))
                .andExpect(MockMvcResultMatchers.status().isBadRequest())
                .andExpect(MockMvcResultMatchers.content().string("Invalid Seed claim"));
    }

    @Test
    public void testTokenMalformado() throws Exception {
        String malformedToken = "malformed_token";

        doThrow(new Exception("Invalid token format")).when(jwtService).validateToken(malformedToken);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/validate")
                        .content(malformedToken)
                        .contentType("application/json"))
                .andExpect(MockMvcResultMatchers.status().isBadRequest())
                .andExpect(MockMvcResultMatchers.content().string("Invalid token format"));
    }

    private String createToken(String name, String role, int seed) {
        // Criar o header do token JWT
        String header = "{\"alg\":\"none\",\"typ\":\"JWT\"}";
        String encodedHeader = Base64.getUrlEncoder().encodeToString(header.getBytes());

        // Criar o payload do token JWT
        String payload = "{\"Name\":\"" + name + "\",\"Role\":\"" + role + "\",\"Seed\":" + seed + "}";
        String encodedPayload = Base64.getUrlEncoder().encodeToString(payload.getBytes());

        // Retornar o token JWT simulado sem assinatura
        return encodedHeader + "." + encodedPayload + ".";
    }

    private String createTokenWithAdditionalClaim() {
        return Base64.getUrlEncoder().encodeToString("{\"Name\":\"John\",\"Role\":\"Admin\",\"Seed\":7,\"ExtraClaim\":\"ExtraValue\"}".getBytes()) + "." +
                Base64.getUrlEncoder().encodeToString("{}".getBytes()); // header placeholder
    }
}