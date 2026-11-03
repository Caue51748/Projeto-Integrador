package com.backendpi.backend.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class JwtServiceTest {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService("ChaveDeTesteSeguraSuperSecretaSocialJoin2026HmacSha256!#$", 3600000L);
    }

    @Test
    void deveGerarEValidarTokenComSucesso() {
        String token = jwtService.gerarToken(42L, "pedro", "pedro@socialjoin.com");

        assertNotNull(token);
        assertTrue(jwtService.validarToken(token));
        assertEquals(42L, jwtService.extrairIdUsuario(token));
        assertEquals("pedro", jwtService.extrairUsername(token));
        assertEquals("pedro@socialjoin.com", jwtService.extrairEmail(token));
    }

    @Test
    void deveRejeitarTokenComAssinaturaAdulterada() {
        String token = jwtService.gerarToken(10L, "lucas", "lucas@email.com");
        String[] partes = token.split("\\.");
        
        // Altera a assinatura
        String tokenAdulterado = partes[0] + "." + partes[1] + ".assinaturaFalsa123";

        assertFalse(jwtService.validarToken(tokenAdulterado));
    }

    @Test
    void deveRejeitarTokenExpirado() {
        // Token com expiração de -1 segundo
        JwtService jwtExpirado = new JwtService("ChaveDeTesteSeguraSuperSecretaSocialJoin2026HmacSha256!#$", -1000L);
        String token = jwtExpirado.gerarToken(5L, "maria", "maria@email.com");

        assertFalse(jwtExpirado.validarToken(token));
    }

    @Test
    void deveRejeitarTokenInvalidoOuNulo() {
        assertFalse(jwtService.validarToken(null));
        assertFalse(jwtService.validarToken(""));
        assertFalse(jwtService.validarToken("formato.invalido"));
    }
}
