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

@RestController
@RequestMapping("/auth")
@CrossOrigin("*")
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
    }
}
