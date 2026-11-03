package com.backendpi.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.backendpi.backend.model.Comentario;
import com.backendpi.backend.repository.ComentarioRepository;
import com.backendpi.backend.security.SecuritySanitizerService;

@Service
public class ComentarioService {

    private final ComentarioRepository repository;
    private final SecuritySanitizerService sanitizerService;

    public ComentarioService(ComentarioRepository repository, SecuritySanitizerService sanitizerService) {
        this.repository = repository;
        this.sanitizerService = sanitizerService;
    }

    public List<Comentario> listar() {
        return repository.findAll();
    }

    public List<Comentario> listarPorPost(Long idPost) {
        return repository.findByIdPost(idPost);
    }

    public Comentario criar(Comentario comentario) {
        if (comentario.getConteudo() != null) {
            comentario.setConteudo(sanitizerService.validarEModerar(comentario.getConteudo(), "Conteúdo do comentário"));
        }
        return repository.save(comentario);
    }

    public Comentario atualizar(Long id, Comentario novo) {
        return repository.findById(id).map(c -> {

            String conteudoLimpo = sanitizerService.validarEModerar(novo.getConteudo(), "Conteúdo do comentário");
            c.setConteudo(conteudoLimpo);
            c.setIdUsuario(novo.getIdUsuario());
            c.setIdPost(novo.getIdPost());

            return repository.save(c);

        }).orElseThrow(() -> new RuntimeException("Comentário não encontrado"));
    }

    public void deletar(Long id) {
        repository.deleteById(id);
    }
}
