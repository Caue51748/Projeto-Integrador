package com.backendpi.backend.repository;

import com.backendpi.backend.model.Usuario;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository
        extends JpaRepository<Usuario, Long> {

    boolean existsByEmail(String email);

    Usuario findByEmail(String email);

    Usuario findByEmailAndSenha(
            String email,
            String senha
    );
}