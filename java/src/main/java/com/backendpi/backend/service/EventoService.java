package com.backendpi.backend.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.backendpi.backend.model.Evento;
import com.backendpi.backend.repository.EventoRepository;

@Service
public class EventoService {

    private final EventoRepository eventoRepository;

    public EventoService(EventoRepository eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    public List<Evento> listarTodos() {
        return eventoRepository.findAll();
    }

    public Optional<Evento> buscarPorId(Long id) {
        return eventoRepository.findById(id);
    }

    public Evento salvar(Evento evento) {

        if (evento.getCriadorId() == null) {
            throw new RuntimeException("O evento precisa ter um criador");
        }

        if (evento.getLimiteParticipantes() != null
                && evento.getLimiteParticipantes() <= 0) {
            throw new RuntimeException(
                    "O limite de participantes deve ser maior que zero"
            );
        }

        evento.setStatus("AGENDADO");

        if (evento.getExigeCheckin() == null) {
            evento.setExigeCheckin(false);
        }

        return eventoRepository.save(evento);
    }

    public void deletar(Long idEvento, Long idUsuario) {

        Evento evento = eventoRepository.findById(idEvento)
                .orElseThrow(() -> new RuntimeException("Evento não encontrado"));

        if (!evento.getCriadorId().equals(idUsuario)) {
            throw new RuntimeException(
                    "Usuário sem permissão para excluir este evento"
            );
        }

        eventoRepository.delete(evento);
    }

    public Evento atualizar(
            Long idEvento,
            Long idUsuario,
            Evento novo) {

        Evento evento = eventoRepository.findById(idEvento)
                .orElseThrow(() -> new RuntimeException("Evento não encontrado"));

        if (!evento.getCriadorId().equals(idUsuario)) {
            throw new RuntimeException(
                    "Usuário sem permissão para editar este evento"
            );
        }

        if (novo.getLimiteParticipantes() != null
                && novo.getLimiteParticipantes() <= 0) {
            throw new RuntimeException(
                    "O limite de participantes deve ser maior que zero"
            );
        }

        evento.setTitulo(novo.getTitulo());
        evento.setDescricao(novo.getDescricao());
        evento.setDataEvento(novo.getDataEvento());
        evento.setHorarioInicio(novo.getHorarioInicio());
        evento.setHorarioFim(novo.getHorarioFim());
        evento.setEncerramentoInscricoes(novo.getEncerramentoInscricoes());
        evento.setLocalEvento(novo.getLocalEvento());
        evento.setComunidadeId(novo.getComunidadeId());
        evento.setLimiteParticipantes(novo.getLimiteParticipantes());
        evento.setExigeCheckin(novo.getExigeCheckin());

        return eventoRepository.save(evento);
    }

    public Evento cancelar(Long idEvento, Long idUsuario) {

        Evento evento = eventoRepository.findById(idEvento)
                .orElseThrow(() -> new RuntimeException("Evento não encontrado"));

        if (!evento.getCriadorId().equals(idUsuario)) {
            throw new RuntimeException(
                    "Usuário sem permissão para cancelar este evento"
            );
        }

        evento.setStatus("CANCELADO");

        return eventoRepository.save(evento);
    }

    public Page<Evento> buscarComFiltros(
            String texto,
            String status,
            Long comunidadeId,
            LocalDate dataInicio,
            LocalDate dataFim,
            int pagina,
            int tamanho) {

        if (texto != null && texto.trim().isEmpty()) {
            texto = null;
        }

        if (status != null && status.trim().isEmpty()) {
            status = null;
        }

        Pageable pageable = PageRequest.of(
                pagina,
                tamanho,
                Sort.by("dataEvento")
                        .ascending()
                        .and(Sort.by("horarioInicio").ascending())
        );

        return eventoRepository.buscarComFiltros(
                texto,
                status,
                comunidadeId,
                dataInicio,
                dataFim,
                pageable
        );
    }
}
