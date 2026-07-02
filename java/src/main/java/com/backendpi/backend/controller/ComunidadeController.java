package com.backendpi.backend.controller;

import java.util.List;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.backendpi.backend.model.Comunidade;
import com.backendpi.backend.service.ComunidadeService;

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

    @DeleteMapping("/{idComunidade}/participar/{idUsuario}")
    public void sairDaComunidade(@PathVariable Long idComunidade,
            @PathVariable Long idUsuario) {
        service.removerMembro(idComunidade, idUsuario);
    }
}
