import { ApiService } from './api_service.js';

class AppController {
    constructor() {
        this.listaUsuariosCompleta = [];
        this.usuariosMap = {};
        this.comunidadesMap = {}; // Guarda id -> nome da comunidade
        this.carregarFiltroComunidadesEventos();
        this.listaComunidades = [];
        this.comentariosPorPost = {};
        this.posts = [];
        this.modoCadastro = false;
        this.telaBoasVindasVisivel = true;
        this.comunidadeAtivaId = null;
        this.usuarioParticipaDaComunidade = false;
        this.comunidadeEditando = null;
        this.eventoEditando = null;
        this.listaEventos = [];
        this.html5QrCode = null;
        this.paginaEventos = 0;
        this.totalPaginasEventos = 0;
        this.tamanhoPaginaEventos = 12;
        this.filtrosEventos = {
            texto: null,
            status: null,
            comunidadeId: null,
            dataInicio: null,
            dataFim: null
        };
        this.timerBuscaEventos = null;
    }

    async inicializar() {
        this.atualizarMenuLateral();
        this.mostrarTelaBoasVindas();
    }

    // --- MENU E NAVEGAÇÃO ---
    mostrarTelaBoasVindas() {
        document.getElementById('welcome-screen').classList.add('active');
        document.getElementById('app-shell').classList.remove('active');
        this.telaBoasVindasVisivel = true;
    }

    esconderTelaBoasVindas() {
        document.getElementById('welcome-screen').classList.remove('active');
        document.getElementById('app-shell').classList.add('active');
        this.telaBoasVindasVisivel = false;
    }

    selecionarOpcao(opcao) {
        this.esconderTelaBoasVindas();

        if (opcao === 'login') {
            this.modoCadastro = false;
            this.atualizarAuthUI();
            this.abrirModal('auth-modal');
        } else if (opcao === 'cadastro') {
            this.modoCadastro = true;
            this.atualizarAuthUI();
            this.abrirModal('auth-modal');
        } else {
            this.atualizarMenuLateral();
            this.carregarDadosGlobais();
        }
    }

    atualizarAuthUI() {
        const nomeInput = document.getElementById('auth-nome');
        document.getElementById('auth-title').innerText = this.modoCadastro ? 'Nova Conta' : 'Acesso ao Painel';
        nomeInput.style.display = this.modoCadastro ? 'block' : 'none';
        if (!this.modoCadastro) nomeInput.value = '';
        document.getElementById('auth-toggle-btn').innerText = this.modoCadastro ? 'Já tem conta? Entrar' : 'Criar nova conta';
    }
    mudarAba(nomeAba) {
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));

        document.getElementById(`view-${nomeAba}`).classList.add('active');
        if (document.getElementById(`tab-${nomeAba}`)) {
            document.getElementById(`tab-${nomeAba}`).classList.add('active');
        }

        this.comunidadeAtivaId = null; // Reseta se sair da tela de subreddit

        if (nomeAba === 'busca') this.renderizarUsuarios(this.listaUsuariosCompleta);
        if (nomeAba === 'feed') this.renderizarFeedGeral();
        if (nomeAba === 'comunidades') this.carregarComunidades();
        if (nomeAba === 'eventos') this.carregarEventos();
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
        if (!ApiService.getUsuarioLogado()) {
            return alert("Faça login primeiro.");
        }

        // Se estiver dentro de uma comunidade, precisa ser membro
        if (this.comunidadeAtivaId && !this.usuarioParticipaDaComunidade) {
            return alert("Você precisa entrar na comunidade antes de publicar.");
        }

        const tituloEl = document.getElementById('modal-post-title');

        if (this.comunidadeAtivaId) {
            tituloEl.innerText =
                `Postar em: ${this.comunidadesMap[this.comunidadeAtivaId]}`;
        } else {
            tituloEl.innerText = "Nova Publicação Global";
        }

        this.abrirModal('post-modal');
    }

    // --- AUTH --- (Igual ao anterior, resumido para focar na lógica)
    alternarAuth() {
        this.modoCadastro = !this.modoCadastro;
        this.atualizarAuthUI();
    }

    async processarAuth() {
        const e = document.getElementById('auth-email').value.trim();
        const s = document.getElementById('auth-senha').value.trim();
        const n = document.getElementById('auth-nome').value.trim();

        try {
            if (this.modoCadastro) {
                const res = await ApiService.criarUsuario(n, e, s);
                if (res.ok) { ApiService.salvarSessao(await res.json()); this.posLogin(); }
            } else {
                const lista = await ApiService.listarUsuarios();
                const user = lista.find(u => (u.nome === e || u.email === e) && u.senha === s);
                if (user) { ApiService.salvarSessao(user); this.posLogin(); } else alert("Credenciais inválidas");
            }
        } catch (err) { alert("Erro de conexão."); }
    }

    posLogin() {
        this.fecharModal('auth-modal');
        this.esconderTelaBoasVindas();
        this.atualizarMenuLateral();
        this.carregarDadosGlobais();
    }

    fazerLogout() {
        ApiService.fazerLogout();
        this.atualizarMenuLateral();
        this.mudarAba('feed');
        this.mostrarTelaBoasVindas();
    }

    // --- CARREGAMENTO GLOBAL ---
    async carregarDadosGlobais() {
        try {
            this.listaUsuariosCompleta = await ApiService.listarUsuarios();
            this.listaUsuariosCompleta.forEach(u => this.usuariosMap[u.idUsuario || u.id] = u.nome);

            // Tenta carregar comunidades para mapear os nomes (Para mostrar no Feed Geral)
            try {
                const coms = await ApiService.listarComunidades();

                this.listaComunidades = coms;

                coms.forEach(c =>
                    this.comunidadesMap[c.idComunidade || c.id] = c.nome
                );
                this.carregarFiltroComunidadesEventos();
            } catch (e) {
                console.warn("API de Comunidades não encontrada ainda.");
            }
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
            this.listaComunidades = comunidades;
            container.innerHTML = '';
            comunidades.forEach(c => {
                const idCom = c.idComunidade || c.id;
                const div = document.createElement('div');
                div.className = 'list-item';

                const idUsuarioLogado = ApiService.getIdUsuarioLogado();

                const ehAdministrador =
                    c.criador &&
                    (c.criador.idUsuario || c.criador.id) == idUsuarioLogado;

                div.innerHTML = `
    <div class="list-item-info">
        <h3>${c.nome}</h3>
        <p>${c.descricao}</p>

        <small style="color:#6b7280;">
            Administrador: ${c.criador ? c.criador.nome : "Desconhecido"}
        </small>

        <br>

        <small style="color:#6b7280;">
            ${c.membros ? c.membros.length : 0} membro(s)
        </small>
    </div>

    <button class="btn-primary"
        onclick="app.entrarSubreddit(${idCom}, '${c.nome}', '${c.descricao}')">
        Acessar
    </button>

     ${ehAdministrador ? `
            <button class="btn-primary"
                style="background:#2563eb;"
                onclick="app.gerenciarComunidade(${idCom})">
                Gerenciar
            </button>
        ` : ""}
      </div>
    
 `;

                container.appendChild(div);
            });
        } catch (e) {
            container.innerHTML = "<p style='padding:16px;'>Crie a tabela Comunidade no Java primeiro!</p>";
        }
    }

    async criarComunidade() {
        if (!ApiService.getUsuarioLogado()) return alert("Faça login primeiro.");

        const nome = document.getElementById('comunidade-nome').value.trim();
        const desc = document.getElementById('comunidade-desc').value.trim();
        const criadorId = ApiService.getIdUsuarioLogado();

        const res = await ApiService.criarComunidadeAPI(nome, desc, criadorId);

        if (res.ok) {
            this.fecharModal('comunidade-modal');
            this.carregarComunidades();
        } else {
            alert("Não foi possível criar a comunidade.");
        }
    }

    entrarSubreddit(id, nome, desc) {

        const usuarioLogado = ApiService.getIdUsuarioLogado();
        const botao = document.getElementById("btn-participar");

        this.comunidadeAtivaId = id;

        const comunidade = this.listaComunidades.find(
            c => (c.idComunidade || c.id) == id
        );

        const idAdministrador =
            comunidade?.criador?.idUsuario || comunidade?.criador?.id;

        this.usuarioParticipaDaComunidade =
            comunidade &&
            comunidade.membros &&
            comunidade.membros.some(
                m => (m.idUsuario || m.id) == usuarioLogado
            );

        // Administrador não precisa de botão Entrar/Sair
        if (usuarioLogado == idAdministrador) {
            botao.style.display = "none";
        } else {
            botao.style.display = "block";

            if (this.usuarioParticipaDaComunidade) {
                botao.innerText = "Sair";
                botao.style.background = "#ef4444";
            } else {
                botao.innerText = "Entrar";
                botao.style.background = "#111827";
            }
        }

        // Estas linhas precisam ficar FORA do if/else
        // porque todo usuário deve conseguir acessar a comunidade.
        document.getElementById('sub-titulo').innerText = nome;
        document.getElementById('sub-desc').innerText = desc;

        document.querySelectorAll('.view-section')
            .forEach(el => el.classList.remove('active'));

        document.getElementById('view-subreddit')
            .classList.add('active');

        this.renderizarSubreddit(id);
    }

    async participarComunidade() {
        const idLogado = ApiService.getIdUsuarioLogado();

        if (!idLogado) {
            return alert("Faça login primeiro.");
        }

        const btn = document.getElementById('btn-participar');

        try {
            let resposta;

            // Se já participa, está tentando SAIR
            if (this.usuarioParticipaDaComunidade) {

                resposta = await ApiService.removerMembro(
                    this.comunidadeAtivaId,
                    idLogado,
                    idLogado
                );

            } else {

                // Se ainda não participa, está tentando ENTRAR
                resposta = await fetch(
                    `http://localhost:8080/comunidades/${this.comunidadeAtivaId}/participar/${idLogado}`,
                    {
                        method: "POST"
                    }
                );
            }

            if (!resposta.ok) {
                alert("Não foi possível realizar esta ação.");
                return;
            }

            this.usuarioParticipaDaComunidade =
                !this.usuarioParticipaDaComunidade;

            if (this.usuarioParticipaDaComunidade) {
                btn.innerText = "Sair";
                btn.style.background = "#ef4444";
            } else {
                btn.innerText = "Entrar";
                btn.style.background = "#111827";
            }

            await this.carregarComunidades();

        } catch (e) {
            console.error(e);
            alert("Erro ao atualizar participação na comunidade.");
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
        } else alert(`Não foi possível publicar o post.`);
    }

    async enviarComentario(idPost, botao) {
        const idLogado = ApiService.getIdUsuarioLogado();

        if (!idLogado) {
            return alert("Faça login primeiro!");
        }

        const input = botao.previousElementSibling;
        const conteudo = input.value.trim();

        if (!conteudo) {
            return alert("Digite um comentário antes de enviar.");
        }

        const res = await ApiService.criarComentario(
            conteudo,
            idLogado,
            idPost
        );

        if (res.ok) {
            await this.carregarDadosGlobais();
        } else {
            alert("Não foi possível enviar o comentário.");
        }
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

            const idUsuarioLogado = ApiService.getIdUsuarioLogado();

            const comunidade = (this.listaComunidades || []).find(
                c => (c.idComunidade || c.id) == idComunidade
            );

            const idAdministrador = comunidade?.criador?.idUsuario;

            const podeExcluir =
                idUsuarioLogado &&
                (
                    idUsuarioLogado == idAutor ||
                    idUsuarioLogado == idAdministrador
                );

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

${podeExcluir ? `
    <div style="margin-top: 10px;">
        <button
            class="btn-secondary"
            onclick="app.excluirPost(${idPost})">
            Excluir
        </button>
    </div>
` : ''}

${ApiService.getIdUsuarioLogado() ? `
                    <div class="comment-input-container">
                       <input type="text" placeholder="Comentar...">
<button onclick="app.enviarComentario(${idPost}, this)">Enviar</button>
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

    async carregarEventos() {

        const container = document.getElementById('eventos-container');
        if (!container) return;

        container.innerHTML = 'Carregando eventos...';

        try {
            const resultado = await ApiService.buscarEventos({
                ...this.filtrosEventos,
                page: this.paginaEventos,
                size: this.tamanhoPaginaEventos
            });

            const eventos = resultado.content;

            this.listaEventos = eventos;
            this.totalPaginasEventos = resultado.totalPages;

            container.innerHTML = '';

            if (eventos.length === 0) {
                container.innerHTML =
                    '<p style="color:var(--text-muted); padding:16px;">Nenhum evento agendado no momento.</p>';
                this.totalPaginasEventos = 0;
                this.atualizarPaginacaoEventos();
                return;
            }

            for (const evento of eventos) {

                const div = document.createElement('div');
                div.className = 'card';

                const status = evento.status || 'AGENDADO';
                const eventoCancelado = status === 'CANCELADO';


                div.style.borderLeft = eventoCancelado
                    ? '4px solid #ef4444'
                    : '4px solid #10b981';

                div.style.opacity = eventoCancelado ? '0.7' : '1';
                div.style.display = 'flex';
                div.style.flexDirection = 'column';
                div.style.justifyContent = 'space-between';

                const dataFormatada = evento.dataEvento
                    ? evento.dataEvento.split('-').reverse().join('/')
                    : '';

                const horarioInicioFormatado = evento.horarioInicio
                    ? evento.horarioInicio.substring(0, 5)
                    : '';

                const horarioFimFormatado = evento.horarioFim
                    ? evento.horarioFim.substring(0, 5)
                    : '';

                const nomeCriador =
                    this.usuariosMap[evento.criadorId] || 'Desconhecido';

                const nomeComunidade = evento.comunidadeId
                    ? this.comunidadesMap[evento.comunidadeId] || 'Desconhecida'
                    : null;

                const vagas = evento.limiteParticipantes
                    ? `${evento.limiteParticipantes} vagas`
                    : 'Sem limite de vagas';

                const usaCheckin = evento.exigeCheckin
                    ? 'Sim'
                    : 'Não';

                const idUsuarioLogado = ApiService.getIdUsuarioLogado();

                const ehCriador =
                    idUsuarioLogado &&
                    idUsuarioLogado == evento.criadorId;

                const participantes =
                    await ApiService.listarParticipantesEvento(evento.id);

                const quantidadeParticipantes = participantes.length;

                const usuarioParticipa =
                    idUsuarioLogado &&
                    participantes.some(
                        p => p.usuarioId == idUsuarioLogado
                    );

                const eventoLotado =
                    evento.limiteParticipantes !== null &&
                    quantidadeParticipantes >= evento.limiteParticipantes;

                div.innerHTML = `
    <div
        onclick="app.abrirDetalhesEvento(${evento.id})"
        style="cursor:pointer;"
    >
        <div style="
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            gap:12px;
        ">
            <div>
                <h3 style="margin:0 0 6px 0;">
                    ${evento.titulo}
                </h3>

                <div style="
                    font-size:13px;
                    color:var(--text-muted);
                ">
                    📅 ${dataFormatada}
                    • ⏰ ${horarioInicioFormatado} às ${horarioFimFormatado}
                </div>
            </div>

            <span style="
                font-size:12px;
                font-weight:600;
            ">
                ${status}
            </span>
        </div>

        <p style="
            color:var(--text-muted);
            font-size:14px;
            margin:12px 0;
            overflow:hidden;
            display:-webkit-box;
            -webkit-line-clamp:2;
            -webkit-box-orient:vertical;
        ">
            ${evento.descricao || 'Sem descrição informada.'}
        </p>

        <div style="
            font-size:13px;
            color:var(--text-muted);
            display:flex;
            flex-direction:column;
            gap:4px;
        ">
            <div>
                📍 ${evento.localEvento}
            </div>

            <div>
                👥 ${evento.limiteParticipantes
                        ? `${quantidadeParticipantes} de ${evento.limiteParticipantes}`
                        : `${quantidadeParticipantes} participante(s)`
                    }
            </div>

            <div>
                👤 ${nomeCriador}
            </div>
        </div>
    </div>
`;

                container.appendChild(div);
            }


        } catch (e) {
            console.error(e);

            container.innerHTML =
                "<p style='padding:16px; color:red;'>Erro ao conectar com a API de Eventos.</p>";
        }
        this.atualizarPaginacaoEventos();
    }

    async criarEvento() {

        const idUsuario = ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return alert("Faça login para organizar um evento!");
        }

        const titulo =
            document.getElementById('evento-titulo').value.trim();

        const descricao =
            document.getElementById('evento-desc').value.trim();

        const dataEvento =
            document.getElementById('evento-data').value;

        const horarioInicio =
            document.getElementById('evento-horario-inicio').value;

        const horarioFim =
            document.getElementById('evento-horario-fim').value;

        const encerramentoInscricoes =
            document.getElementById(
                'evento-encerramento-inscricoes'
            ).value;

        const localEvento =
            document.getElementById('evento-local').value.trim();

        const comunidadeValor =
            document.getElementById('evento-comunidade-id').value;

        const limiteValor =
            document.getElementById('evento-limite').value;

        const exigeCheckin =
            document.getElementById('evento-checkin').checked;

        if (
            !titulo ||
            !dataEvento ||
            !horarioInicio ||
            !horarioFim ||
            !localEvento
        ) {
            return alert(
                "Preencha título, data, horário de início, horário de fim e local."
            );
        }

        const novoEvento = {
            titulo,
            descricao,
            dataEvento,

            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",

            encerramentoInscricoes:
                encerramentoInscricoes
                    ? encerramentoInscricoes + ":00"
                    : null,

            localEvento,

            criadorId: parseInt(idUsuario),

            comunidadeId:
                comunidadeValor
                    ? parseInt(comunidadeValor)
                    : null,

            limiteParticipantes:
                limiteValor
                    ? parseInt(limiteValor)
                    : null,

            exigeCheckin
        };
        try {

            const res =
                await ApiService.criarEventoAPI(novoEvento);

            if (res.ok) {

                this.fecharModal('evento-modal');

                document.getElementById('evento-titulo').value = '';
                document.getElementById('evento-desc').value = '';
                document.getElementById('evento-data').value = '';
                document.getElementById('evento-horario-inicio').value = '';
                document.getElementById('evento-horario-fim').value = '';
                document.getElementById('evento-encerramento-inscricoes').value = '';
                document.getElementById('evento-local').value = '';
                document.getElementById('evento-comunidade-id').value = '';
                document.getElementById('evento-limite').value = '';
                document.getElementById('evento-checkin').checked = false;

                await this.carregarEventos();

                alert("Evento publicado com sucesso!");

            } else {
                alert("Não foi possível criar o evento.");
            }

        } catch (error) {
            console.error(error);
            alert("Erro de conexão ao criar o evento.");
        }
    }

    gerenciarComunidade(idComunidade) {

        const comunidade = this.listaComunidades.find(
            c => (c.idComunidade || c.id) == idComunidade
        );

        if (!comunidade) return;

        this.comunidadeEditando = comunidade;

        document.getElementById("editar-comunidade-nome").value =
            comunidade.nome;

        document.getElementById("editar-comunidade-desc").value =
            comunidade.descricao;

        this.abrirModal("gerenciar-comunidade-modal");
    }

    async salvarEdicaoComunidade() {

        const nome = document.getElementById("editar-comunidade-nome").value.trim();
        const descricao = document.getElementById("editar-comunidade-desc").value.trim();

        const idComunidade =
            this.comunidadeEditando.idComunidade || this.comunidadeEditando.id;

        const idUsuario = ApiService.getIdUsuarioLogado();

        const resposta = await ApiService.atualizarComunidade(
            idComunidade,
            idUsuario,
            nome,
            descricao
        );

        if (resposta.ok) {
            this.fecharModal("gerenciar-comunidade-modal");

            await this.carregarComunidades();

            if (this.comunidadeAtivaId == idComunidade) {
                this.entrarSubreddit(
                    idComunidade,
                    nome,
                    descricao
                );
            }

        } else {
            alert("Você não tem permissão para editar esta comunidade.");
        }
    }



    async excluirComunidade() {

        if (!confirm("Tem certeza que deseja excluir esta comunidade?")) {
            return;
        }

        const idComunidade =
            this.comunidadeEditando.idComunidade || this.comunidadeEditando.id;

        const idUsuario = ApiService.getIdUsuarioLogado();

        const resposta = await ApiService.excluirComunidade(
            idComunidade,
            idUsuario
        );

        if (resposta.ok) {
            this.fecharModal("gerenciar-comunidade-modal");

            await this.carregarComunidades();

            alert("Comunidade excluída com sucesso!");
        } else {
            alert("Você não tem permissão para excluir esta comunidade.");
        }
    }



    abrirGerenciarMembros() {

        const lista = document.getElementById("lista-membros-comunidade");

        lista.innerHTML = "";

        this.comunidadeEditando.membros.forEach(membro => {

            const criadorId = this.comunidadeEditando.criador.idUsuario;

            lista.innerHTML += `
    <div class="membro-item">
        <span>${membro.nome}</span>

        ${membro.idUsuario !== criadorId
                    ? `<button class="btn-danger"
                        onclick="app.removerMembro(${membro.idUsuario})">
                        Remover
                   </button>`
                    : `<span style="color: gray;">Administrador</span>`
                }
    </div>
`;

        });

        this.abrirModal("gerenciar-membros-modal");
    }

    async removerMembro(idUsuario) {

        if (!confirm("Deseja remover este membro da comunidade?")) {
            return;
        }

        const idComunidade =
            this.comunidadeEditando.idComunidade || this.comunidadeEditando.id;

        const idSolicitante = ApiService.getIdUsuarioLogado();

        const resposta = await ApiService.removerMembro(
            idComunidade,
            idUsuario,
            idSolicitante
        );

        if (resposta.ok) {
            alert("Membro removido com sucesso!");

            await this.carregarComunidades();

            this.comunidadeEditando = this.listaComunidades.find(
                c => (c.idComunidade || c.id) == idComunidade
            );

            this.abrirGerenciarMembros();
        } else {
            alert("Você não tem permissão para remover este membro.");
        }
    }

    async excluirPost(idPost) {

        if (!confirm("Deseja realmente excluir esta publicação?")) {
            return;
        }

        const idUsuario = ApiService.getIdUsuarioLogado();
        const resposta = await ApiService.deletarPost(idPost, idUsuario);

        if (resposta.ok) {
            await this.carregarDadosGlobais();

            if (this.comunidadeAtivaId) {
                this.renderizarSubreddit(this.comunidadeAtivaId);
            }
        } else {
            alert("Você não tem permissão para excluir esta publicaçãox.");
        }
    }

    gerenciarEvento(idEvento) {

        const evento = this.listaEventos.find(
            e => (e.idEvento || e.id) == idEvento
        );

        if (!evento) return;

        this.eventoEditando = evento;

        document.getElementById('editar-evento-titulo').value =
            evento.titulo || '';

        document.getElementById('editar-evento-descricao').value =
            evento.descricao || '';

        document.getElementById('editar-evento-data').value =
            evento.dataEvento || '';

        document.getElementById('editar-evento-horario-inicio').value =
            evento.horarioInicio
                ? evento.horarioInicio.substring(0, 5)
                : '';

        document.getElementById('editar-evento-horario-fim').value =
            evento.horarioFim
                ? evento.horarioFim.substring(0, 5)
                : '';

        document.getElementById('editar-evento-local').value =
            evento.localEvento || '';

        document.getElementById('editar-evento-comunidade').value =
            evento.comunidadeId || '';

        document.getElementById('editar-evento-limite').value =
            evento.limiteParticipantes || '';

        document.getElementById('editar-evento-checkin').checked =
            evento.exigeCheckin === true;

        this.abrirModal('gerenciar-evento-modal');
    }

    async salvarEdicaoEvento() {

        if (!this.eventoEditando) {
            return;
        }

        const idUsuario = ApiService.getIdUsuarioLogado();

        const idEvento =
            this.eventoEditando.idEvento || this.eventoEditando.id;

        const titulo =
            document.getElementById('editar-evento-titulo').value.trim();

        const descricao =
            document.getElementById('editar-evento-descricao').value.trim();

        const dataEvento =
            document.getElementById('editar-evento-data').value;

        const horarioInicio =
            document.getElementById('editar-evento-horario-inicio').value;

        const horarioFim =
            document.getElementById('editar-evento-horario-fim').value;

        const localEvento =
            document.getElementById('editar-evento-local').value.trim();

        const comunidadeValor =
            document.getElementById('editar-evento-comunidade').value;

        const limiteValor =
            document.getElementById('editar-evento-limite').value;

        const exigeCheckin =
            document.getElementById('editar-evento-checkin').checked;

        if (!titulo || !dataEvento || !horario || !localEvento) {
            return alert(
                "Preencha título, data, horário e local do evento."
            );
        }

        const eventoAtualizado = {
            titulo,
            descricao,
            dataEvento,
            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",
            localEvento,

            comunidadeId:
                comunidadeValor
                    ? parseInt(comunidadeValor)
                    : null,

            limiteParticipantes:
                limiteValor
                    ? parseInt(limiteValor)
                    : null,

            exigeCheckin
        };

        const resposta = await ApiService.atualizarEvento(
            idEvento,
            idUsuario,
            eventoAtualizado
        );

        if (resposta.ok) {
            this.fecharModal('gerenciar-evento-modal');

            this.eventoEditando = null;

            await this.carregarEventos();

            alert("Evento atualizado com sucesso!");
        } else {
            alert("Não foi possível atualizar o evento.");
        }
    }

    async excluirEvento() {

        if (!this.eventoEditando) {
            return;
        }

        if (!confirm("Tem certeza que deseja excluir este evento?")) {
            return;
        }

        const idUsuario = ApiService.getIdUsuarioLogado();

        const idEvento =
            this.eventoEditando.idEvento || this.eventoEditando.id;

        const resposta = await ApiService.excluirEvento(
            idEvento,
            idUsuario
        );

        if (resposta.ok) {
            this.fecharModal('gerenciar-evento-modal');

            this.eventoEditando = null;

            await this.carregarEventos();

            alert("Evento excluído com sucesso!");
        } else {
            alert("Não foi possível excluir o evento.");
        }
    }

    async cancelarEvento() {

        if (!this.eventoEditando) {
            return;
        }

        if (!confirm("Tem certeza que deseja cancelar este evento?")) {
            return;
        }

        const idEvento =
            this.eventoEditando.idEvento || this.eventoEditando.id;

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        const resposta =
            await ApiService.cancelarEvento(
                idEvento,
                idUsuario
            );

        if (resposta.ok) {
            this.fecharModal('gerenciar-evento-modal');

            this.eventoEditando = null;

            await this.carregarEventos();

            alert("Evento cancelado com sucesso!");
        } else {
            alert("Não foi possível cancelar o evento.");
        }
    }

    async participarEvento(idEvento) {

        const idUsuario = ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return alert("Faça login para participar do evento.");
        }

        const resposta = await ApiService.participarEvento(
            idEvento,
            idUsuario
        );

        if (resposta.ok) {
            await this.carregarEventos();
        } else {
            alert("Não foi possível participar do evento.");
        }
    }

    async sairDoEvento(idEvento) {

        const idUsuario = ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return;
        }

        if (!confirm("Deseja cancelar sua participação neste evento?")) {
            return;
        }

        const resposta = await ApiService.sairEvento(
            idEvento,
            idUsuario
        );

        if (resposta.ok) {
            await this.carregarEventos();
        } else {
            alert("Não foi possível cancelar sua participação.");
        }
    }

    async abrirParticipantesEvento() {

        if (!this.eventoEditando) {
            return;
        }

        const idEvento =
            this.eventoEditando.idEvento || this.eventoEditando.id;

        const participacoes =
            await ApiService.listarParticipantesEvento(idEvento);

        const lista =
            document.getElementById('lista-participantes-evento');

        lista.innerHTML = '';

        if (participacoes.length === 0) {
            lista.innerHTML =
                '<p style="color:var(--text-muted);">Nenhum participante inscrito.</p>';

            this.abrirModal('participantes-evento-modal');
            return;
        }

        participacoes.forEach(participacao => {

            const idUsuario = participacao.usuarioId;

            const nomeUsuario =
                this.usuariosMap[idUsuario] || 'Usuário desconhecido';

            const status =
                participacao.status || 'INSCRITO';

            const presente =
                status === 'PRESENTE';

            lista.innerHTML += `
        <div class="membro-item">
            <div>
                <span>${nomeUsuario}</span>

                <span style="
                    margin-left:8px;
                    font-size:12px;
                    font-weight:600;
                ">
                    ${presente ? 'PRESENTE ✓' : 'INSCRITO'}
                </span>
            </div>

            <button
                class="btn-danger"
                onclick="app.removerParticipanteEvento(${idUsuario})">
                Remover
            </button>
        </div>
    `;
        });

        this.abrirModal('participantes-evento-modal');
    }

    async removerParticipanteEvento(idParticipante) {

        if (!this.eventoEditando) {
            return;
        }

        if (!confirm("Deseja remover este participante do evento?")) {
            return;
        }

        const idEvento =
            this.eventoEditando.idEvento || this.eventoEditando.id;

        const idSolicitante =
            ApiService.getIdUsuarioLogado();

        const resposta =
            await ApiService.removerParticipanteEvento(
                idEvento,
                idParticipante,
                idSolicitante
            );

        if (resposta.ok) {

            alert("Participante removido com sucesso!");

            await this.abrirParticipantesEvento();

            await this.carregarEventos();

        } else {
            alert("Não foi possível remover o participante.");
        }
    }

    abrirValidacaoIngresso() {

        if (!this.eventoEditando) {
            return;
        }

        document.getElementById('token-ingresso').value = '';

        this.abrirModal('validar-ingresso-modal');
    }

    async validarIngresso() {

        if (!this.eventoEditando) {
            return;
        }

        const token =
            document.getElementById('token-ingresso').value.trim();

        if (!token) {
            return alert("Digite o código do ingresso.");
        }

        const idEvento =
            this.eventoEditando.idEvento || this.eventoEditando.id;

        const idSolicitante =
            ApiService.getIdUsuarioLogado();

        const resposta =
            await ApiService.validarIngressoEvento(
                idEvento,
                idSolicitante,
                token
            );

        if (resposta.ok) {

            const participacao = await resposta.json();

            alert("Ingresso válido! Check-in realizado.");

            document.getElementById('token-ingresso').value = '';

            await this.abrirParticipantesEvento();

        } else {
            alert(
                "Ingresso inválido, já utilizado ou pertencente a outro evento."
            );
        }
    }
    async abrirLeitorQR() {

        const reader = document.getElementById('qr-reader');
        reader.style.display = 'block';

        if (this.html5QrCode) {
            try {
                await this.html5QrCode.stop();
            } catch (e) {
                // ignora se já estiver parado
            }
        }

        this.html5QrCode = new Html5Qrcode("qr-reader");

        try {
            const cameras = await Html5Qrcode.getCameras();

            if (!cameras || cameras.length === 0) {
                alert("Nenhuma câmera encontrada.");
                return;
            }

            await this.html5QrCode.start(
                cameras[0].id,
                {
                    fps: 10,
                    qrbox: {
                        width: 250,
                        height: 250
                    }
                },
                async (decodedText) => {

                    try {
                        await this.html5QrCode.stop();
                    } catch (e) {
                        console.error(e);
                    }

                    reader.style.display = 'none';

                    document.getElementById('token-ingresso').value =
                        decodedText;

                    await this.validarIngresso();
                }
            );

        } catch (erro) {
            console.error(erro);
            reader.style.display = 'none';

            alert("Não foi possível acessar a câmera.");
        }
    }

    async pararLeitorQR() {

        if (this.html5QrCode) {
            try {
                await this.html5QrCode.stop();
            } catch (erro) {
                console.error(erro);
            }

            this.html5QrCode = null;
        }

        document.getElementById('qr-reader').style.display = 'none';
    }

    atualizarPaginacaoEventos() {

        const info =
            document.getElementById('eventos-pagina-info');

        const btnAnterior =
            document.getElementById('btn-eventos-anterior');

        const btnProxima =
            document.getElementById('btn-eventos-proxima');

        if (!info || !btnAnterior || !btnProxima) {
            return;
        }

        const paginaAtual = this.paginaEventos + 1;

        const totalPaginas =
            this.totalPaginasEventos || 1;

        info.innerText =
            `Página ${paginaAtual} de ${totalPaginas}`;

        btnAnterior.disabled =
            this.paginaEventos <= 0;

        btnProxima.disabled =
            this.paginaEventos >=
            this.totalPaginasEventos - 1;
    }

    async paginaAnteriorEventos() {

        if (this.paginaEventos <= 0) {
            return;
        }

        this.paginaEventos--;

        await this.carregarEventos();
    }

    async proximaPaginaEventos() {

        if (
            this.paginaEventos >=
            this.totalPaginasEventos - 1
        ) {
            return;
        }

        this.paginaEventos++;

        await this.carregarEventos();
    }

    async filtrarEventos() {

        const texto =
            document.getElementById('filtro-evento-texto')
                .value.trim();

        const comunidadeId =
            document.getElementById('filtro-evento-comunidade')
                .value;

        const status =
            document.getElementById('filtro-evento-status')
                .value;

        const periodo =
            document.getElementById('filtro-evento-periodo')
                .value;

        const intervalo =
            document.getElementById('filtro-evento-intervalo');

        let dataInicio = null;
        let dataFim = null;

        const hoje = new Date();

        const formatarData = (data) => {
            const ano = data.getFullYear();
            const mes = String(data.getMonth() + 1).padStart(2, '0');
            const dia = String(data.getDate()).padStart(2, '0');

            return `${ano}-${mes}-${dia}`;
        };

        if (periodo === 'hoje') {

            dataInicio = formatarData(hoje);
            dataFim = formatarData(hoje);

            intervalo.style.display = 'none';

        } else if (periodo === 'semana') {

            const inicio = new Date(hoje);

            const diaSemana = inicio.getDay();

            const diferencaParaSegunda =
                diaSemana === 0 ? -6 : 1 - diaSemana;

            inicio.setDate(
                inicio.getDate() + diferencaParaSegunda
            );

            const fim = new Date(inicio);
            fim.setDate(inicio.getDate() + 6);

            dataInicio = formatarData(inicio);
            dataFim = formatarData(fim);

            intervalo.style.display = 'none';

        } else if (periodo === 'mes') {

            const inicio = new Date(
                hoje.getFullYear(),
                hoje.getMonth(),
                1
            );

            const fim = new Date(
                hoje.getFullYear(),
                hoje.getMonth() + 1,
                0
            );

            dataInicio = formatarData(inicio);
            dataFim = formatarData(fim);

            intervalo.style.display = 'none';

        } else if (periodo === 'personalizado') {

            intervalo.style.display = 'flex';

            dataInicio =
                document.getElementById(
                    'filtro-evento-data-inicio'
                ).value || null;

            dataFim =
                document.getElementById(
                    'filtro-evento-data-fim'
                ).value || null;

        } else {

            intervalo.style.display = 'none';
        }

        this.filtrosEventos = {
            texto: texto || null,

            comunidadeId:
                comunidadeId
                    ? parseInt(comunidadeId)
                    : null,

            status:
                status || null,

            dataInicio,
            dataFim
        };

        this.paginaEventos = 0;

        await this.carregarEventos();
    }

    carregarFiltroComunidadesEventos() {

        const select =
            document.getElementById(
                'filtro-evento-comunidade'
            );

        if (!select) {
            return;
        }

        select.innerHTML =
            '<option value="">Todas as comunidades</option>';

        Object.entries(this.comunidadesMap)
            .sort((a, b) =>
                a[1].localeCompare(b[1])
            )
            .forEach(([id, nome]) => {

                const option =
                    document.createElement('option');

                option.value = id;
                option.textContent = nome;

                select.appendChild(option);
            });
    }

    buscarEventosComDebounce() {

        clearTimeout(this.timerBuscaEventos);

        this.timerBuscaEventos = setTimeout(() => {
            this.filtrarEventos();
        }, 400);
    }

    async abrirDetalhesEvento(idEvento) {

        const evento = this.listaEventos.find(
            e => (e.idEvento || e.id) == idEvento
        );

        if (!evento) {
            return;
        }

        const participantes =
            await ApiService.listarParticipantesEvento(idEvento);

        const quantidadeParticipantes = participantes.length;

        const idUsuarioLogado =
            ApiService.getIdUsuarioLogado();

        const usuarioParticipa =
            idUsuarioLogado &&
            participantes.some(
                p => p.usuarioId == idUsuarioLogado
            );

        const ehCriador =
            idUsuarioLogado &&
            idUsuarioLogado == evento.criadorId;

        const nomeCriador =
            this.usuariosMap[evento.criadorId] || 'Desconhecido';

        const nomeComunidade =
            evento.comunidadeId
                ? this.comunidadesMap[evento.comunidadeId]
                : null;

        const dataFormatada =
            evento.dataEvento
                ? evento.dataEvento.split('-').reverse().join('/')
                : '';
        const horarioInicioFormatado =
            evento.horarioInicio
                ? evento.horarioInicio.substring(0, 5)
                : '';

        const horarioFimFormatado =
            evento.horarioFim
                ? evento.horarioFim.substring(0, 5)
                : '';

        const eventoCancelado =
            evento.status === 'CANCELADO';

        const eventoLotado =
            evento.limiteParticipantes !== null &&
            quantidadeParticipantes >= evento.limiteParticipantes;

        const container =
            document.getElementById('evento-detalhes-conteudo');

        container.innerHTML = `
        <div class="card">

            <div style="
                display:flex;
                justify-content:space-between;
                gap:16px;
                align-items:flex-start;
            ">
                <div>
                    <h1 style="margin-top:0;">
                        ${evento.titulo}
                    </h1>

                    <p style="
                        color:var(--text-muted);
                        margin-top:6px;
                    ">
                        Organizado por ${nomeCriador}
                    </p>
                </div>

                <span style="
                    font-size:13px;
                    font-weight:700;
                ">
                    ${evento.status || 'AGENDADO'}
                </span>
            </div>

            <p style="
                font-size:15px;
                line-height:1.6;
                margin:24px 0;
            ">
                ${evento.descricao || 'Sem descrição informada.'}
            </p>

            <div style="
                border-top:1px solid #f3f4f6;
                padding-top:20px;
                display:grid;
                gap:10px;
            ">
                <div>📅 <b>Data:</b> ${dataFormatada}</div>

                <div>⏰ <b>Horário:</b> ${horarioInicioFormatado} às ${horarioFimFormatado}</div>

                <div>📍 <b>Local:</b> ${evento.localEvento}</div>

                ${nomeComunidade ? `
                    <div>
                        💬 <b>Comunidade:</b> ${nomeComunidade}
                    </div>
                ` : ''}

                <div>
                    👥 <b>Participantes:</b>
                    ${evento.limiteParticipantes
                ? `${quantidadeParticipantes} de ${evento.limiteParticipantes}`
                : quantidadeParticipantes
            }
                </div>

                <div>
                    🎟 <b>Controle de entrada:</b>
                    ${evento.exigeCheckin ? 'Sim' : 'Não'}
                </div>
            </div>

            <div style="
                display:flex;
                gap:10px;
                flex-wrap:wrap;
                margin-top:24px;
            ">

                ${!eventoCancelado &&
                idUsuarioLogado &&
                !ehCriador
                ? usuarioParticipa
                    ? `
                                <button
                                    class="btn-secondary"
                                    onclick="app.sairDoEvento(${idEvento})">
                                    Sair do evento
                                </button>
                            `
                    : eventoLotado
                        ? `
                                    <button
                                        class="btn-secondary"
                                        disabled>
                                        Evento lotado
                                    </button>
                                `
                        : `
                                    <button
                                        class="btn-primary"
                                        onclick="app.participarEvento(${idEvento})">
                                        Participar
                                    </button>
                                `
                : ''
            }

                ${ehCriador
                ? `
                            <button
                                class="btn-primary"
                                onclick="app.gerenciarEvento(${idEvento})">
                                Gerenciar evento
                            </button>
                        `
                : ''
            }

            </div>
        </div>
    `;

        document.querySelectorAll('.view-section')
            .forEach(el => el.classList.remove('active'));

        document.getElementById('view-evento-detalhes')
            .classList.add('active');
    }

    voltarParaEventos() {

        document.querySelectorAll('.view-section')
            .forEach(el => el.classList.remove('active'));

        document.getElementById('view-eventos')
            .classList.add('active');

        document.querySelectorAll('.nav-btn')
            .forEach(el => el.classList.remove('active'));

        const botaoEventos =
            document.getElementById('tab-eventos');

        if (botaoEventos) {
            botaoEventos.classList.add('active');
        }
    }
}


window.app = new AppController();
window.app.inicializar();