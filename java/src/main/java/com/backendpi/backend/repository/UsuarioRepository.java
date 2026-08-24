package com.backendpi.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.backendpi.backend.model.Usuario;

public interface UsuarioRepository
        extends JpaRepository<Usuario, Long> {

    boolean existsByEmail(String email);

    Usuario findByEmail(String email);

    Usuario findByEmailAndSenha(
            String email,
            String senha
    );

    boolean existsByUsername(String username);
}