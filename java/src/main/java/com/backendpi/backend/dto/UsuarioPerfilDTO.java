package com.backendpi.backend.dto;

import java.util.Collections;
import java.util.List;

public class UsuarioPerfilDTO {

    private Long idUsuario;
    private String nome;
    private String username;
    private String bio;
    private String fotoPerfil;
    private List<String> interesses;
    private String token;

    // Construtor completo com token
    public UsuarioPerfilDTO(
            Long idUsuario,
            String nome,
            String username,
            String bio,
            String fotoPerfil,
            List<String> interesses,
            String token) {

        this.idUsuario = idUsuario;
        this.nome = nome;
        this.username = username;
        this.bio = bio;
        this.fotoPerfil = fotoPerfil;
        this.interesses = interesses;
        this.token = token;
    }

    // Construtor completo sem token (mantém compatibilidade)
    public UsuarioPerfilDTO(
            Long idUsuario,
            String nome,
            String username,
            String bio,
            String fotoPerfil,
            List<String> interesses) {

        this(
                idUsuario,
                nome,
                username,
                bio,
                fotoPerfil,
                interesses,
                null
        );
    }

    // Construtor antigo, com 5 parâmetros
    public UsuarioPerfilDTO(
            Long idUsuario,
            String nome,
            String username,
            String bio,
            String fotoPerfil) {

        this(
                idUsuario,
                nome,
                username,
                bio,
                fotoPerfil,
                Collections.emptyList(),
                null
        );
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

    public List<String> getInteresses() {
        return interesses;
    }

    public void setInteresses(List<String> interesses) {
        this.interesses = interesses;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
