package com.backendpi.backend.service;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.UsuarioRepository;

@Service
public class UsuarioService {

    private final UsuarioRepository repository;

    public UsuarioService(UsuarioRepository repository) {
        this.repository = repository;
    }

    public List<Usuario> listar() {
        return repository.findAll();
    }

    public Usuario salvar(Usuario usuario) {

        if (repository.existsByEmail(usuario.getEmail())) {
            throw new RuntimeException("Email já cadastrado");
        }

        if (repository.existsByUsername(usuario.getUsername())) {
            throw new RuntimeException(
                    "Nome de usuário já cadastrado"
            );
        }

        return repository.save(usuario);
    }

    public void deletar(Long id) {
        repository.deleteById(id);
    }

    public Usuario login(String email, String senha) {
        return repository.findByEmailAndSenha(email, senha);
    }

    public Optional<Usuario> buscarPorId(Long id) {
        return repository.findById(id);
    }
}
