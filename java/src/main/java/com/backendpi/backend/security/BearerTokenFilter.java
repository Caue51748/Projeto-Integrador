package com.backendpi.backend.security;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class BearerTokenFilter extends OncePerRequestFilter {

    private final AuthSessionService sessionService;
    private final JwtService jwtService;

    @Autowired
    public BearerTokenFilter(AuthSessionService sessionService, JwtService jwtService) {
        this.sessionService = sessionService;
        this.jwtService = jwtService != null ? jwtService : new JwtService("SocialJoinChaveMestraJWT2026ParaAutenticacaoSeguraHmacSha256!#$", 604800000L);
    }

    public BearerTokenFilter(AuthSessionService sessionService) {
        this(sessionService, new JwtService("SocialJoinChaveMestraJWT2026ParaAutenticacaoSeguraHmacSha256!#$", 604800000L));
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = extrairToken(request.getHeader("Authorization"));
        Long userId = null;
        if (token != null) {
            userId = sessionService.buscarUsuarioId(token).orElse(null);
            if (userId == null && jwtService.validarToken(token)) {
                userId = jwtService.extrairIdUsuario(token);
            }
        }

        boolean endpointPublicoDeAutenticacao = HttpMethod.POST.matches(request.getMethod())
                && ("/usuarios".equals(request.getServletPath())
                || "/usuarios/login".equals(request.getServletPath())
                || "/auth/login".equals(request.getServletPath()));

        if (token != null && userId == null && !endpointPublicoDeAutenticacao) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sessão inválida ou expirada.");
            return;
        }

        boolean metodoDeEscrita = !HttpMethod.GET.matches(request.getMethod())
                && !HttpMethod.HEAD.matches(request.getMethod())
                && !HttpMethod.OPTIONS.matches(request.getMethod());

        if (metodoDeEscrita && !endpointPublicoDeAutenticacao && userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Autenticação necessária.");
            return;
        }

        if (userId != null) {
            AuthenticatedUserContext.setUserId(userId);
            request.setAttribute("usuarioId", userId);
        }
        try {
            filterChain.doFilter(request, response);
        } finally {
            AuthenticatedUserContext.clear();
        }
    }

    private String extrairToken(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return null;
        }
        return authorization.substring(7).trim();
    }
}
