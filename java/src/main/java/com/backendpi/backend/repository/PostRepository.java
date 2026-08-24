package com.backendpi.backend.repository;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.backendpi.backend.model.Post;

public interface PostRepository extends JpaRepository<Post, Long> {

    List<Post> findByIdComunidade(Long idComunidade);
    List<Post> findByIdUsuarioOrderByDataPostagemDesc(Long idUsuario);
}
