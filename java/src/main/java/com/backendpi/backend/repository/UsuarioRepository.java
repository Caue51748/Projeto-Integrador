package com.backendpi.backend.repository;

import com.backendpi.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Usuario findByEmailAndSenha(String email, String senha);

    boolean existsByEmail(String email);
}