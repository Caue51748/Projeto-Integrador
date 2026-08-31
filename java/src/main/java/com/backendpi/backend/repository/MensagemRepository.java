package com.backendpi.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.backendpi.backend.model.Mensagem;

public interface MensagemRepository
        extends JpaRepository<Mensagem, Long> {
}
