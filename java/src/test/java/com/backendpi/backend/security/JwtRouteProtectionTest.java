package com.backendpi.backend.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import java.io.IOException;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import jakarta.servlet.ServletException;

class JwtRouteProtectionTest {

    private JwtService jwtService;
    private JwtAuthenticationFilter filter;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService("ChaveDeTesteSeguraSuperSecretaSocialJoin2026HmacSha256!#$", 3600000L);
        filter = new JwtAuthenticationFilter(jwtService);
    }

    @Test
    void devePermitirPreflightCorsOptionsSemToken() throws ServletException, IOException {
        MockHttpServletRequest request = new MockHttpServletRequest("OPTIONS", "/posts");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain filterChain = new MockFilterChain();

        filter.doFilterInternal(request, response, filterChain);

        assertEquals(200, response.getStatus());
    }

    @Test
    void devePermitirRotaPublicaGetPostsSemToken() throws ServletException, IOException {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/posts");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain filterChain = new MockFilterChain();

        filter.doFilterInternal(request, response, filterChain);

        // Não deve ser barrado com 401
        assertEquals(200, response.getStatus());
    }

    @Test
    void deveBloquearRotaProtegidaPostPostsSemToken() throws ServletException, IOException {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/posts");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain filterChain = new MockFilterChain();

        filter.doFilterInternal(request, response, filterChain);

        assertEquals(401, response.getStatus());
        assertTrue(response.getContentAsString().contains("Token JWT ausente"));
    }

    @Test
    void deveBloquearRotaProtegidaComTokenInvalido() throws ServletException, IOException {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/posts");
        request.addHeader("Authorization", "Bearer token_falso_invalido");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain filterChain = new MockFilterChain();

        filter.doFilterInternal(request, response, filterChain);

        assertEquals(401, response.getStatus());
        assertTrue(response.getContentAsString().contains("Token JWT inválido"));
    }

    @Test
    void devePermitirRotaProtegidaComTokenValido() throws ServletException, IOException {
        String tokenValido = jwtService.gerarToken(99L, "carlos", "carlos@socialjoin.com");

        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/posts");
        request.addHeader("Authorization", "Bearer " + tokenValido);
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain filterChain = new MockFilterChain();

        filter.doFilterInternal(request, response, filterChain);

        assertEquals(200, response.getStatus());
        assertEquals(99L, request.getAttribute("usuarioId"));
        assertEquals("carlos", request.getAttribute("usuarioUsername"));
        assertEquals("carlos@socialjoin.com", request.getAttribute("usuarioEmail"));
    }
}
