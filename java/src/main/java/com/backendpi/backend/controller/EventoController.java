package com.backendpi.backend.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.backendpi.backend.dto.EventoResumoDTO;
import com.backendpi.backend.model.Evento;
import com.backendpi.backend.service.EventoService;

@RestController
@RequestMapping("/api/eventos")
@CrossOrigin(origins = {"http://127.0.0.1:5500", "http://localhost:5500"})
public class EventoController {

    private final EventoService eventoService;

    public EventoController(EventoService eventoService) {
        this.eventoService = eventoService;
    }

    @GetMapping
    public List<Evento> listarTodos() {
        return eventoService.listarTodos();
    }

    @GetMapping("/usuario/{idUsuario}")
    public List<Evento> listarPorCriador(
            @PathVariable Long idUsuario) {

        return eventoService.listarPorCriador(idUsuario);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Evento> buscarPorId(@PathVariable Long id) {
        return eventoService.buscarPorId(id)
                .map(evento -> ResponseEntity.ok().body(evento))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Evento criar(@RequestBody Evento evento) {
        return eventoService.salvar(evento);
    }

    @DeleteMapping("/{idEvento}/usuario/{idUsuario}")
    public ResponseEntity<Void> deletar(
            @PathVariable Long idEvento,
            @PathVariable Long idUsuario) {

        eventoService.deletar(idEvento, idUsuario);

        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{idEvento}/usuario/{idUsuario}")
    public Evento atualizar(
            @PathVariable Long idEvento,
            @PathVariable Long idUsuario,
            @RequestBody Evento novo) {

        return eventoService.atualizar(
                idEvento,
                idUsuario,
                novo
        );
    }

    @PutMapping("/{idEvento}/cancelar/usuario/{idUsuario}")
    public Evento cancelar(
            @PathVariable Long idEvento,
            @PathVariable Long idUsuario) {

        return eventoService.cancelar(idEvento, idUsuario);
    }

    @GetMapping("/buscar")
    public Page<EventoResumoDTO> buscarComFiltros(
            @RequestParam(required = false) String texto,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long comunidadeId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataInicio,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataFim,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {

        return eventoService.buscarComFiltros(
                texto,
                status,
                comunidadeId,
                dataInicio,
                dataFim,
                page,
                size
        );
    }
}
