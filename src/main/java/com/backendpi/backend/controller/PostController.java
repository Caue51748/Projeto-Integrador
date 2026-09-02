package com.backendpi.backend.controller;

import com.backendpi.backend.model.Post;
import com.backendpi.backend.service.PostService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/posts")
public class PostController {

    private final PostService service;

    public PostController(PostService service) {
        this.service = service;
    }

    @GetMapping
    public List<Post> listar() {
        return service.listar();
    }

    @PostMapping("criar/{id}")
    public Post criar(@RequestBody Post post) {
        return service.salvar(post);
    }

    @GetMapping("buscar/{id}")
    public Post buscar(@PathVariable Long id) {
        return service.buscarPorId(id);
    }

    @DeleteMapping("/deletar/{id}")
    public void deletar(@PathVariable Long id) {
        service.deletar(id);
    }
}