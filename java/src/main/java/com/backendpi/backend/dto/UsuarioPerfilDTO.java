package com.backendpi.backend.dto;

public class UsuarioPerfilDTO {

    private Long idUsuario;
    private String nome;
    private String username;
    private String bio;

    public UsuarioPerfilDTO(
            Long idUsuario,
            String nome,
            String username,
            String bio) {

        this.idUsuario = idUsuario;
        this.nome = nome;
        this.username = username;
        this.bio = bio;
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
}
