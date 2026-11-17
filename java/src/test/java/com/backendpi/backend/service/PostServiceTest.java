package com.backendpi.backend.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import com.backendpi.backend.model.Post;
import com.backendpi.backend.model.UsuarioSeguido;
import com.backendpi.backend.repository.ComentarioRepository;
import com.backendpi.backend.repository.ComunidadeRepository;
import com.backendpi.backend.repository.PostRepository;
import com.backendpi.backend.repository.UsuarioSeguidoRepository;
import com.backendpi.backend.security.AuthenticatedUserContext;

@ExtendWith(MockitoExtension.class)
class PostServiceTest {

    @Mock
    private PostRepository postRepository;

    @Mock
    private ComentarioRepository comentarioRepository;

    @Mock
    private ComunidadeRepository comunidadeRepository;

    @Mock
    private ImagensPostService imagensPostService;

    @Mock
    private UsuarioSeguidoRepository usuarioSeguidoRepository;

    @InjectMocks
    private PostService postService;

    @AfterEach
    void limparContextoAutenticado() {
        AuthenticatedUserContext.clear();
    }

    @Test
    void deveListarPostsApenasDasContasSeguidasPeloUsuarioAutenticado() {
        AuthenticatedUserContext.setUserId(7L);
        PageRequest pageable = PageRequest.of(0, 10);
        UsuarioSeguido seguido = new UsuarioSeguido();
        seguido.setSeguidoId(12L);
        Post post = new Post();
        Page<Post> posts = new PageImpl<>(List.of(post), pageable, 1);
        when(usuarioSeguidoRepository.findBySeguidorIdOrderBySeguidoEmDesc(7L))
                .thenReturn(List.of(seguido));
        when(postRepository.findByIdUsuarioInOrderByIdPostDesc(List.of(12L), pageable))
                .thenReturn(posts);

        assertSame(posts, postService.listarPostsSeguidos(pageable));
    }

    @Test
    void deveRetornarPaginaVaziaQuandoUsuarioNaoSegueNinguem() {
        AuthenticatedUserContext.setUserId(7L);
        PageRequest pageable = PageRequest.of(0, 10);
        when(usuarioSeguidoRepository.findBySeguidorIdOrderBySeguidoEmDesc(7L))
                .thenReturn(List.of());

        Page<Post> resultado = postService.listarPostsSeguidos(pageable);

        assertTrue(resultado.isEmpty());
        assertEquals(pageable, resultado.getPageable());
        verify(postRepository, never())
                .findByIdUsuarioInOrderByIdPostDesc(List.of(), pageable);
    }
}
