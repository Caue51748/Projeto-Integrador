package com.backendpi.backend.controller;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.backendpi.backend.dto.UsuarioPerfilDTO;
import com.backendpi.backend.model.Usuario;
import com.backendpi.backend.repository.UsuarioRepository;
import com.backendpi.backend.security.JwtService;
import com.backendpi.backend.security.SecuritySanitizerService;
import com.backendpi.backend.service.UsuarioService;

@RestController
@RequestMapping("/usuarios")
@CrossOrigin("*")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final UsuarioService usuarioService;
    private final JwtService jwtService;
    private final SecuritySanitizerService sanitizerService;

    public UsuarioController(
            UsuarioRepository usuarioRepository,
            UsuarioService usuarioService,
            JwtService jwtService,
            SecuritySanitizerService sanitizerService) {

        this.usuarioRepository = usuarioRepository;
        this.usuarioService = usuarioService;
        this.jwtService = jwtService;
        this.sanitizerService = sanitizerService;
    }

    @GetMapping
    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }

    @PostMapping
    public Usuario criar(@RequestBody Usuario usuario) {
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
        String token = jwtService.gerarToken(salvo.getIdUsuario(), salvo.getUsername(), salvo.getEmail());
        salvo.setToken(token);
        return salvo;
    }

    @PutMapping("/{id}")
    public Usuario atualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario
    ) {
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
        return usuarioService.atualizar(id, usuario);
    }

    @DeleteMapping("/{id}")
    public void deletar(@PathVariable Long id) {
        usuarioRepository.deleteById(id);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioPerfilDTO> buscarPorId(
            @PathVariable Long id) {

        return usuarioRepository.findById(id)
                .map(usuario -> {

                    UsuarioPerfilDTO perfil
                            = new UsuarioPerfilDTO(
                                    usuario.getIdUsuario(),
                                    usuario.getNome(),
                                    usuario.getUsername(),
                                    usuario.getBio(),
                                    usuario.getFotoPerfil(),
                                    usuario.getInteresses()
                            );

                    return ResponseEntity.ok(perfil);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/perfil")
    public ResponseEntity<?> atualizarPerfil(
            @PathVariable Long id,
            @RequestBody Usuario dadosPerfil) {

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

                    UsuarioPerfilDTO perfil
                            = new UsuarioPerfilDTO(
                                    atualizado.getIdUsuario(),
                                    atualizado.getNome(),
                                    atualizado.getUsername(),
                                    atualizado.getBio(),
                                    atualizado.getFotoPerfil(),
                                    atualizado.getInteresses()
                            );

                    return ResponseEntity.ok(perfil);
                })
                .orElse(ResponseEntity.notFound().build());
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

        String token = jwtService.gerarToken(usuario.getIdUsuario(), usuario.getUsername(), usuario.getEmail());

        UsuarioPerfilDTO perfil
                = new UsuarioPerfilDTO(
                        usuario.getIdUsuario(),
                        usuario.getNome(),
                        usuario.getUsername(),
                        usuario.getBio(),
                        usuario.getFotoPerfil(),
                        usuario.getInteresses(),
                        token
                );

        return ResponseEntity.ok(perfil);
    }

    @PostMapping("/{id}/foto")
    public ResponseEntity<?> atualizarFotoPerfil(
            @PathVariable Long id,
            @RequestParam("foto") MultipartFile foto) {

        Usuario usuario = usuarioRepository.findById(id)
                .orElse(null);

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
            Path diretorio = Paths.get("uploads", "perfis").toAbsolutePath().normalize();
            Files.createDirectories(diretorio);
            Path destino = diretorio.resolve(UUID.randomUUID() + extensao).normalize();
            if (!destino.startsWith(diretorio)) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "error", "Nome de arquivo inválido."));
            }

            try (InputStream arquivo = foto.getInputStream()) {
                Files.copy(arquivo, destino);
            }

            String caminhoFoto = "uploads/perfis/" + destino.getFileName();
            String caminhoAnterior = usuario.getFotoPerfil();
            usuario.setFotoPerfil(caminhoFoto);
            Usuario salvo;
            try {
                salvo = usuarioRepository.save(usuario);
            } catch (RuntimeException erroBanco) {
                Files.deleteIfExists(destino);
                throw erroBanco;
            }

            if (caminhoAnterior != null && caminhoAnterior.startsWith("uploads/perfis/")) {
                try {
                    String nomeAnterior = Paths.get(caminhoAnterior).getFileName().toString();
                    Path fotoAnterior = diretorio.resolve(nomeAnterior).normalize();
                    if (fotoAnterior.startsWith(diretorio) && !fotoAnterior.equals(destino)) {
                        Files.deleteIfExists(fotoAnterior);
                    }
                } catch (Exception erroLimpeza) {
                    System.err.println("Não foi possível remover a foto de perfil anterior: "
                            + erroLimpeza.getMessage());
                }
            }

            UsuarioPerfilDTO perfil = new UsuarioPerfilDTO(
                    salvo.getIdUsuario(),
                    salvo.getNome(),
                    salvo.getUsername(),
                    salvo.getBio(),
                    salvo.getFotoPerfil(),
                    salvo.getInteresses()
            );

            return ResponseEntity.ok(perfil);

        } catch (Exception erro) {
            erro.printStackTrace();
            return ResponseEntity
                    .internalServerError()
                    .body(Map.of("success", false, "error", "Não foi possível salvar a foto de perfil."));
        }
    }
}
