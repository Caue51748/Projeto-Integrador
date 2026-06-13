// app.js

import { ApiService } from './api_service.js';

class AppController {
    constructor() {
        this.listaUsuariosCompleta = [];
        this.usuariosMap = {};
        this.comentariosPorPost = {};
        this.posts = [];
        this.modoCadastro = false;
    }

    async inicializar() {
        this.atualizarCabecalho();
        await this.carregarDados();
        await this.carregarComunidades();
    }

    // --- NAVEGAÇÃO DE ABAS ---
    mudarAba(nomeAba) {
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
        
        document.getElementById(`view-${nomeAba}`).classList.add('active');
        document.getElementById(`tab-${nomeAba}`).classList.add('active');

        if(nomeAba === 'busca') this.renderizarUsuarios(this.listaUsuariosCompleta);
    }

    // --- CABEÇALHO E MODAIS ---
    atualizarCabecalho() {
        const container = document.getElementById('header-buttons');
        if (ApiService.getUsuarioLogado()) {
            container.innerHTML = `
                <button class="btn-outline" onclick="app.fazerLogout()">Sair</button>
                <button onclick="app.abrirModal('post-modal')">Publicar</button>
            `;
        } else {
            container.innerHTML = `<button onclick="app.abrirModal('auth-modal')">Entrar</button>`;
        }
    }

    abrirModal(id) { document.getElementById(id).style.display = 'flex'; }
    fecharModal(id) { document.getElementById(id).style.display = 'none'; }

    alternarAuth() {
        this.modoCadastro = !this.modoCadastro;
        document.getElementById('auth-title').innerText = this.modoCadastro ? 'Criar Conta' : 'Bem-vindo de volta';
        document.getElementById('auth-nome').style.display = this.modoCadastro ? 'block' : 'none';
        document.getElementById('auth-toggle-btn').innerText = this.modoCadastro ? 'Já tem conta? Entrar' : 'Não tem conta? Inscreva-se';
    }

    // --- AUTENTICAÇÃO ---
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
                    alert("Erro ao criar conta: " + await res.text());
                }
            } else {
                const lista = await ApiService.listarUsuarios();
                const userEncontrado = lista.find(u => (u.nome === emailOuNome || u.email === emailOuNome) && u.senha === senha);
                
                if (userEncontrado) {
                    ApiService.salvarSessao(userEncontrado);
                    this.posLogin();
                } else alert("Credenciais incorretas!");
            }
        } catch (e) { alert("Erro ao conectar com o banco de dados."); }
    }

    posLogin() {
        this.fecharModal('auth-modal');
        document.getElementById('auth-senha').value = '';
        this.atualizarCabecalho();
        this.renderizarFeed();
    }

    fazerLogout() {
        ApiService.fazerLogout();
        this.atualizarCabecalho();
        this.renderizarFeed();
    }

    // --- DADOS DO FEED E BUSCA ---
    async carregarDados() {
        try {
            this.listaUsuariosCompleta = await ApiService.listarUsuarios();
            this.usuariosMap = {};
            this.listaUsuariosCompleta.forEach(u => {
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
            document.getElementById('feed-container').innerHTML = `<div class="loader">Erro de conexão com servidor.</div>`;
        }
    }

    // --- ABA BUSCA ---
    filtrarUsuarios() {
        const texto = document.getElementById('search-input').value.toLowerCase();
        const filtrados = this.listaUsuariosCompleta.filter(u => u.nome.toLowerCase().includes(texto));
        this.renderizarUsuarios(filtrados);
    }

    renderizarUsuarios(lista) {
        const container = document.getElementById('users-container');
        container.innerHTML = '';
        if (lista.length === 0) {
            container.innerHTML = '<div class="loader">Nenhum usuário encontrado.</div>';
            return;
        }
        lista.forEach(u => {
            const inicial = u.nome.charAt(0).toUpperCase();
            const div = document.createElement('div');
            div.className = 'user-row';
            div.innerHTML = `
                <div class="avatar">${inicial}</div>
                <div class="user-info">
                    <span class="user-name">${u.nome}</span>
                    <span class="user-handle">@${u.nome.toLowerCase().replace(/\s/g, '')}</span>
                </div>
            `;
            container.appendChild(div);
        });
    }

    // --- ABA COMUNIDADES ---
    async carregarComunidades() {
        const container = document.getElementById('comunidades-container');
        const comunidades = await ApiService.listarComunidades();
        
        container.innerHTML = '';
        comunidades.forEach(c => {
            const div = document.createElement('div');
            div.className = 'card community-card';
            div.innerHTML = `
                <div class="community-info">
                    <h3>${c.nome}</h3>
                    <p>${c.descricao}</p>
                </div>
                <button class="btn-join">Participar</button>
            `;
            container.appendChild(div);
        });
    }

    async criarComunidade() {
        if (!ApiService.getUsuarioLogado()) return alert("Faça login!");
        const nome = document.getElementById('comunidade-nome').value.trim();
        const desc = document.getElementById('comunidade-desc').value.trim();
        if(!nome) return alert("Preencha o nome!");

        const res = await ApiService.criarComunidadeAPI(nome, desc);
        if(res.ok) {
            this.fecharModal('comunidade-modal');
            await this.carregarComunidades();
        } else {
            alert("Atenção: " + (await res.text() || "Crie o backend de Comunidades no Spring Boot primeiro."));
        }
    }

    // --- POSTS E COMENTÁRIOS ---
    async enviarPost() {
        const idLogado = ApiService.getIdUsuarioLogado();
        if (!idLogado) return alert("Sua sessão expirou!");
        const titulo = document.getElementById('post-titulo').value.trim();
        const conteudo = document.getElementById('post-conteudo').value.trim();
        if (!titulo || !conteudo) return alert("Preencha tudo!");

        const res = await ApiService.criarPost(titulo, conteudo, idLogado);
        if (res.ok) {
            this.fecharModal('post-modal');
            document.getElementById('post-titulo').value = '';
            document.getElementById('post-conteudo').value = '';
            await this.carregarDados();
        } else alert(`Erro: ${await res.text()}`);
    }

    async enviarComentario(idPost) {
        const idLogado = ApiService.getIdUsuarioLogado();
        if (!idLogado) return alert("Faça login para comentar!");
        const input = document.getElementById(`input-comment-${idPost}`);
        const conteudo = input.value.trim();
        if (!conteudo) return;

        const res = await ApiService.criarComentario(conteudo, idLogado, idPost);
        if (res.ok) {
            input.value = ''; 
            await this.carregarDados();
        } else alert(`Erro: ${await res.text()}`);
    }

    renderizarFeed() {
        const container = document.getElementById('feed-container');
        container.innerHTML = '';
        if (this.posts.length === 0) return container.innerHTML = '<div class="loader">Nenhum post encontrado.</div>';

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
                        <input type="text" id="input-comment-${idPost}" placeholder="Escreva um comentário...">
                        <button onclick="app.enviarComentario(${idPost})">Enviar</button>
                    </div>
                `;
            }

            const postDiv = document.createElement('div');
            postDiv.className = 'card post';
            postDiv.innerHTML = `
                <div class="post-header-area">
                    <div class="avatar">${inicial}</div>
                    <div class="post-header">${nomeAutor}</div>
                </div>
                <div class="post-title">${post.titulo}</div>
                <div class="post-body">${post.conteudo}</div>
                <div class="post-actions">
                    <i class="material-icons">favorite_border</i>
                    <i class="material-icons">chat_bubble_outline</i>
                    <i class="material-icons">share</i>
                </div>
                ${comentariosHTML ? `<div>${comentariosHTML}</div>` : ''}
                ${inputComentarioHTML}
            `;
            container.appendChild(postDiv);
        });
    }
}

window.app = new AppController();
window.app.inicializar();