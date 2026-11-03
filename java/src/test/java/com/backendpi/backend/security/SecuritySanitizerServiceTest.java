package com.backendpi.backend.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.backendpi.backend.exception.ConteudoInadequadoException;

class SecuritySanitizerServiceTest {

    private SecuritySanitizerService sanitizer;

    @BeforeEach
    void setUp() {
        sanitizer = new SecuritySanitizerService();
    }

    @Test
    void devePermitirTextoValido() {
        String texto = "Bem-vindos à comunidade de desenvolvimento de jogos!";
        String resultado = sanitizer.validarEModerar(texto, "Descrição");

        assertNotNull(resultado);
        assertEquals(texto, resultado);
    }

    @Test
    void deveBloquearTentativasDeSqlInjection() {
        assertThrows(ConteudoInadequadoException.class, () ->
                sanitizer.validarEModerar("Post legal ' OR '1'='1", "Título")
        );

        assertThrows(ConteudoInadequadoException.class, () ->
                sanitizer.validarEModerar("admin'; DROP TABLE usuarios; --", "Nome")
        );

        assertThrows(ConteudoInadequadoException.class, () ->
                sanitizer.validarEModerar("1 UNION SELECT * FROM posts", "Conteúdo")
        );
    }

    @Test
    void deveBloquearPalavrasInadequadasEVulgares() {
        assertThrows(ConteudoInadequadoException.class, () ->
                sanitizer.validarEModerar("Esse post é uma merda total", "Comentário")
        );

        assertThrows(ConteudoInadequadoException.class, () ->
                sanitizer.validarEModerar("Você é muito idiota", "Mensagem")
        );

        // Teste de leetspeak e repetição
        assertThrows(ConteudoInadequadoException.class, () ->
                sanitizer.validarEModerar("Que p0rr4 é essa", "Título")
        );
    }

    @Test
    void deveSanitizarTagsXss() {
        String xss = "<script>alert('hack');</script>Olá amigos!";
        String sanitizado = sanitizer.sanitizarXss(xss);

        assertFalse(sanitizado.contains("<script>"));
        assertTrue(sanitizado.contains("Olá amigos!"));
    }
}
