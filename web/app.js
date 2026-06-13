// app.js
import { ApiService } from './api_service.js';

class AppController {
    constructor() {
        this.listaUsuariosCompleta = [];
        this.usuariosMap = {};
        this.comunidadesMap = {}; // Guarda id -> nome da comunidade
        this.comentariosPorPost = {};
        this.posts = [];
        this.modoCadastro = false;
        
        // Estado da comunidade ativa (estilo Subreddit)
        this.comunidadeAtivaId = null; 
    }

    async inicializar() {
        this.atualizarMenuLateral();
        await this.carregarDadosGlobais();
    }

    // --- MENU E NAVEGAÇÃO ---
    mudarAba(nomeAba) {
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));
        
        document.getElementById(`view-${nomeAba}`).classList.add('active');
        if(document.getElementById(`tab-${nomeAba}`)) {
            document.getElementById(`tab-${nomeAba}`).classList.add('active');
        }

        this.comunidadeAtivaId = null; // Reseta se sair da tela de subreddit

        if(nomeAba === 'busca') this.renderizarUsuarios(this.listaUsuariosCompleta);
        if(nomeAba === 'feed') this.renderizarFeedGeral();
        if(nomeAba === 'comunidades') this.carregarComunidades();
    }

    atualizarMenuLateral() {
        const container = document.getElementById('header-buttons');
        const user = ApiService.getUsuarioLogado();
        if (user) {
            container.innerHTML = `
                <div style="font-size:14px; margin-bottom:8px; color:#cbd5e1;">Logado como: <b>${user.nome}</b></div>
                <button class="btn-primary" style="width:100%; background:#ef4444;" onclick="app.fazerLogout()">Sair do Sistema</button>
            `;
        } else {
            container.innerHTML = `<button class="btn-primary" style="width:100%;" onclick="app.abrirModal('auth-modal')">Fazer Login</button>`;
        }
    }

    abrirModal(id) { document.getElementById(id).style.display = 'flex'; }
    fecharModal(id) { document.getElementById(id).style.display = 'none'; }

    abrirModalPost() {
        if (!ApiService.getUsuarioLogado()) return alert("Faça login primeiro!");
        const tituloEl = document.getElementById('modal-post-title');
        
        if (this.comunidadeAtivaId) {
            tituloEl.innerText = `Postar em: ${this.comunidadesMap[this.comunidadeAtivaId]}`;
        } else {
            tituloEl.innerText = "Nova Publicação Global";
        }
        this.abrirModal('post-modal');
    }

    // --- AUTH --- (Igual ao anterior, resumido para focar na lógica)
    alternarAuth() {
        this.modoCadastro = !this.modoCadastro;
        document.getElementById('auth-title').innerText = this.modoCadastro ? 'Nova Conta' : 'Acesso ao Painel';
        document.getElementById('auth-nome').style.display = this.modoCadastro ? 'block' : 'none';
        document.getElementById('auth-toggle-btn').innerText = this.modoCadastro ? 'Já tem conta? Entrar' : 'Criar nova conta';
    }

    async processarAuth() {
        const e = document.getElementById('auth-email').value.trim();
        const s = document.getElementById('auth-senha').value.trim();
        const n = document.getElementById('auth-nome').value.trim();

        try {
            if (this.modoCadastro) {
                const res = await ApiService.criarUsuario(n, e, s);
                if(res.ok) { ApiService.salvarSessao(await res.json()); this.posLogin(); }
            } else {
                const lista = await ApiService.listarUsuarios();
                const user = lista.find(u => (u.nome === e || u.email === e) && u.senha === s);
                if (user) { ApiService.salvarSessao(user); this.posLogin(); } else alert("Credenciais inválidas");
            }
        } catch (err) { alert("Erro de conexão."); }
    }

    posLogin() { this.fecharModal('auth-modal'); this.atualizarMenuLateral(); this.carregarDadosGlobais(); }
    fazerLogout() { ApiService.fazerLogout(); this.atualizarMenuLateral(); this.mudarAba('feed'); }

    // --- CARREGAMENTO GLOBAL ---
    async carregarDadosGlobais() {
        try {
            this.listaUsuariosCompleta = await ApiService.listarUsuarios();
            this.listaUsuariosCompleta.forEach(u => this.usuariosMap[u.idUsuario || u.id] = u.nome);

            // Tenta carregar comunidades para mapear os nomes (Para mostrar no Feed Geral)
            try {
                const coms = await ApiService.listarComunidades();
                coms.forEach(c => this.comunidadesMap[c.idComunidade || c.id] = c.nome);
            } catch(e) { console.warn("API de Comunidades não encontrada ainda."); }

            const listaComentarios = await ApiService.listarComentarios();
            this.comentariosPorPost = {};
            listaComentarios.forEach(c => {
                let idPost = c.idPost || c.id_post;
                if (!this.comentariosPorPost[idPost]) this.comentariosPorPost[idPost] = [];
                this.comentariosPorPost[idPost].push(c);
            });

            this.posts = (await ApiService.listarPosts()).reverse();
            
            // Se estiver dentro de uma comunidade recarrega ela, se não, feed geral
            if (this.comunidadeAtivaId) this.renderizarSubreddit(this.comunidadeAtivaId);
            else this.renderizarFeedGeral();

        } catch (e) {
            console.error(e);
            document.getElementById('feed-container').innerHTML = `Erro de conexão com servidor.`;
        }
    }

    // --- LÓGICA DE SUBREDDIT E COMUNIDADES ---
    async carregarComunidades() {
        const container = document.getElementById('comunidades-container');
        try {
            const comunidades = await ApiService.listarComunidades();
            container.innerHTML = '';
            comunidades.forEach(c => {
                const idCom = c.idComunidade || c.id;
                const div = document.createElement('div');
                div.className = 'list-item';
                div.innerHTML = `
                    <div class="list-item-info">
                        <h3 onclick="app.entrarSubreddit(${idCom}, '${c.nome}', '${c.descricao}')">${c.nome}</h3>
                        <p>${c.descricao}</p>
                    </div>
                    <button class="btn-primary" onclick="app.entrarSubreddit(${idCom}, '${c.nome}', '${c.descricao}')">Acessar</button>
                `;
                container.appendChild(div);
            });
        } catch (e) {
            container.innerHTML = "<p style='padding:16px;'>Crie a tabela Comunidade no Java primeiro!</p>";
        }
    }

    async criarComunidade() {
        if (!ApiService.getUsuarioLogado()) return alert("Faça login!");
        const nome = document.getElementById('comunidade-nome').value.trim();
        const desc = document.getElementById('comunidade-desc').value.trim();
        const res = await ApiService.criarComunidadeAPI(nome, desc);
        if(res.ok) { this.fecharModal('comunidade-modal'); this.carregarComunidades(); }
        else alert("Crie o backend de Comunidades no Spring Boot.");
    }

    entrarSubreddit(id, nome, desc) {
        this.comunidadeAtivaId = id;
        document.getElementById('sub-titulo').innerText = nome;
        document.getElementById('sub-desc').innerText = desc;
        
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.getElementById('view-subreddit').classList.add('active');
        
        this.renderizarSubreddit(id);
    }

   async participarComunidade() {
        const idLogado = ApiService.getIdUsuarioLogado();
        if (!idLogado) return alert("Faça login primeiro!");
        
        const btn = document.getElementById('btn-participar');
        
        try {
            // Chama a nova rota que criamos no Java
            await fetch(`http://localhost:8080/comunidades/${this.comunidadeAtivaId}/participar/${idLogado}`, {
                method: 'POST'
            });

            btn.innerText = "Participando";
            btn.style.background = "#059669"; // Fica Verde
            
        } catch (e) {
            alert("Erro ao entrar na comunidade.");
        }
    }
    
    renderizarSubreddit(idComunidade) {
        // Filtra os posts para mostrar apenas os desta comunidade
        const postsDestaComunidade = this.posts.filter(p => p.idComunidade == idComunidade || p.id_comunidade == idComunidade);
        this.montarCardsPosts(postsDestaComunidade, 'subreddit-feed-container', false);
    }

    renderizarFeedGeral() {
        // Mostra todos
        this.montarCardsPosts(this.posts, 'feed-container', true);
    }

    // --- FUNÇÕES DE POSTS/COMENTARIOS REUTILIZÁVEIS ---
    async enviarPost() {
        const idLogado = ApiService.getIdUsuarioLogado();
        const titulo = document.getElementById('post-titulo').value.trim();
        const conteudo = document.getElementById('post-conteudo').value.trim();
        
        // Se this.comunidadeAtivaId existir, envia o post vinculado à comunidade
        const res = await ApiService.criarPost(titulo, conteudo, idLogado, this.comunidadeAtivaId);
        if (res.ok) {
            this.fecharModal('post-modal');
            document.getElementById('post-titulo').value = '';
            document.getElementById('post-conteudo').value = '';
            await this.carregarDadosGlobais();
        } else alert(`O Java recusou o post. Adicionou a coluna id_comunidade na tabela?`);
    }

    async enviarComentario(idPost) {
        const idLogado = ApiService.getIdUsuarioLogado();
        if (!idLogado) return alert("Logue primeiro!");
        const input = document.getElementById(`input-comment-${idPost}`);
        const res = await ApiService.criarComentario(input.value.trim(), idLogado, idPost);
        if (res.ok) await this.carregarDadosGlobais();
    }

    montarCardsPosts(listaPosts, idContainer, mostrarTagComunidade) {
        const container = document.getElementById(idContainer);
        container.innerHTML = '';
        if (listaPosts.length === 0) return container.innerHTML = '<p style="color:var(--text-muted)">Nenhuma publicação ainda.</p>';

        listaPosts.forEach(post => {
            let idAutor = post.idUsuario || post.id_usuario;
            let idPost = post.idPost || post.id;
            let idComunidade = post.idComunidade || post.id_comunidade;

            let nomeAutor = this.usuariosMap[idAutor] || 'Desconhecido';
            let nomeComunidade = this.comunidadesMap[idComunidade];
            
            let htmlComentarios = (this.comentariosPorPost[idPost] || []).map(c => 
                `<div class="comment-preview"><span>${this.usuariosMap[c.idUsuario || c.id_usuario] || 'User'}:</span>${c.conteudo}</div>`
            ).join('');

            const div = document.createElement('div');
            div.className = 'card';
            div.innerHTML = `
                <div class="post-header-area">
                    <div class="avatar">${nomeAutor.charAt(0).toUpperCase()}</div>
                    <div>
                        <span class="post-author">${nomeAutor}</span>
                        ${mostrarTagComunidade && nomeComunidade ? `<span class="post-community-tag">em c/${nomeComunidade}</span>` : ''}
                    </div>
                </div>
                <div class="post-title">${post.titulo}</div>
                <div class="post-body">${post.conteudo}</div>
                ${htmlComentarios}
                ${ApiService.getIdUsuarioLogado() ? `
                    <div class="comment-input-container">
                        <input type="text" id="input-comment-${idPost}" placeholder="Comentar...">
                        <button onclick="app.enviarComentario(${idPost})">Enviar</button>
                    </div>` : ''}
            `;
            container.appendChild(div);
        });
    }

    // --- ABA BUSCA ---
    filtrarUsuarios() {
        const txt = document.getElementById('search-input').value.toLowerCase();
        this.renderizarUsuarios(this.listaUsuariosCompleta.filter(u => u.nome.toLowerCase().includes(txt)));
    }

    renderizarUsuarios(lista) {
        const container = document.getElementById('users-container');
        container.innerHTML = '';
        lista.forEach(u => {
            const div = document.createElement('div');
            div.className = 'list-item';
            div.innerHTML = `
                <div style="display:flex; align-items:center;">
                    <div class="avatar" style="width:32px; height:32px; margin-right:12px;">${u.nome.charAt(0).toUpperCase()}</div>
                    <span style="font-weight:600;">${u.nome}</span>
                </div>
            `;
            container.appendChild(div);
        });
    }
}

window.app = new AppController();
window.app.inicializar();