package com.backendpi.backend.dto;

public class UsuarioPerfilDTO {

    private Long idUsuario;
    private String nome;
    private String username;
    private String bio;
    private String fotoPerfil;

    public UsuarioPerfilDTO(
            Long idUsuario,
            String nome,
            String username,
            String bio,
            String fotoPerfil) {

        this.idUsuario = idUsuario;
        this.nome = nome;
        this.username = username;
        this.bio = bio;
        this.fotoPerfil = fotoPerfil;
    }

    public Long getIdUsuario() {
        return idUsuario;
    }

    public String getNome() {
        return nome;
    }

    public String getBio() {
        return bio;
    }

    public String getUsername() {
        return username;
    }

    public String getFotoPerfil() {
        return fotoPerfil;
    }
}
