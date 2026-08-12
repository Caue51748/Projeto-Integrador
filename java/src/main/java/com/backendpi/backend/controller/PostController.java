package com.backendpi.backend.controller;

import java.util.List;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.backendpi.backend.model.Post;
import com.backendpi.backend.service.PostService;

@RestController
@RequestMapping("/posts")
@CrossOrigin(origins = "*")
public class PostController {

    private final PostService service;

    public PostController(PostService service) {
        this.service = service;
    }

    @GetMapping
    public List<Post> listar() {
        return service.listar();
    }

    @PostMapping
    public Post salvar(@RequestBody Post post) {
        return service.salvar(post);
    }

    @GetMapping("/{id}")
    public Post buscarPorId(@PathVariable Long id) {
        return service.buscarPorId(id);
    }

    @DeleteMapping("/{idPost}/usuario/{idUsuario}")
    public void deletar(
            @PathVariable Long idPost,
            @PathVariable Long idUsuario) {

        service.deletar(idPost, idUsuario);
    }
}
