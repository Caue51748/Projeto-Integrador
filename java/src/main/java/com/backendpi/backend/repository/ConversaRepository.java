package com.backendpi.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.backendpi.backend.model.Conversa;

public interface ConversaRepository
        extends JpaRepository<Conversa, Long> {
}
