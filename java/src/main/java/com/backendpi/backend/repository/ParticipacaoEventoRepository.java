package com.backendpi.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.backendpi.backend.model.ParticipacaoEvento;

public interface ParticipacaoEventoRepository
        extends JpaRepository<ParticipacaoEvento, Long> {

    boolean existsByUsuarioIdAndEventoId(
            Long usuarioId,
            Long eventoId
    );

    List<ParticipacaoEvento> findByEventoId(Long eventoId);

    List<ParticipacaoEvento> findByUsuarioId(Long usuarioId);

    void deleteByUsuarioIdAndEventoId(
            Long usuarioId,
            Long eventoId
    );

    long countByEventoId(Long eventoId);

    Optional<ParticipacaoEvento> findByTokenIngresso(String tokenIngresso);
}