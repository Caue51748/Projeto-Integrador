package com.backendpi.backend.model;

import java.time.LocalDate;
import java.time.LocalTime;

import com.fasterxml.jackson.annotation.JsonFormat;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "eventos")
public class Evento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_evento")
    private Long id;

    @Column(nullable = false, length = 150)
    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "data_evento", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate dataEvento;

    @Column(nullable = false)
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime horario;

    @Column(name = "local_evento", nullable = false)
    private String localEvento;

    @Column(name = "comunidade_id")
    private Long comunidadeId;

    @Column(name = "criador_id", nullable = false)
    private Long criadorId;

    @Column(name = "limite_participantes")
    private Integer limiteParticipantes;

    @Column(nullable = false)
    private String status = "AGENDADO";

    @Column(name = "exige_checkin", nullable = false)
    private Boolean exigeCheckin = false;

    public Long getId() {
        return id;
    }

    public String getTitulo() {
        return titulo;
    }

    public String getDescricao() {
        return descricao;
    }

    public LocalDate getDataEvento() {
        return dataEvento;
    }

    public LocalTime getHorario() {
        return horario;
    }

    public String getLocalEvento() {
        return localEvento;
    }

    public Long getComunidadeId() {
        return comunidadeId;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public void setDataEvento(LocalDate dataEvento) {
        this.dataEvento = dataEvento;
    }

    public void setHorario(LocalTime horario) {
        this.horario = horario;
    }

    public void setLocalEvento(String localEvento) {
        this.localEvento = localEvento;
    }

    public void setComunidadeId(Long comunidadeId) {
        this.comunidadeId = comunidadeId;
    }

    public Long getCriadorId() {
        return criadorId;
    }

    public void setCriadorId(Long criadorId) {
        this.criadorId = criadorId;
    }

    public Integer getLimiteParticipantes() {
        return limiteParticipantes;
    }

    public void setLimiteParticipantes(Integer limiteParticipantes) {
        this.limiteParticipantes = limiteParticipantes;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getExigeCheckin() {
        return exigeCheckin;
    }

    public void setExigeCheckin(Boolean exigeCheckin) {
        this.exigeCheckin = exigeCheckin;
    }

}
