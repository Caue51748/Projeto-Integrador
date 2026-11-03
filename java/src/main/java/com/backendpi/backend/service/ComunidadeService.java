package com.backendpi.backend.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.backendpi.backend.model.Comunidade;
import com.backendpi.backend.model.Post;
import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.ComentarioRepository;
import com.backendpi.backend.repository.ComunidadeRepository;
import com.backendpi.backend.repository.PostRepository;
import com.backendpi.backend.repository.UsuarioRepository;
import com.backendpi.backend.security.SecuritySanitizerService;

@Service
public class ComunidadeService {

    private final ComunidadeRepository repository;
    private final UsuarioRepository usuarioRepository;
    private final PostRepository postRepository;
    private final ComentarioRepository comentarioRepository;
    private final SecuritySanitizerService sanitizerService;

    public ComunidadeService(
            ComunidadeRepository repository,
            UsuarioRepository usuarioRepository,
            PostRepository postRepository,
            ComentarioRepository comentarioRepository,
            SecuritySanitizerService sanitizerService) {

        this.repository = repository;
        this.usuarioRepository = usuarioRepository;
        this.postRepository = postRepository;
        this.comentarioRepository = comentarioRepository;
        this.sanitizerService = sanitizerService;
    }

    public List<Comunidade> listar() {
        return repository.findAll();
    }

    public Comunidade buscarPorId(Long idComunidade) {
        return repository.findById(idComunidade)
                .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));
    }

    public Comunidade salvar(Comunidade comunidade) {
        if (comunidade.getNome() != null) {
            comunidade.setNome(sanitizerService.validarEModerar(comunidade.getNome(), "Nome da comunidade"));
        }
        if (comunidade.getDescricao() != null) {
            comunidade.setDescricao(sanitizerService.validarEModerar(comunidade.getDescricao(), "Descrição da comunidade"));
        }
        if (comunidade.getCategoria() != null) {
            comunidade.setCategoria(sanitizerService.validarEModerar(comunidade.getCategoria(), "Categoria da comunidade"));
        }
        return repository.save(comunidade);
    }

    public List<Comunidade> listarPorUsuario(Long idUsuario) {
        return repository.findByMembroId(idUsuario);
    }

    public Comunidade criar(Map<String, Object> dados) {

        Long criadorId = Long.valueOf(dados.get("criadorId").toString());

        Usuario criador = usuarioRepository.findById(criadorId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        String nome = dados.get("nome") != null ? dados.get("nome").toString() : "";
        String descricao = dados.get("descricao") != null ? dados.get("descricao").toString() : "";
        String categoria = dados.get("categoria") == null ? null : dados.get("categoria").toString();

        nome = sanitizerService.validarEModerar(nome, "Nome da comunidade");
        descricao = sanitizerService.validarEModerar(descricao, "Descrição da comunidade");
        if (categoria != null) {
            categoria = sanitizerService.validarEModerar(categoria, "Categoria da comunidade");
        }

        Comunidade comunidade = new Comunidade();
        comunidade.setNome(nome);
        comunidade.setDescricao(descricao);
        comunidade.setCategoria(categoria);
        comunidade.setCor(dados.get("cor") == null ? "#EA3F74" : dados.get("cor").toString());
        comunidade.setCriador(criador);
        comunidade.getMembros().add(criador);

        return repository.save(comunidade);
    }

    public Comunidade atualizar(Long idComunidade, Long idUsuario, Comunidade nova) {

        Comunidade comunidade = repository.findById(idComunidade)
                .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));

        if (comunidade.getCriador() == null
                || !comunidade.getCriador().getIdUsuario().equals(idUsuario)) {

            throw new RuntimeException("Usuário sem permissão para editar esta comunidade");
        }

        if (nova.getNome() != null) {
            comunidade.setNome(sanitizerService.validarEModerar(nova.getNome(), "Nome da comunidade"));
        }
        if (nova.getDescricao() != null) {
            comunidade.setDescricao(sanitizerService.validarEModerar(nova.getDescricao(), "Descrição da comunidade"));
        }
        if (nova.getCategoria() != null) {
            comunidade.setCategoria(sanitizerService.validarEModerar(nova.getCategoria(), "Categoria da comunidade"));
        }
        if (nova.getCor() != null) {
            comunidade.setCor(nova.getCor());
        }

        return repository.save(comunidade);
    }

    public void deletar(Long idComunidade, Long idUsuario) {

        Comunidade comunidade = repository.findById(idComunidade)
                .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));

        if (comunidade.getCriador() == null
                || !comunidade.getCriador().getIdUsuario().equals(idUsuario)) {

            throw new RuntimeException(
                    "Usuário sem permissão para excluir esta comunidade"
            );
        }

        List<Post> postsDaComunidade
                = postRepository.findByIdComunidade(idComunidade);

        for (Post post : postsDaComunidade) {

            comentarioRepository.deleteAll(
                    comentarioRepository.findByIdPost(post.getIdPost())
            );

            postRepository.delete(post);
        }

        repository.delete(comunidade);
    }

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

    public void removerMembro(
            Long idComunidade,
            Long idMembro,
            Long idSolicitante) {

        Comunidade comunidade = repository.findById(idComunidade)
                .orElseThrow(() -> new RuntimeException("Comunidade não encontrada"));

        Usuario membro = usuarioRepository.findById(idMembro)
                .orElseThrow(() -> new RuntimeException("Membro não encontrado"));

        if (comunidade.getCriador() == null) {
            throw new RuntimeException("Comunidade sem administrador");
        }

        Long idAdministrador = comunidade.getCriador().getIdUsuario();

        boolean removendoASiMesmo = idMembro.equals(idSolicitante);
        boolean solicitanteEhAdministrador = idAdministrador.equals(idSolicitante);

        // Administrador não pode sair/remover a si próprio
        if (idMembro.equals(idAdministrador)) {
            throw new RuntimeException(
                    "O administrador não pode ser removido da comunidade"
            );
        }

        // Só o próprio membro ou o administrador podem fazer a remoção
        if (!removendoASiMesmo && !solicitanteEhAdministrador) {
            throw new RuntimeException(
                    "Usuário sem permissão para remover este membro"
            );
        }

        comunidade.getMembros().remove(membro);

        repository.save(comunidade);
    }
}
