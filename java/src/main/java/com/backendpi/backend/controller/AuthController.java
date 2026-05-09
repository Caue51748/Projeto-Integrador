package com.backendpi.backend.controller;

import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.UsuarioRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@CrossOrigin("*")
public class AuthController {

    @Autowired
    private UsuarioRepository repository;

    @PostMapping("/login")
    public Usuario login(@RequestBody Usuario usuario) {

        Usuario usuarioEncontrado =
                repository.findByEmail(usuario.getEmail());

        if (usuarioEncontrado == null) {
            return null;
        }

        if (!usuarioEncontrado.getSenha()
                .equals(usuario.getSenha())) {

            return null;
        }

        return usuarioEncontrado;
    }
}