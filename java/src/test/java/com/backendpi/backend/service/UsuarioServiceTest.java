package com.backendpi.backend.service;

import static org.junit.jupiter.api.Assertions.assertSame;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;

import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.UsuarioRepository;

@ExtendWith(MockitoExtension.class)
class UsuarioServiceTest {

    @Mock
    private UsuarioRepository usuarioRepository;

    @InjectMocks
    private UsuarioService usuarioService;

    @Test
    void deveLogarPorEmail() {
        Usuario usuario = new Usuario();
        when(usuarioRepository.findByEmailAndSenha("ana@email.com", "12345678")).thenReturn(usuario);

        Usuario resultado = usuarioService.login("ana@email.com", null, "12345678");

        assertSame(usuario, resultado);
        verify(usuarioRepository).findByEmailAndSenha("ana@email.com", "12345678");
    }

    @Test
    void deveLogarPorTelefone() {
        Usuario usuario = new Usuario();
        when(usuarioRepository.findByTelefoneAndSenha("11999990000", "12345678")).thenReturn(usuario);

        Usuario resultado = usuarioService.login(null, "11999990000", "12345678");

        assertSame(usuario, resultado);
        verify(usuarioRepository).findByTelefoneAndSenha("11999990000", "12345678");
    }
}
