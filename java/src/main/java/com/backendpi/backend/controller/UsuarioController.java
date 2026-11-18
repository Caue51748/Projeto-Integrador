package com.backendpi.backend.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.backendpi.backend.dto.AlterarSenhaRequest;
import com.backendpi.backend.dto.UsuarioPerfilDTO;
import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.ComunidadeRepository;
import com.backendpi.backend.repository.EventoRepository;
import com.backendpi.backend.repository.UsuarioRepository;
import com.backendpi.backend.security.JwtService;
import com.backendpi.backend.security.SecuritySanitizerService;
import com.backendpi.backend.service.UsuarioService;
import com.backendpi.backend.security.AuthSessionService;
import com.backendpi.backend.security.AuthenticatedUserContext;
import com.backendpi.backend.service.CloudinaryImageStorageService;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioController.class);
    private final UsuarioRepository usuarioRepository;
    private final UsuarioService usuarioService;
    private final JwtService jwtService;
    private final SecuritySanitizerService sanitizerService;
    private final AuthSessionService authSessionService;
    private final CloudinaryImageStorageService imageStorage;
    private final EventoRepository eventoRepository;
    private final ComunidadeRepository comunidadeRepository;

    public UsuarioController(
            UsuarioRepository usuarioRepository,
            UsuarioService usuarioService,
            JwtService jwtService,
            SecuritySanitizerService sanitizerService,
            AuthSessionService authSessionService,
            CloudinaryImageStorageService imageStorage,
            EventoRepository eventoRepository,
            ComunidadeRepository comunidadeRepository) {

        this.usuarioRepository = usuarioRepository;
        this.usuarioService = usuarioService;
        this.jwtService = jwtService;
        this.sanitizerService = sanitizerService;
        this.authSessionService = authSessionService;
        this.imageStorage = imageStorage;
        this.eventoRepository = eventoRepository;
        this.comunidadeRepository = comunidadeRepository;
    }

    @GetMapping
    public List<UsuarioPerfilDTO> listar() {
        AuthenticatedUserContext.requireUserId();
        return usuarioRepository.findAll().stream()
                .map(this::criarPerfil)
                .toList();
    }

    @PostMapping
    public UsuarioPerfilDTO criar(@RequestBody Usuario usuario) {
        if (usuario.getNome() != null) {
            usuario.setNome(sanitizerService.validarEModerar(usuario.getNome(), "Nome"));
        }
        if (usuario.getNomeCompleto() != null) {
            usuario.setNomeCompleto(sanitizerService.validarEModerar(usuario.getNomeCompleto(), "Nome Completo"));
        }
        if (usuario.getUsername() != null) {
            usuario.setUsername(sanitizerService.validarEModerar(usuario.getUsername(), "Username"));
        }
        if (usuario.getBio() != null) {
            usuario.setBio(sanitizerService.validarEModerar(usuario.getBio(), "Bio"));
        }

        Usuario salvo = usuarioService.salvar(usuario);
        return criarPerfilComSessao(salvo);
    }

    @PutMapping("/{id}")
    public UsuarioPerfilDTO atualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario
    ) {
        AuthenticatedUserContext.requireMatches(id);
        if (usuario.getSenha() != null && !usuario.getSenha().isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Use a opção de alteração de senha para atualizar sua senha.");
        }
        if (usuario.getNome() != null) {
            usuario.setNome(sanitizerService.validarEModerar(usuario.getNome(), "Nome"));
        }
        if (usuario.getNomeCompleto() != null) {
            usuario.setNomeCompleto(sanitizerService.validarEModerar(usuario.getNomeCompleto(), "Nome Completo"));
        }
        if (usuario.getUsername() != null) {
            usuario.setUsername(sanitizerService.validarEModerar(usuario.getUsername(), "Username"));
        }
        if (usuario.getBio() != null) {
            usuario.setBio(sanitizerService.validarEModerar(usuario.getBio(), "Bio"));
        }
        return criarPerfil(usuarioService.atualizar(id, usuario));
    }

    @DeleteMapping("/{id}")
    public void deletar(@PathVariable Long id) {
        AuthenticatedUserContext.requireMatches(id);
        usuarioService.deletar(id);
        authSessionService.encerrarSessoesDoUsuario(id);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioPerfilDTO> buscarPorId(
            @PathVariable Long id) {

        AuthenticatedUserContext.requireUserId();
        return usuarioRepository.findById(id)
                .map(usuario -> ResponseEntity.ok(criarPerfil(usuario)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/perfil")
    public ResponseEntity<?> atualizarPerfil(
            @PathVariable Long id,
            @RequestBody Usuario dadosPerfil) {

        AuthenticatedUserContext.requireMatches(id);
        return usuarioRepository.findById(id)
                .map(usuario -> {

                    String novoUsername = dadosPerfil.getUsername();

                    // Username não pode ficar vazio
                    if (novoUsername == null || novoUsername.trim().isEmpty()) {
                        return ResponseEntity
                                .badRequest()
                                .body("Username é obrigatório.");
                    }

                    novoUsername = sanitizerService.validarEModerar(novoUsername.trim(), "Username");

                    // Só verifica duplicidade se o username realmente mudou
                    if (!novoUsername.equals(usuario.getUsername())
                            && usuarioRepository.existsByUsername(novoUsername)) {

                        return ResponseEntity
                                .badRequest()
                                .body("Username já está em uso.");
                    }

                    if (dadosPerfil.getNome() != null) {
                        usuario.setNome(sanitizerService.validarEModerar(dadosPerfil.getNome(), "Nome"));
                    }
                    usuario.setUsername(novoUsername);
                    if (dadosPerfil.getBio() != null) {
                        usuario.setBio(sanitizerService.validarEModerar(dadosPerfil.getBio(), "Bio"));
                    }

                    Usuario atualizado
                            = usuarioRepository.save(usuario);

                    return ResponseEntity.ok(criarPerfil(atualizado));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/me/senha")
    public ResponseEntity<UsuarioPerfilDTO> alterarSenha(
            @RequestBody AlterarSenhaRequest dados) {
        if (dados == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Informe a senha atual e a nova senha.");
        }
        Long idUsuario = AuthenticatedUserContext.requireUserId();
        Usuario atualizado = usuarioService.alterarSenha(
                idUsuario,
                dados.senhaAtual(),
                dados.novaSenha());

        authSessionService.encerrarSessoesDoUsuario(idUsuario);
        UsuarioPerfilDTO perfil = criarPerfil(atualizado);
        perfil.setAuthToken(authSessionService.criarSessao(idUsuario));
        return ResponseEntity.ok(perfil);
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioPerfilDTO> login(
            @RequestBody Map<String, String> dados) {

        String email = dados.get("email");
        String telefone = dados.get("telefone");
        String senha = dados.get("senha");

        Usuario usuario
                = usuarioService.login(email, telefone, senha);

        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }

        return ResponseEntity.ok(criarPerfilComSessao(usuario));
    }

    @PostMapping("/{id}/foto")
    public ResponseEntity<?> atualizarFotoPerfil(
            @PathVariable Long id,
            @RequestParam("foto") MultipartFile foto) {

        AuthenticatedUserContext.requireMatches(id);
        Usuario usuario = usuarioRepository.findById(id).orElse(null);
        if (usuario == null) {
            return ResponseEntity.notFound().build();
        }

        if (foto.isEmpty()) {
            return ResponseEntity
                    .badRequest()
                    .body(Map.of("success", false, "error", "Selecione uma imagem."));
        }

        String extensao = switch (foto.getContentType() == null ? "" : foto.getContentType()) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            default -> null;
        };

        if (extensao == null) {
            return ResponseEntity
                    .badRequest()
                    .body(Map.of("success", false, "error", "Use uma imagem JPG, PNG ou WEBP."));
        }

        // Limite de 5 MB
        if (foto.getSize() > 5 * 1024 * 1024) {
            return ResponseEntity
                    .badRequest()
                    .body(Map.of("success", false, "error", "A foto deve ter no máximo 5 MB."));
        }

        try {
            CloudinaryImageStorageService.UploadedImage enviada =
                    imageStorage.upload(foto, "projeto-integrador/perfis");
            String caminhoAnterior = usuario.getFotoPerfil();
            String publicIdAnterior = usuario.getFotoPerfilPublicId();
            usuario.setFotoPerfil(enviada.secureUrl());
            usuario.setFotoPerfilPublicId(enviada.publicId());
            Usuario salvo;
            try {
                salvo = usuarioRepository.save(usuario);
            } catch (RuntimeException erroBanco) {
                try {
                    imageStorage.delete(enviada.publicId());
                } catch (RuntimeException erroLimpeza) {
                    logger.error("Não foi possível limpar imagem do Cloudinary após falha ao salvar o perfil.", erroLimpeza);
                }
                throw erroBanco;
            }

            if (publicIdAnterior != null && !publicIdAnterior.isBlank()) {
                try {
                    imageStorage.delete(publicIdAnterior);
                } catch (RuntimeException erroLimpeza) {
                    logger.warn("A nova foto foi salva, mas a foto anterior não pôde ser removida do Cloudinary.",
                            erroLimpeza);
                }
            } else {
                removerFotoLocalAntiga(caminhoAnterior);
            }

            return ResponseEntity.ok(criarPerfil(salvo));
        } catch (IllegalArgumentException erro) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", erro.getMessage()));
        } catch (ResponseStatusException erro) {
            throw erro;
        } catch (Exception erro) {
            logger.error("Não foi possível atualizar a foto de perfil.", erro);
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "error", "Não foi possível salvar a foto de perfil."));
        }
    }

    private void removerFotoLocalAntiga(String caminhoAnterior) {
        if (caminhoAnterior == null || !caminhoAnterior.startsWith("uploads/perfis/")) {
            return;
        }
        try {
            Path diretorio = Paths.get("uploads", "perfis").toAbsolutePath().normalize();
            Path fotoAnterior = diretorio.resolve(Paths.get(caminhoAnterior).getFileName()).normalize();
            if (fotoAnterior.startsWith(diretorio)) {
                Files.deleteIfExists(fotoAnterior);
            }
        } catch (IOException erroLimpeza) {
            logger.warn("Não foi possível remover a foto de perfil local anterior.", erroLimpeza);
        }
    }

    @PostMapping("/me/upgrade-premium")
    public ResponseEntity<UsuarioPerfilDTO> assinarPremium() {
        Long idUsuario = AuthenticatedUserContext.requireUserId();
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        usuario.adicionarRole("premium");
        Usuario atualizado = usuarioRepository.save(usuario);
        return ResponseEntity.ok(criarPerfil(atualizado));
    }

    @PostMapping("/me/cancelar-premium")
    public ResponseEntity<UsuarioPerfilDTO> cancelarPremium() {
        Long idUsuario = AuthenticatedUserContext.requireUserId();
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        usuario.removerRole("premium");
        Usuario atualizado = usuarioRepository.save(usuario);
        return ResponseEntity.ok(criarPerfil(atualizado));
    }

    @GetMapping("/me/limites")
    public ResponseEntity<Map<String, Object>> obterLimites() {
        Long idUsuario = AuthenticatedUserContext.requireUserId();
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        boolean premium = usuario.isPremium();
        long eventosCriados = eventoRepository.countByCriadorIdAndStatusNot(idUsuario, "CANCELADO");
        long comunidadesCriadas = comunidadeRepository.countByCriadorId(idUsuario);

        return ResponseEntity.ok(Map.of(
                "premium", premium,
                "role", usuario.getRole() == null ? "" : usuario.getRole(),
                "eventosCriados", eventosCriados,
                "limiteEventos", premium ? -1 : 3,
                "comunidadesCriadas", comunidadesCriadas,
                "limiteComunidades", premium ? -1 : 3
        ));
    }

    private UsuarioPerfilDTO criarPerfil(Usuario usuario) {
        UsuarioPerfilDTO dto = new UsuarioPerfilDTO(
                usuario.getIdUsuario(),
                usuario.getNome(),
                usuario.getUsername(),
                usuario.getBio(),
                usuario.getFotoPerfil(),
                usuario.getInteresses()
        );
        dto.setRole(usuario.getRole());
        dto.setPremium(usuario.isPremium());
        return dto;
    }

    private UsuarioPerfilDTO criarPerfilComSessao(Usuario usuario) {
        UsuarioPerfilDTO perfil = criarPerfil(usuario);
        String sessionToken = authSessionService.criarSessao(usuario.getIdUsuario());
        perfil.setAuthToken(sessionToken);
        String jwt = jwtService.gerarToken(usuario.getIdUsuario(), usuario.getUsername(), usuario.getEmail());
        perfil.setToken(jwt);
        return perfil;
    }
}
