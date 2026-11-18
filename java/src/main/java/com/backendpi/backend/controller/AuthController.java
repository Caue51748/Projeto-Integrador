package com.backendpi.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.security.JwtService;
import com.backendpi.backend.service.UsuarioService;
import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.dto.UsuarioPerfilDTO;
import com.backendpi.backend.security.AuthSessionService;
import com.backendpi.backend.service.UsuarioService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UsuarioService usuarioService;
    private final JwtService jwtService;

    public AuthController(UsuarioService usuarioService, JwtService jwtService) {
        this.usuarioService = usuarioService;
        this.jwtService = jwtService;
    }

    @PostMapping("/login")
    public ResponseEntity<Usuario> login(@RequestBody Usuario usuario) {
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }
        Usuario user = usuarioService.login(usuario.getEmail(), usuario.getTelefone(), usuario.getSenha());
        if (user == null) {
            return ResponseEntity.status(401).build();
        }
        String token = jwtService.gerarToken(user.getIdUsuario(), user.getUsername(), user.getEmail());
        user.setToken(token);
        return ResponseEntity.ok(user);
    private final AuthSessionService authSessionService;

    public AuthController(UsuarioService usuarioService, AuthSessionService authSessionService) {
        this.usuarioService = usuarioService;
        this.authSessionService = authSessionService;
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioPerfilDTO> login(@RequestBody Usuario usuario) {
        if (usuario == null) {
            return ResponseEntity.badRequest().build();
        }
        Usuario autenticado = usuarioService.login(
                usuario.getEmail(),
                usuario.getTelefone(),
                usuario.getSenha()
        );
        if (autenticado == null) {
            return ResponseEntity.status(401).build();
        }

        UsuarioPerfilDTO perfil = new UsuarioPerfilDTO(
                autenticado.getIdUsuario(),
                autenticado.getNome(),
                autenticado.getUsername(),
                autenticado.getBio(),
                autenticado.getFotoPerfil(),
                autenticado.getInteresses()
        );
        perfil.setAuthToken(authSessionService.criarSessao(autenticado.getIdUsuario()));
        return ResponseEntity.ok(perfil);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        if (authorization != null && authorization.startsWith("Bearer ")) {
            authSessionService.encerrarSessao(authorization.substring(7).trim());
        }
        return ResponseEntity.noContent().build();
    }
}
