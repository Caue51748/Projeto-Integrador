// UsuarioController.java
package com.backendpi.backend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
                                    usuario.getBio()
                            );

                    return ResponseEntity.ok(perfil);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/perfil")
    public ResponseEntity<Usuario> atualizarPerfil(
            @PathVariable Long id,
            @RequestBody Usuario dadosPerfil) {

        return usuarioRepository.findById(id)
                .map(usuario -> {

                    usuario.setNome(dadosPerfil.getNome());
                    usuario.setBio(dadosPerfil.getBio());

                    Usuario atualizado
                            = usuarioRepository.save(usuario);

                    return ResponseEntity.ok(atualizado);
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
                        usuario.getBio(),
                        usuario.getUsername()
                );

        return ResponseEntity.ok(perfil);
    }
}
