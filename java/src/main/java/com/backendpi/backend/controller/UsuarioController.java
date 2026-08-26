// UsuarioController.java
package com.backendpi.backend.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
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
import com.backendpi.backend.service.UsuarioService;

@RestController
@RequestMapping("/usuarios")
@CrossOrigin("*")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final UsuarioService usuarioService;

    public UsuarioController(
            UsuarioRepository usuarioRepository,
            UsuarioService usuarioService) {

        this.usuarioRepository = usuarioRepository;
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }

    @PostMapping
    public Usuario criar(@RequestBody Usuario usuario) {
        return usuarioService.salvar(usuario);
    }

    @PutMapping("/{id}")
    public Usuario atualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario
    ) {
        usuario.setIdUsuario(id);
        return usuarioRepository.save(usuario);
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
                                    usuario.getFotoPerfil()
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

                    novoUsername = novoUsername.trim();

                    // Só verifica duplicidade se o username realmente mudou
                    if (!novoUsername.equals(usuario.getUsername())
                            && usuarioRepository.existsByUsername(novoUsername)) {

                        return ResponseEntity
                                .badRequest()
                                .body("Username já está em uso.");
                    }

                    usuario.setNome(dadosPerfil.getNome());
                    usuario.setUsername(novoUsername);
                    usuario.setBio(dadosPerfil.getBio());

                    Usuario atualizado
                            = usuarioRepository.save(usuario);

                    UsuarioPerfilDTO perfil
                            = new UsuarioPerfilDTO(
                                    atualizado.getIdUsuario(),
                                    atualizado.getNome(),
                                    atualizado.getUsername(),
                                    atualizado.getBio(),
                                    atualizado.getFotoPerfil()
                            );

                    return ResponseEntity.ok(perfil);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioPerfilDTO> login(
            @RequestBody Map<String, String> dados) {

        String email = dados.get("email");
        String senha = dados.get("senha");

        Usuario usuario
                = usuarioService.login(email, senha);

        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }

        UsuarioPerfilDTO perfil
                = new UsuarioPerfilDTO(
                        usuario.getIdUsuario(),
                        usuario.getNome(),
                        usuario.getUsername(),
                        usuario.getBio(),
                        usuario.getFotoPerfil()
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

         System.out.println("=== TROCA DE FOTO ===");
        System.out.println("Usuario: " + id);
        System.out.println("Arquivo: " + foto.getOriginalFilename());
        System.out.println("Foto antiga: " + usuario.getFotoPerfil());

        if (foto.isEmpty()) {
            return ResponseEntity
                    .badRequest()
                    .body("Selecione uma imagem.");
        }

        String tipo = foto.getContentType();

        if (tipo == null || !tipo.startsWith("image/")) {
            return ResponseEntity
                    .badRequest()
                    .body("O arquivo precisa ser uma imagem.");
        }

        try {

            Path pasta
                    = Paths.get("uploads", "perfis");

            Files.createDirectories(pasta);

            String nomeOriginal
                    = foto.getOriginalFilename();

            String extensao = "";

            if (nomeOriginal != null
                    && nomeOriginal.contains(".")) {

                extensao = nomeOriginal.substring(
                        nomeOriginal.lastIndexOf(".")
                );
            }

            String nomeArquivo
                    = UUID.randomUUID() + extensao;

            Path destino
                    = pasta.resolve(nomeArquivo);

            Files.copy(
                    foto.getInputStream(),
                    destino,
                    StandardCopyOption.REPLACE_EXISTING
            );

            String caminho
                    = "uploads/perfis/" + nomeArquivo;

            usuario.setFotoPerfil(caminho);

            usuarioRepository.save(usuario);

            UsuarioPerfilDTO perfil
                    = new UsuarioPerfilDTO(
                            usuario.getIdUsuario(),
                            usuario.getNome(),
                            usuario.getUsername(),
                            usuario.getBio(),
                            usuario.getFotoPerfil()
                    );

            return ResponseEntity.ok(perfil);

        } catch (IOException erro) {

            erro.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body("Erro ao salvar a imagem.");
        }
    }
}
