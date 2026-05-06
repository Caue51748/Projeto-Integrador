package com.backendpi.backend.service;

import com.backendpi.backend.model.Post;
import com.backendpi.backend.repository.PostRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PostService {

    private final PostRepository repository;

    public PostService(PostRepository repository) {
        this.repository = repository;
    }

    public List<Post> listar() {
        return repository.findAll();
    }

    public Post salvar(Post post) {
        return repository.save(post);
    }

    public Post buscarPorId(Long id) {
        return repository.findById(id).orElse(null);
    }

    public void deletar(Long id) {
        repository.deleteById(id);
    }

    public Post atualizar(Long id, Post novo) {

        return repository.findById(id).map(post -> {

            post.setTitulo(novo.getTitulo());
            post.setConteudo(novo.getConteudo());
            post.setIdUsuario(novo.getIdUsuario());
            post.setIdComunidade(novo.getIdComunidade());

            return repository.save(post);

        }).orElseThrow();
    }
}