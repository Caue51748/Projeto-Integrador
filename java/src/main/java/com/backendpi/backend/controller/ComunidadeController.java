package com.backendpi.backend.controller;

import java.util.List;
import java.util.Map;

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
public Comunidade criar(@RequestBody Map<String, Object> dados) {

    System.out.println("=================================");
    System.out.println(dados);
    System.out.println("=================================");

    return service.criar(dados);
}

   @PutMapping("/{idComunidade}/usuario/{idUsuario}")
public Comunidade atualizar(
        @PathVariable Long idComunidade,
        @PathVariable Long idUsuario,
        @RequestBody Comunidade nova) {

    return service.atualizar(idComunidade, idUsuario, nova);
}

@DeleteMapping("/{idComunidade}/usuario/{idUsuario}")
public void deletar(
        @PathVariable Long idComunidade,
        @PathVariable Long idUsuario) {

    service.deletar(idComunidade, idUsuario);
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

    @DeleteMapping("/{idComunidade}/membros/{idMembro}/usuario/{idSolicitante}")
public void removerMembro(
        @PathVariable Long idComunidade,
        @PathVariable Long idMembro,
        @PathVariable Long idSolicitante) {

    service.removerMembro(
            idComunidade,
            idMembro,
            idSolicitante
    );
}
}
