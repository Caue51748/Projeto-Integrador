package com.backendpi.backend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
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
import com.backendpi.backend.service.GoogleDriveService;
import com.backendpi.backend.service.UsuarioService;

@RestController
@RequestMapping("/usuarios")
@CrossOrigin("*")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final UsuarioService usuarioService;
    private final GoogleDriveService googleDriveService;


    public UsuarioController(
            UsuarioRepository usuarioRepository,
            UsuarioService usuarioService,
            GoogleDriveService googleDriveService) {

        this.usuarioRepository = usuarioRepository;
        this.usuarioService = usuarioService;
        this.googleDriveService = googleDriveService;
    }


    // =====================================================
    // LISTAR USUÁRIOS
    // =====================================================

    @GetMapping
    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }


    // =====================================================
    // CRIAR USUÁRIO
    // =====================================================

    @PostMapping
    public Usuario criar(
            @RequestBody Usuario usuario) {

        return usuarioService.salvar(usuario);
    }


    // =====================================================
    // ATUALIZAR USUÁRIO
    // =====================================================

    @PutMapping("/{id}")
    public Usuario atualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario) {

        usuario.setIdUsuario(id);

        return usuarioRepository.save(usuario);
    }


    // =====================================================
    // DELETAR USUÁRIO
    // =====================================================

    @DeleteMapping("/{id}")
    public void deletar(
            @PathVariable Long id) {

        usuarioRepository.deleteById(id);
    }


    // =====================================================
    // BUSCAR PERFIL
    // =====================================================

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioPerfilDTO> buscarPorId(
            @PathVariable Long id) {

        return usuarioRepository.findById(id)
                .map(usuario -> {

                    UsuarioPerfilDTO perfil =
                            new UsuarioPerfilDTO(
                                    usuario.getIdUsuario(),
                                    usuario.getNome(),
                                    usuario.getUsername(),
                                    usuario.getBio(),
                                    usuario.getFotoPerfil()
                            );

                    return ResponseEntity.ok(perfil);
                })
                .orElse(
                        ResponseEntity.notFound().build()
                );
    }


    // =====================================================
    // ATUALIZAR PERFIL
    // =====================================================

    @PutMapping("/{id}/perfil")
    public ResponseEntity<?> atualizarPerfil(
            @PathVariable Long id,
            @RequestBody Usuario dadosPerfil) {

        Usuario usuario =
                usuarioRepository.findById(id)
                        .orElse(null);

        if (usuario == null) {
            return ResponseEntity
                    .notFound()
                    .build();
        }


        // =============================================
        // VALIDAR USERNAME
        // =============================================

        String novoUsername =
                dadosPerfil.getUsername();

        if (novoUsername == null ||
                novoUsername.trim().isEmpty()) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            "Username é obrigatório."
                    );
        }

        novoUsername =
                novoUsername.trim();


        // =============================================
        // VERIFICAR SE USERNAME MUDOU
        // =============================================

        String usernameAntigo =
                usuario.getUsername();

        boolean usernameMudou =
                !novoUsername.equals(usernameAntigo);


        // =============================================
        // VERIFICAR DUPLICIDADE
        // =============================================

        if (usernameMudou &&
                usuarioRepository.existsByUsername(
                        novoUsername
                )) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            "Username já está em uso."
                    );
        }


        try {

            // =========================================
            // SE O USERNAME MUDOU E EXISTE FOTO
            // =========================================

            if (usernameMudou &&
                    usuario.getFotoPerfil() != null &&
                    !usuario.getFotoPerfil().isBlank()) {

                String fotoPerfil =
                        usuario.getFotoPerfil();

                /*
                 * fotoPerfil normalmente será:
                 *
                 * /google/drive/image/FILE_ID
                 *
                 * Então pegamos somente o ID.
                 */

                String prefixo =
                        "/google/drive/image/";

                if (fotoPerfil.startsWith(prefixo)) {

                    String fileId =
                            fotoPerfil.substring(
                                    prefixo.length()
                            );

                    if (!fileId.isBlank()) {

                        googleDriveService
                                .renomearFotoPerfil(
                                        fileId,
                                        usuario.getIdUsuario(),
                                        novoUsername
                                );
                    }
                }
            }


            // =========================================
            // ATUALIZAR DADOS
            // =========================================

            usuario.setNome(
                    dadosPerfil.getNome()
            );

            usuario.setUsername(
                    novoUsername
            );

            usuario.setBio(
                    dadosPerfil.getBio()
            );


            Usuario atualizado =
                    usuarioRepository.save(usuario);


            // =========================================
            // RETORNAR PERFIL
            // =========================================

            UsuarioPerfilDTO perfil =
                    new UsuarioPerfilDTO(
                            atualizado.getIdUsuario(),
                            atualizado.getNome(),
                            atualizado.getUsername(),
                            atualizado.getBio(),
                            atualizado.getFotoPerfil()
                    );

            return ResponseEntity.ok(perfil);

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "error",
                                    "Erro ao atualizar perfil: "
                                            + e.getMessage()
                            )
                    );
        }
    }


    // =====================================================
    // LOGIN
    // =====================================================

    @PostMapping("/login")
    public ResponseEntity<UsuarioPerfilDTO> login(
            @RequestBody Map<String, String> dados) {

        String email =
                dados.get("email");

        String senha =
                dados.get("senha");

        Usuario usuario =
                usuarioService.login(
                        email,
                        senha
                );

        if (usuario == null) {

            return ResponseEntity
                    .status(401)
                    .build();
        }

        UsuarioPerfilDTO perfil =
                new UsuarioPerfilDTO(
                        usuario.getIdUsuario(),
                        usuario.getNome(),
                        usuario.getUsername(),
                        usuario.getBio(),
                        usuario.getFotoPerfil()
                );

        return ResponseEntity.ok(perfil);
    }


    // =====================================================
    // TROCAR FOTO DE PERFIL
    // =====================================================

    @PostMapping("/{id}/foto")
    public ResponseEntity<?> atualizarFotoPerfil(
            @PathVariable Long id,
            @RequestParam("foto") MultipartFile foto) {

        Usuario usuario =
                usuarioRepository.findById(id)
                        .orElse(null);

        if (usuario == null) {

            return ResponseEntity
                    .notFound()
                    .build();
        }


        if (foto.isEmpty()) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            "Selecione uma imagem."
                    );
        }


        String tipo =
                foto.getContentType();

        if (tipo == null ||
                !tipo.startsWith("image/")) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            "O arquivo precisa ser uma imagem."
                    );
        }


        try {

            // =========================================
            // ENVIA PARA O DRIVE
            // =========================================

            String fileId =
                    googleDriveService.salvarFotoPerfil(
                            foto,
                            usuario.getIdUsuario(),
                            usuario.getUsername()
                    );


            // =========================================
            // URL DA IMAGEM
            // =========================================

            String urlFoto =
                    "/google/drive/image/"
                            + fileId;


            // =========================================
            // SALVA NO BANCO
            // =========================================

            usuario.setFotoPerfil(
                    urlFoto
            );

            usuarioRepository.save(usuario);


            // =========================================
            // RETORNA PERFIL
            // =========================================

            UsuarioPerfilDTO perfil =
                    new UsuarioPerfilDTO(
                            usuario.getIdUsuario(),
                            usuario.getNome(),
                            usuario.getUsername(),
                            usuario.getBio(),
                            usuario.getFotoPerfil()
                    );

            return ResponseEntity.ok(perfil);

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "error",
                                    e.getMessage()
                            )
                    );
        }
    }
}