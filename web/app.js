// app.js

import { ApiService } from './api_service.js';

class AppController {
    constructor() {
        this.usuariosMap = {};
        this.comentariosPorPost = {};
        this.posts = [];
        this.modoCadastro = false;
    }

    async inicializar() {
        this.atualizarCabecalho();
        await this.carregarDados();
    }

    atualizarCabecalho() {
        const container = document.getElementById('header-buttons');
        if (ApiService.getUsuarioLogado()) {
            container.innerHTML = `
                <button class="btn-outline" onclick="app.fazerLogout()">Sair</button>
                <button onclick="app.abrirModal('post-modal')">Novo Post</button>
            `;
        } else {
            container.innerHTML = `<button onclick="app.abrirModal('auth-modal')">Entrar</button>`;
        }
    }

    abrirModal(id) { document.getElementById(id).style.display = 'flex'; }
    fecharModal(id) { document.getElementById(id).style.display = 'none'; }

    alternarAuth() {
        this.modoCadastro = !this.modoCadastro;
        document.getElementById('auth-title').innerText = this.modoCadastro ? 'Criar Conta' : 'Entrar';
        document.getElementById('auth-nome').style.display = this.modoCadastro ? 'block' : 'none';
        document.getElementById('auth-toggle-btn').innerText = this.modoCadastro ? 'Já tem conta? Entrar' : 'Não tem conta? Criar conta';
    }

    async processarAuth() {
        const emailOuNome = document.getElementById('auth-email').value.trim();
        const senha = document.getElementById('auth-senha').value.trim();
        const nome = document.getElementById('auth-nome').value.trim();

        if (!emailOuNome || !senha) return alert("Preencha o usuário/email e a senha!");

        try {
            if (this.modoCadastro) {
                if (!nome) return alert("Preencha seu nome completo!");
                const res = await ApiService.criarUsuario(nome, emailOuNome, senha);
                if(res.ok) {
                    const novoUsuario = await res.json();
                    ApiService.salvarSessao(novoUsuario);
                    this.posLogin();
                } else {
                    const erro = await res.text();
                    alert("Erro ao criar conta: " + erro);
                }
            } else {
                // LÓGICA REAL DE LOGIN: Busca o usuário e checa a senha
                const lista = await ApiService.listarUsuarios();
                const userEncontrado = lista.find(u => 
                    (u.nome === emailOuNome || u.email === emailOuNome) && u.senha === senha
                );
                
                if (userEncontrado) {
                    ApiService.salvarSessao(userEncontrado);
                    this.posLogin();
                } else {
                    alert("Credenciais incorretas! Verifique se a senha e o nome estão certos.");
                }
            }
        } catch (e) {
            console.error(e);
            alert("Erro ao conectar com o banco de dados.");
        }
    }

    posLogin() {
        this.fecharModal('auth-modal');
        document.getElementById('auth-senha').value = ''; // Limpa a senha
        this.atualizarCabecalho();
        this.renderizarFeed();
    }

    fazerLogout() {
        ApiService.fazerLogout();
        this.atualizarCabecalho();
        this.renderizarFeed();
    }

    async enviarPost() {
        const idLogado = ApiService.getIdUsuarioLogado();
        if (!idLogado) return alert("Sua sessão expirou, faça login novamente!");
        
        const titulo = document.getElementById('post-titulo').value.trim();
        const conteudo = document.getElementById('post-conteudo').value.trim();
        
        if (!titulo || !conteudo) return alert("Preencha o título e o conteúdo!");

        try {
            const res = await ApiService.criarPost(titulo, conteudo, idLogado);
            if (res.ok) {
                this.fecharModal('post-modal');
                document.getElementById('post-titulo').value = '';
                document.getElementById('post-conteudo').value = '';
                await this.carregarDados();
            } else {
                const erro = await res.text();
                alert(`O servidor recusou o post. Erro: ${erro}`);
            }
        } catch(e) {
            console.error(e);
            alert("Erro fatal ao tentar enviar o post.");
        }
    }

    async enviarComentario(idPost) {
        const idLogado = ApiService.getIdUsuarioLogado();
        if (!idLogado) return alert("Faça login para comentar!");
        
        const input = document.getElementById(`input-comment-${idPost}`);
        const conteudo = input.value.trim();
        if (!conteudo) return;

        try {
            const res = await ApiService.criarComentario(conteudo, idLogado, idPost);
            if (res.ok) {
                input.value = ''; 
                await this.carregarDados();
            } else {
                const erro = await res.text();
                alert(`O servidor recusou o comentário. Erro: ${erro}`);
            }
        } catch(e) {
            console.error(e);
            alert("Erro fatal ao tentar enviar o comentário.");
        }
    }

    async carregarDados() {
        try {
            const listaUsuarios = await ApiService.listarUsuarios();
            this.usuariosMap = {};
            listaUsuarios.forEach(u => {
                let id = u.idUsuario || u.id_usuario || u.id;
                this.usuariosMap[id] = u.nome;
            });

            const listaComentarios = await ApiService.listarComentarios();
            this.comentariosPorPost = {};
            listaComentarios.forEach(c => {
                let idPost = c.idPost || c.id_post;
                if (!this.comentariosPorPost[idPost]) this.comentariosPorPost[idPost] = [];
                this.comentariosPorPost[idPost].push(c);
            });

            const listaPosts = await ApiService.listarPosts();
            this.posts = listaPosts.reverse();

            this.renderizarFeed();
        } catch (erro) {
            document.getElementById('feed-container').innerHTML = 
                `<div class="loader" style="color: red;">Erro ao conectar com o servidor (Spring Boot).</div>`;
        }
    }

    renderizarFeed() {
        const container = document.getElementById('feed-container');
        container.innerHTML = '';

        if (this.posts.length === 0) {
            container.innerHTML = '<div class="loader">Nenhum post encontrado.</div>';
            return;
        }

        this.posts.forEach(post => {
            let idUsuarioPost = post.idUsuario || post.id_usuario;
            let idPost = post.idPost || post.id;
            let nomeAutor = this.usuariosMap[idUsuarioPost] || 'Desconhecido';
            let inicial = nomeAutor.charAt(0).toUpperCase();
            
            let comentariosDestePost = this.comentariosPorPost[idPost] || [];
            let previews = comentariosDestePost.slice(0, 3);

            let comentariosHTML = '';
            previews.forEach(c => {
                let idUsuarioComentario = c.idUsuario || c.id_usuario;
                let nomeComentarista = this.usuariosMap[idUsuarioComentario] || 'Desconhecido';
                comentariosHTML += `<div class="comment-preview"><span>${nomeComentarista}</span> ${c.conteudo}</div>`;
            });

            let inputComentarioHTML = '';
            if (ApiService.getIdUsuarioLogado()) {
                inputComentarioHTML = `
                    <div class="comment-input-container">
                        <input type="text" id="input-comment-${idPost}" placeholder="Adicione um comentário...">
                        <button onclick="app.enviarComentario(${idPost})">Enviar</button>
                    </div>
                `;
            }

            const postDiv = document.createElement('div');
            postDiv.className = 'post';
            postDiv.innerHTML = `
                <div class="avatar">${inicial}</div>
                <div class="post-content">
                    <div class="post-header">${nomeAutor}</div>
                    <div class="post-title">${post.titulo}</div>
                    <div class="post-body">${post.conteudo}</div>
                    <div class="post-actions">
                        <i class="material-icons">favorite_border</i>
                        <i class="material-icons">chat_bubble_outline</i>
                    </div>
                    ${comentariosHTML ? `<div style="margin-bottom: 12px;">${comentariosHTML}</div>` : ''}
                    ${inputComentarioHTML}
                </div>
            `;
            container.appendChild(postDiv);
        });
    }
}

window.app = new AppController();
window.app.inicializar();