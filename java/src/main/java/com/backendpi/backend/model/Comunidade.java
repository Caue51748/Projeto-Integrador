package com.backendpi.backend.model;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "comunidades")
public class Comunidade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_comunidade")
    private Long id;

    private String nome;
    private String descricao;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "criador_id")
    private Usuario criador;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "usuario_comunidade",
            joinColumns = @JoinColumn(
                    name = "comunidade_id",
                    referencedColumnName = "id_comunidade"
            ),
            inverseJoinColumns = @JoinColumn(
                    name = "usuario_id",
                    referencedColumnName = "id_usuario"
            )
    )
    private List<Usuario> membros = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public List<Usuario> getMembros() {
        return membros;
    }

    public void setMembros(List<Usuario> membros) {
        this.membros = membros;
    }

    public Usuario getCriador() {
        return criador;
    }

    public void setCriador(Usuario criador) {
        this.criador = criador;
    }
}
