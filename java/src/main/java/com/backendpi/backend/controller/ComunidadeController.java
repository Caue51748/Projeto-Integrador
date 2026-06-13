package com.backendpi.backend.controller;

import com.backendpi.backend.model.Comunidade;
import com.backendpi.backend.service.ComunidadeService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/comunidades")
@CrossOrigin(origins = "*") // Muito importante para não dar erro de conexão com o JS!
public class ComunidadeController {

    private final ComunidadeService service;

    public ComunidadeController(ComunidadeService service) {
        this.service = service;
    }

    @GetMapping
    public List<Comunidade> listar() {
        return service.listar();
    }

    @PostMapping
    public Comunidade criar(@RequestBody Comunidade comunidade) {
        return service.criar(comunidade);
    }

    @PutMapping("/{id}")
    public Comunidade atualizar(@PathVariable Long id, @RequestBody Comunidade nova) {
        return service.atualizar(id, nova);
    }

    @DeleteMapping("/{id}")
    public void deletar(@PathVariable Long id) {
        service.deletar(id);
    }

    // NOVA ROTA PARA VINCULAR USUARIO E COMUNIDADE
    @PostMapping("/{idComunidade}/participar/{idUsuario}")
    public void participarDaComunidade(@PathVariable Long idComunidade, @PathVariable Long idUsuario) {
        service.adicionarMembro(idComunidade, idUsuario);
    }
}