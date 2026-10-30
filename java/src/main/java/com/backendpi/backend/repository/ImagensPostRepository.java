package com.backendpi.backend.repository;

import com.backendpi.backend.model.ImagensPost;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ImagensPostRepository extends JpaRepository<ImagensPost, Long> {
	List<ImagensPost> findByIdPostOrderByIdAsc(Long idPost);
	long countByIdPost(Long idPost);
}