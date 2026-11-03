package com.backendpi.backend.security;

import java.io.IOException;

import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    public JwtAuthenticationFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        // 1. Permite preflight CORS OPTIONS sem autenticação
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            filterChain.doFilter(request, response);
            return;
        }

        String path = request.getRequestURI();
        String method = request.getMethod();

        // 2. Extrai cabeçalho Authorization
        String authHeader = request.getHeader("Authorization");
        String token = null;

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7).trim();
        }

        boolean tokenValido = (token != null && jwtService.validarToken(token));

        if (tokenValido) {
            request.setAttribute("usuarioId", jwtService.extrairIdUsuario(token));
            request.setAttribute("usuarioUsername", jwtService.extrairUsername(token));
            request.setAttribute("usuarioEmail", jwtService.extrairEmail(token));
        }

        // 3. Verifica se a rota precisa de proteção
        if (rotaRequerAutenticacao(path, method)) {
            if (!tokenValido) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                String mensagemErro = (token == null)
                        ? "Acesso negado: Token JWT ausente na requisição."
                        : "Acesso negado: Token JWT inválido ou expirado.";

                response.getWriter().write(String.format(
                        "{\"status\":401,\"error\":\"Unauthorized\",\"message\":\"%s\"}",
                        mensagemErro
                ));
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private boolean rotaRequerAutenticacao(String path, String method) {
        // Rotas sempre públicas
        if (path.startsWith("/uploads/")
                || path.startsWith("/google/drive/")
                || path.startsWith("/ws")
                || path.startsWith("/error")) {
            return false;
        }

        // Login e Cadastro são abertos
        if (path.equals("/usuarios/login") || path.equals("/auth/login")) {
            return false;
        }

        if (path.equals("/usuarios") && "POST".equalsIgnoreCase(method)) {
            return false;
        }

        // Chat e mensagens privadas exigem autenticação
        if (path.startsWith("/conversas") || path.startsWith("/mensagens")) {
            return true;
        }

        // Operações de escrita/modificação/exclusão (POST, PUT, DELETE, PATCH) são protegidas
        if ("POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method)
                || "PATCH".equalsIgnoreCase(method)) {
            return true;
        }

        // Consultas GET nas redes e feed são públicas para leitura
        return false;
    }
}
