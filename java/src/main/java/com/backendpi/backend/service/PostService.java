package com.backendpi.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.backendpi.backend.model.Comunidade;
import com.backendpi.backend.model.Post;
import com.backendpi.backend.repository.ComentarioRepository;
import com.backendpi.backend.repository.ComunidadeRepository;
import com.backendpi.backend.repository.PostRepository;

@Service
public class PostService {

    private final PostRepository repository;
    private final ComentarioRepository comentarioRepository;
    private final ComunidadeRepository comunidadeRepository;

    public PostService(
            PostRepository repository,
            ComentarioRepository comentarioRepository,
            ComunidadeRepository comunidadeRepository) {

        this.repository = repository;
        this.comentarioRepository = comentarioRepository;
        this.comunidadeRepository = comunidadeRepository;
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

    public void deletar(Long idPost, Long idUsuario) {

        Post post = repository.findById(idPost)
                .orElseThrow(() -> new RuntimeException("Post não encontrado"));

        boolean eAutor = post.getIdUsuario().equals(idUsuario);

        boolean eAdministrador = false;

        if (post.getIdComunidade() != null) {
            Comunidade comunidade = comunidadeRepository.findById(post.getIdComunidade())
                    .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));

            if (comunidade.getCriador() != null) {
                eAdministrador = comunidade.getCriador()
                        .getIdUsuario()
                        .equals(idUsuario);
            }
        }

        if (!eAutor && !eAdministrador) {
            throw new RuntimeException("Usuário sem permissão para excluir este post");
        }

        comentarioRepository.deleteAll(
                comentarioRepository.findByIdPost(idPost)
        );

        repository.deleteById(idPost);
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
