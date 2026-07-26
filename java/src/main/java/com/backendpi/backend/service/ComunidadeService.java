package com.backendpi.backend.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.backendpi.backend.model.Comunidade;
import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.ComunidadeRepository;
import com.backendpi.backend.repository.UsuarioRepository;

@Service
public class ComunidadeService {

    private final ComunidadeRepository repository;
    private final UsuarioRepository usuarioRepository;

    // Construtor atualizado recebendo os DOIS repositórios
    public ComunidadeService(ComunidadeRepository repository, UsuarioRepository usuarioRepository) {
        this.repository = repository;
        this.usuarioRepository = usuarioRepository;
    }

    public List<Comunidade> listar() {
        return repository.findAll();
    }

    public Comunidade criar(Map<String, Object> dados) {
        System.out.println(dados);

        Long criadorId = Long.valueOf(dados.get("criadorId").toString());

        Usuario criador = usuarioRepository.findById(criadorId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Comunidade comunidade = new Comunidade();

        comunidade.setNome(dados.get("nome").toString());
        comunidade.setDescricao(dados.get("descricao").toString());
        comunidade.setCriador(criador);

        return repository.save(comunidade);
    }

    public Comunidade atualizar(Long id, Comunidade nova) {
        return repository.findById(id).map(c -> {
            c.setNome(nova.getNome());
            c.setDescricao(nova.getDescricao());
            return repository.save(c);
        }).orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));
    }

    public void deletar(Long id) {
        repository.deleteById(id);
    }

    // NOVO MÉTODO PARA ENTRAR NA COMUNIDADE
    public void adicionarMembro(Long idComunidade, Long idUsuario) {
        Comunidade comunidade = repository.findById(idComunidade)
                .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        if (!comunidade.getMembros().contains(usuario)) {
            comunidade.getMembros().add(usuario);
            repository.save(comunidade);
        }
    }

    public void removerMembro(Long idComunidade, Long idUsuario) {
        Comunidade comunidade = repository.findById(idComunidade)
                .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        comunidade.getMembros().remove(usuario);

        repository.save(comunidade);
    }
}
