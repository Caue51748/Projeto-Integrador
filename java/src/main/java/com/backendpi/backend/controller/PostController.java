package com.backendpi.backend.controller;

import com.backendpi.backend.model.Post;
import com.backendpi.backend.service.PostService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @DeleteMapping("/{id}")
    public void deletar(@PathVariable Long id) {
        service.deletar(id);
    }
}