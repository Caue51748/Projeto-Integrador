package com.backendpi.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "imagens_post")
public class ImagensPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "id_post")
    private Long idPost;

    @Column(name = "url")
    private String url;

    public ImagensPost() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getIdPost() {
        return idPost;
    }

    public void setIdPost(Long idPost) {
        this.idPost = idPost;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}