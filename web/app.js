import { ApiService } from './api_service.js';

class AppController {
    constructor() {
        this.listaUsuariosCompleta = [];
        this.usuariosMap = {};
        this.usuariosFotosMap = {};
        this.comunidadesMap = {}; // Guarda id -> nome da comunidade
        this.carregarFiltroComunidadesEventos();
        this.listaComunidades = [];
        this.comentariosPorPost = {};
        this.posts = [];
        this.paginaFeed = 0;
        this.tamanhoPaginaFeed = 10;
        this.temMaisPosts = true;
        this.carregandoMaisPosts = false;
        this.votos = [];
        this.postsSalvos = [];
        this.filtroFeed = 'todos';
        this.ordenacaoFeed = 'recentes';
        this.modoCadastro = false;
        this.telaBoasVindasVisivel = true;
        this.comunidadeAtivaId = null;
        this.usuarioParticipaDaComunidade = false;
        this.comunidadeEditando = null;
        this.eventoEditando = null;
        this.listaEventos = [];
        this.paginaEventos = 0;
        this.totalPaginasEventos = 0;
        this.tamanhoPaginaEventos = 12;
        this.interessesSelecionados = [];
        this.usuariosSeguidos = new Set();
        this.filtrosEventos = {
            texto: null,
            status: null,
            categoria: null,
            comunidadeId: null,
            dataInicio: null,
            dataFim: null
        };
        this.timerBuscaEventos = null;
        this.viewAntesDoPerfil = 'feed';
        this.visaoEventos = 'descobrir';
        this.agendaIniciadaNaEntrada = false;
        this.listaConversas = [];
        this.conversaAtiva = null;
        this.chatSocket = null;
        this.chatSidebarAberto = true;
    }
    async inicializar() {

        // Listener para Scroll Infinito no Feed
        window.addEventListener('scroll', () => {
            const feedView = document.getElementById('view-feed');
            if (feedView && feedView.classList.contains('active')) {
                const scrollY = window.scrollY || window.pageYOffset;
                const visibleHeight = window.innerHeight;
                const totalHeight = document.documentElement.scrollHeight || document.body.scrollHeight;
                if (scrollY + visibleHeight >= totalHeight - 350) {
                    this.carregarMaisPosts();
                }
            }
        });

        document.addEventListener('keydown', (evento) => {
            if (evento.key === 'Escape') {
                document.querySelector('.account-menu')?.classList.remove('open');
                document.querySelectorAll('.modal-overlay').forEach(modal => {
                    if (modal.style.display === 'flex') modal.style.display = 'none';
                });
            }
        });

        document.addEventListener('click', (evento) => {
            if (!evento.target.closest('.account-menu')) {
                document.querySelector('.account-menu')?.classList.remove('open');
            }
        });

        const chatForm =
            document.getElementById('chat-message-form');

        if (chatForm) {
            chatForm.addEventListener(
                'submit',
                (event) => this.enviarMensagemChat(event)
            );
        }

        const chatCloseBtn =
            document.getElementById('chat-close-btn');

        if (chatCloseBtn) {
            chatCloseBtn.addEventListener(
                'click',
                () => this.fecharConversa()
            );
        }

        const chatToggleBtn =
            document.getElementById('chat-toggle-btn');

        if (chatToggleBtn) {
            chatToggleBtn.addEventListener(
                'click',
                () => this.alternarChatSidebar()
            );
        }

        const chatSearchInput =
            document.getElementById('chat-search-input');

        if (chatSearchInput) {
            chatSearchInput.addEventListener(
                'input',
                (event) => this.filtrarConversas(event.target.value)
            );
        }

        const usuarioLogado =
            ApiService.getUsuarioLogado();

        console.log(
            "Usuário encontrado ao iniciar:",
            usuarioLogado
        );

        this.atualizarMenuLateral();

        if (usuarioLogado) {

            // PRIMEIRO mostra o sistema
            this.esconderTelaBoasVindas();
            this.conectarWebSocketChat();

            // A agenda é a tela principal e não deve esperar o carregamento do feed.
            this.agendaIniciadaNaEntrada = true;
            this.carregarEventos();

            // DEPOIS carrega os dados
            try {
                await this.carregarDadosGlobais();
                await this.carregarConversas();
            } catch (erro) {
                console.error(
                    "Erro ao carregar dados iniciais:",
                    erro
                );
            }

            return;
        }


        this.mostrarTelaBoasVindas();
    }

    fecharConversa() {
        const janela =
            document.getElementById('chat-window');

        if (janela) {
            janela.classList.remove('active');
        }

        this.conversaAtiva = null;
    }

    alternarChatSidebar() {
        const sidebar = document.getElementById('chat-sidebar');
        const toggleBtn = document.getElementById('chat-toggle-btn');

        if (!sidebar || !toggleBtn) {
            return;
        }

        this.chatSidebarAberto = !this.chatSidebarAberto;
        sidebar.classList.toggle('collapsed', !this.chatSidebarAberto);
        toggleBtn.textContent = this.chatSidebarAberto ? '‹' : '›';
        toggleBtn.setAttribute('title', this.chatSidebarAberto ? 'Recolher mensagens' : 'Expandir mensagens');
    }

    filtrarConversas(termoBusca = '') {
        const container = document.getElementById('chat-conversations');

        if (!container) {
            return;
        }

        const texto = termoBusca.trim().toLowerCase();
        const conversasFiltradas = this.listaConversas.filter((conversa) => {
            const nome = (conversa.nomeOutroUsuario || '').toLowerCase();
            const username = (conversa.usernameOutroUsuario || '').toLowerCase();
            return nome.includes(texto) || username.includes(texto);
        });

        this.renderizarConversas(conversasFiltradas, texto);
    }

    // --- MENU E NAVEGAÇÃO ---
    mostrarTelaBoasVindas() {
        document.getElementById('welcome-screen').classList.add('active');
        document.getElementById('app-shell').classList.remove('active');
        this.telaBoasVindasVisivel = true;
        this.carregarEventosDestaque();
    }

    esconderTelaBoasVindas() {
        document.getElementById('welcome-screen').classList.remove('active');
        document.getElementById('app-shell').classList.add('active');
        this.telaBoasVindasVisivel = false;
    }

    async carregarEventosDestaque() {
        const container = document.getElementById('preview-events');
        const dataContainer = document.getElementById('preview-date');

        if (!container || !dataContainer) return;

        try {
            const resultado = await ApiService.buscarEventos({
                status: 'AGENDADO',
                page: 0,
                size: 3
            });
            const eventos = (resultado.content || []).slice(0, 3);

            if (!eventos.length) {
                container.innerHTML = '<div class="preview-empty">Nenhum evento agendado por enquanto.</div>';
                dataContainer.innerHTML = '<strong>--</strong><span>AGENDA<br><b>em breve</b></span>';
                return;
            }

            const primeiroEvento = eventos[0];
            const data = this.formatarDataDestaque(primeiroEvento.dataEvento);
            dataContainer.innerHTML = `
                <strong>${data.dia}</strong>
                <span>${data.mes}<br><b>${data.semana}</b></span>
            `;

            container.innerHTML = eventos.map((evento, index) => {
                const horario = evento.horarioInicio
                    ? evento.horarioInicio.substring(0, 5)
                    : '--:--';
                const local = evento.localEvento || 'Local a confirmar';
                const participantes = evento.quantidadeParticipantes || 0;
                const limite = evento.limiteParticipantes
                    ? ` · ${participantes}/${evento.limiteParticipantes} vagas`
                    : '';

                return `
                    <div class="preview-event ${index === 0 ? 'preview-event-highlight' : ''}">
                        <div class="preview-event-time">${horario}</div>
                        <div><strong>${this.escaparHtmlDestaque(evento.titulo || 'Evento')}</strong><span>${this.escaparHtmlDestaque(local)}${limite}</span></div>
                        <i class="material-icons">chevron_right</i>
                    </div>
                `;
            }).join('');
        } catch (erro) {
            console.warn('Não foi possível carregar a agenda inicial.', erro);
            container.innerHTML = '<div class="preview-empty">A agenda estará disponível em instantes.</div>';
        }
    }

    formatarDataDestaque(dataEvento) {
        if (!dataEvento) return { dia: '--', mes: 'AGENDA', semana: 'em breve' };

        const data = new Date(`${dataEvento}T00:00:00`);
        return {
            dia: String(data.getDate()).padStart(2, '0'),
            mes: data.toLocaleDateString('pt-BR', { month: 'short' }).replace('.', '').toUpperCase(),
            semana: data.toLocaleDateString('pt-BR', { weekday: 'long' })
        };
    }

    escaparHtmlDestaque(valor) {
        return String(valor).replace(/[&<>'"]/g, caractere => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            "'": '&#39;',
            '"': '&quot;'
        }[caractere]));
    }

    selecionarOpcao(opcao) {
        if (opcao === 'login') {
            this.modoCadastro = false;
            this.atualizarAuthUI();
            this.abrirModal('auth-modal');
        } else if (opcao === 'cadastro') {
            this.modoCadastro = true;
            this.atualizarAuthUI();
            this.abrirModal('auth-modal');
        } else {
            this.esconderTelaBoasVindas();
            this.atualizarMenuLateral();
            this.carregarDadosGlobais();
        }
    }

    async explorarEventos() {
        this.esconderTelaBoasVindas();
        this.atualizarMenuLateral();
        await this.carregarDadosGlobais();
        this.mudarAba('eventos');
    }

    getInteressesDisponiveis() {
        return [
            'Tecnologia', 'Arte', 'Música', 'Esportes', 'Networking',
            'Cultura', 'Educação', 'Games', 'Gastronomia', 'Saúde',
            'Filmes', 'Fotografia', 'Natureza', 'Inovação', 'Social'
        ];
    }

    getInteressesSelecionados() {
        const usuarioLogado = ApiService.getUsuarioLogado();
        if (usuarioLogado && Array.isArray(usuarioLogado.interesses) && usuarioLogado.interesses.length) {
            this.carregarConversas();
            return usuarioLogado.interesses;
        }

        return [...this.interessesSelecionados];
    }

    toggleInteresse(interesse) {
        const selecionados = new Set(this.getInteressesSelecionados());

        if (selecionados.has(interesse)) {
            selecionados.delete(interesse);
        } else {
            if (selecionados.size >= 5) {
                this.mostrarAuthFeedback('Você pode escolher até 5 interesses.');
                return;
            }
            selecionados.add(interesse);
        }

        this.interessesSelecionados = [...selecionados];
        this.renderizarSelecaoInteresses();
        this.mostrarAuthFeedback('');
    }

    renderizarSelecaoInteresses() {
        const container = document.getElementById('auth-interesses-list');
        if (!container) return;

        const selecionados = new Set(this.getInteressesSelecionados());
        container.innerHTML = this.getInteressesDisponiveis()
            .map(interesse => `
                <button
                    type="button"
                    class="interesse-chip ${selecionados.has(interesse) ? 'active' : ''}"
                    data-interesse="${interesse}"
                    onclick="app.toggleInteresse('${interesse}')"
                >
                    ${interesse}
                </button>
            `)
            .join('');
    }

    atualizarAuthUI() {
        const modal = document.querySelector('.auth-modal');
        const titulo = document.getElementById('auth-title');
        const subtitulo = document.getElementById('auth-subtitle');
        const submit = document.getElementById('auth-submit');
        const forgot = document.getElementById('auth-forgot');
        const emailLabel = document.getElementById('auth-email-label') || document.querySelector('label[for="auth-email"]');
        const emailInput = document.getElementById('auth-email');

        if (!modal || !titulo || !submit) return;

        modal.classList.toggle('register-mode', this.modoCadastro);
        titulo.innerText = this.modoCadastro ? 'Crie seu espaço' : 'Acesso ao Painel';
        subtitulo.innerText = this.modoCadastro
            ? 'Monte seu perfil e encontre eventos que combinam com você.'
            : 'Entre para acompanhar eventos, comunidades e conversas.';
        submit.innerText = this.modoCadastro ? 'Criar minha conta' : 'Entrar';
        forgot.style.display = this.modoCadastro ? 'none' : 'block';

        if (emailLabel) {
            emailLabel.innerText = this.modoCadastro ? 'E-mail' : 'E-mail ou telefone';
        }
        if (emailInput) {
            emailInput.placeholder = this.modoCadastro ? 'seu@email.com' : 'seu@email.com ou (00) 00000-0000';
            emailInput.setAttribute('autocomplete', this.modoCadastro ? 'email' : 'username');
        }

        document.getElementById('auth-senha').setAttribute(
            'autocomplete',
            this.modoCadastro ? 'new-password' : 'current-password'
        );

        document.getElementById('auth-tab-login')?.classList.toggle('active', !this.modoCadastro);
        document.getElementById('auth-tab-register')?.classList.toggle('active', this.modoCadastro);
        this.mostrarAuthFeedback('');
        this.atualizarForcaSenha();
        if (this.modoCadastro) this.renderizarSelecaoInteresses();
    }
    mudarAba(nomeAba) {
        this.salvarViewAtual(nomeAba);
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));

        document.getElementById(`view-${nomeAba}`).classList.add('active');
        if (document.getElementById(`tab-${nomeAba}`)) {
            document.getElementById(`tab-${nomeAba}`).classList.add('active');
        }

        this.comunidadeAtivaId = null; // Reseta se sair da tela de subreddit

        if (nomeAba === 'busca') this.renderizarUsuarios(this.listaUsuariosCompleta);
        if (nomeAba === 'feed') {
            this.renderizarFeedGeral();
            this.carregarEventosFeed();
        }
        if (nomeAba === 'comunidades') this.carregarComunidades();
        if (nomeAba === 'eventos') this.carregarEventos();
    }

    atualizarMenuLateral() {
        const container = document.getElementById('header-buttons');
        const user = ApiService.getUsuarioLogado();
        if (user) {
            const inicial = (user.nome || 'U').charAt(0).toUpperCase();
            const fotoUrl = ApiService.formatarUrlFotoPerfil(user.fotoPerfil);
            const avatarHtml = fotoUrl
                ? `<img src="${fotoUrl}?v=${Date.now()}" class="account-avatar" style="object-fit:cover; border-radius:50%; width:28px; height:28px;" onerror="this.outerHTML='<span class=\\'account-avatar\\'>${inicial}</span>'">`
                : `<span class="account-avatar">${inicial}</span>`;

            container.innerHTML = `
    <div class="account-menu">
        <button class="account-trigger" aria-haspopup="true" aria-expanded="false" onclick="app.alternarMenuConta(event)">
            ${avatarHtml}
            <span class="account-name">${this.escaparHtmlDestaque(user.nome || 'Minha conta')}</span>
            <i class="material-icons account-chevron">expand_more</i>
        </button>
        <div class="account-dropdown" role="menu">
            <div class="account-dropdown-label">Conta conectada</div>
            <button class="account-menu-item" role="menuitem" onclick="app.abrirMeuPerfil()">
                <i class="material-icons">person_outline</i> Meu perfil
            </button>
            <button class="account-menu-item account-menu-logout" role="menuitem" onclick="app.fazerLogout()">
                <i class="material-icons">logout</i> Sair do sistema
            </button>
        </div>
    </div>
`;
        } else {
            container.innerHTML = `<button class="btn-primary" style="width:100%;" onclick="app.abrirModal('auth-modal')">Fazer Login</button>`;
        }
    }

    alternarMenuConta(evento) {
        evento.stopPropagation();
        const menu = document.querySelector('.account-menu');
        const aberto = menu.classList.toggle('open');
        menu.querySelector('.account-trigger').setAttribute('aria-expanded', aberto);
    }

    abrirModal(id) {
        const modal = document.getElementById(id);
        if (!modal) return;

        if (id === 'evento-modal') {
            if (!ApiService.getUsuarioLogado()) {
                this.definirModoAuth(false);
                this.abrirModal('auth-modal');
                this.mostrarAuthFeedback("Faça login para organizar um evento.");
                return;
            }
            this.prepararModalEvento();
        }

        modal.style.display = 'flex';
        if (id === 'auth-modal') {
            setTimeout(() => {
                const targetId = this.modoCadastro ? 'auth-nome-completo' : 'auth-email';
                document.getElementById(targetId)?.focus();
            }, 0);
        } else if (id === 'evento-modal') {
            setTimeout(() => document.getElementById('evento-titulo')?.focus(), 0);
        }
    }

    abrirModalEvento() {
        this.abrirModal('evento-modal');
    }

    prepararModalEvento() {
        this.popularComunidadesEvento(this.comunidadeAtivaId || null);
        this.mostrarEventoFeedback('');

        const hojeIso = new Date().toISOString().split('T')[0];
        const dataInput = document.getElementById('evento-data');
        if (dataInput && !dataInput.value) {
            dataInput.min = hojeIso;
        }
    }

    popularComunidadesEvento(selecionadaId = null) {
        const select = document.getElementById('evento-comunidade-id');
        if (!select) return;

        select.innerHTML = '<option value="">Nenhuma (Evento aberto / Global)</option>';
        if (Array.isArray(this.listaComunidades)) {
            this.listaComunidades.forEach(com => {
                const id = com.idComunidade || com.id;
                const nome = com.nome || 'Comunidade';
                const selected = (selecionadaId && String(id) === String(selecionadaId)) ? 'selected' : '';
                select.innerHTML += `<option value="${id}" ${selected}>${this.escaparHtmlDestaque(nome)}</option>`;
            });
        }
        if (selecionadaId) {
            select.value = selecionadaId;
        }
    }

    atualizarPreviewCapaEvento(input) {
        const file = input?.files?.[0];
        const previewBox = document.getElementById('evento-capa-preview-box');
        const nomeEl = document.getElementById('evento-capa-nome');
        if (!previewBox || !nomeEl) return;

        if (file) {
            nomeEl.innerText = file.name;
            const reader = new FileReader();
            reader.onload = (e) => {
                previewBox.style.backgroundImage = `linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('${e.target.result}')`;
                previewBox.classList.add('has-preview');
            };
            reader.readAsDataURL(file);
        } else {
            nomeEl.innerText = 'Clique para selecionar uma imagem';
            previewBox.style.backgroundImage = 'none';
            previewBox.classList.remove('has-preview');
        }
    }

    mostrarEventoFeedback(mensagem) {
        const feedback = document.getElementById('evento-feedback');
        if (!feedback) return;
        feedback.innerText = mensagem;
        feedback.classList.toggle('visible', Boolean(mensagem));
        if (mensagem) {
            feedback.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    definirEventoLoading(carregando) {
        const botao = document.getElementById('btn-criar-evento');
        if (!botao) return;
        botao.disabled = carregando;
        botao.classList.toggle('loading', carregando);
        botao.innerText = carregando ? 'Agendando evento...' : 'Agendar Evento';
    }

    limparFormularioEvento() {
        const titulo = document.getElementById('evento-titulo');
        if (titulo) titulo.value = '';
        const desc = document.getElementById('evento-desc');
        if (desc) desc.value = '';
        const cat = document.getElementById('evento-categoria');
        if (cat) cat.value = '';
        const data = document.getElementById('evento-data');
        if (data) data.value = '';
        const inicio = document.getElementById('evento-horario-inicio');
        if (inicio) inicio.value = '';
        const fim = document.getElementById('evento-horario-fim');
        if (fim) fim.value = '';
        const enc = document.getElementById('evento-encerramento-inscricoes');
        if (enc) enc.value = '';
        const local = document.getElementById('evento-local');
        if (local) local.value = '';
        const com = document.getElementById('evento-comunidade-id');
        if (com) com.value = '';
        const lim = document.getElementById('evento-limite');
        if (lim) lim.value = '';
        const check = document.getElementById('evento-checkin');
        if (check) check.checked = false;

        const capaInput = document.getElementById('evento-capa');
        if (capaInput) capaInput.value = '';
        this.atualizarPreviewCapaEvento(capaInput);
        this.mostrarEventoFeedback('');
    }

    fecharModal(id) { document.getElementById(id).style.display = 'none'; }

    abrirModalPost() {

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return alert("Faça login primeiro.");
        }


        // Se estiver dentro de uma comunidade,
        // só permite publicar se participar dela.
        if (
            this.comunidadeAtivaId &&
            !this.usuarioParticipaDaComunidade
        ) {
            return alert(
                "Você precisa entrar na comunidade antes de publicar."
            );
        }


        const tituloEl =
            document.getElementById('modal-post-title');

        if (this.comunidadeAtivaId) {

            tituloEl.innerText =
                `Postar em: ${this.comunidadesMap[
                this.comunidadeAtivaId
                ]
                }`;

        } else {

            tituloEl.innerText =
                "Nova Publicação Global";
        }


        const seletorComunidade =
            document.getElementById(
                'post-comunidade-id'
            );


        if (seletorComunidade) {

            seletorComunidade.innerHTML = `
            <option value="">
                Publicar no feed global
            </option>
        `;


            /*
             * Mostra somente comunidades
             * das quais o usuário participa.
             */
            const comunidadesPermitidas =
                this.listaComunidades.filter(
                    comunidade => {

                        const membros =
                            comunidade.membros || [];

                        const usuarioEhMembro =
                            membros.some(
                                membro =>
                                    String(
                                        membro.idUsuario ||
                                        membro.id
                                    ) ===
                                    String(idUsuario)
                            );


                        /*
                         * Também permite ao criador
                         * publicar na própria comunidade.
                         */
                        const idCriador =
                            comunidade.criador?.idUsuario ||
                            comunidade.criador?.id;

                        const usuarioEhCriador =
                            String(idCriador) ===
                            String(idUsuario);


                        return (
                            usuarioEhMembro ||
                            usuarioEhCriador
                        );
                    }
                );


            comunidadesPermitidas.forEach(
                comunidade => {

                    const id =
                        comunidade.idComunidade ||
                        comunidade.id;

                    seletorComunidade.innerHTML += `
                    <option value="${id}">
                        ${this.escaparHtmlDestaque(
                        comunidade.nome
                    )
                        }
                    </option>
                `;
                }
            );


            /*
             * Se o usuário abriu o modal
             * de dentro de uma comunidade,
             * ela já fica selecionada.
             */
            if (this.comunidadeAtivaId) {

                seletorComunidade.value =
                    this.comunidadeAtivaId;
            }
        }


        this.abrirModal('post-modal');
    }

    // --- AUTH --- (Igual ao anterior, resumido para focar na lógica)
    alternarAuth() {
        this.modoCadastro = !this.modoCadastro;
        this.atualizarAuthUI();
    }

    definirModoAuth(modoCadastro) {
        this.modoCadastro = modoCadastro;
        this.atualizarAuthUI();
    }

    mostrarAuthFeedback(mensagem) {
        const feedback = document.getElementById('auth-feedback');
        if (!feedback) return;
        feedback.innerText = mensagem;
        feedback.classList.toggle('visible', Boolean(mensagem));
    }

    alternarVisibilidadeSenha(id, botao) {
        const input = document.getElementById(id);
        if (!input) return;
        const visivel = input.type === 'text';
        input.type = visivel ? 'password' : 'text';
        botao.setAttribute('aria-label', visivel ? 'Mostrar senha' : 'Ocultar senha');
        botao.querySelector('.material-icons').innerText = visivel ? 'visibility' : 'visibility_off';
    }

    atualizarForcaSenha() {
        const indicador = document.getElementById('auth-password-strength');
        const senha = document.getElementById('auth-senha')?.value || '';
        if (!indicador) return;

        if (!this.modoCadastro || !senha) {
            indicador.innerText = '';
            indicador.className = 'password-strength';
            return;
        }

        const pontuacao = [
            senha.length >= 8,
            /[A-Z]/.test(senha),
            /[0-9]/.test(senha),
            /[^A-Za-z0-9]/.test(senha)
        ].filter(Boolean).length;
        const nivel = pontuacao <= 1 ? 'weak' : pontuacao <= 3 ? 'medium' : 'strong';
        const texto = nivel === 'weak' ? 'Senha fraca' : nivel === 'medium' ? 'Senha média' : 'Senha forte';
        indicador.innerText = texto;
        indicador.className = `password-strength ${nivel}`;
    }

    definirAuthLoading(carregando) {
        const botao = document.getElementById('auth-submit');
        if (!botao) return;
        botao.disabled = carregando;
        botao.classList.toggle('loading', carregando);
        botao.innerText = carregando ? 'Aguarde...' : (this.modoCadastro ? 'Criar minha conta' : 'Entrar');
    }

    recuperarSenha() {
        this.mostrarAuthFeedback('A recuperação de senha ainda precisa ser habilitada no servidor.');
    }

    getInteresseScore(item, interessesUsuario) {
        if (!interessesUsuario || !interessesUsuario.length) return 0;

        const texto = `${item?.categoria || ''} ${item?.titulo || ''} ${item?.nome || ''} ${item?.descricao || ''}`.toLowerCase();
        let score = 0;

        interessesUsuario.forEach(interesse => {
            const termo = interesse.toLowerCase();
            if ((item?.categoria || '').toLowerCase().includes(termo)) score += 3;
            if (texto.includes(termo)) score += 1;
        });

        return score;
    }

    ordenarPorInteresses(lista) {
        const interessesUsuario = this.getInteressesSelecionados();
        if (!interessesUsuario.length || !lista?.length) return lista;

        return [...lista].sort((a, b) => this.getInteresseScore(b, interessesUsuario) - this.getInteresseScore(a, interessesUsuario));
    }

    async processarAuth() {
        const nomeCompleto =
            document.getElementById('auth-nome-completo').value.trim();
        const e = document.getElementById('auth-email').value.trim();
        const s = document.getElementById('auth-senha').value;
        const n = document.getElementById('auth-nome').value.trim();
        const username =
            document.getElementById('auth-username').value.trim().replace(/^@+/, '');
        const dataNascimento =
            document.getElementById('auth-data-nascimento').value;
        const telefone =
            document.getElementById('auth-telefone').value.trim();
        const confirmarSenha =
            document.getElementById('auth-confirmar-senha')?.value || '';
        const interesses = this.getInteressesSelecionados();

        this.mostrarAuthFeedback('');

        if (!s || (!this.modoCadastro && !e)) {
            return this.mostrarAuthFeedback(
                this.modoCadastro
                    ? 'Informe uma senha para continuar.'
                    : 'Informe seu e-mail ou telefone e sua senha para continuar.'
            );
        }

        if (!this.modoCadastro) {
            const credencial = e;
            if (!credencial) {
                return this.mostrarAuthFeedback('Informe seu e-mail ou telefone para continuar.');
            }
            if (credencial.includes('@') && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(credencial)) {
                return this.mostrarAuthFeedback('Informe um e-mail válido.');
            }
            if (!credencial.includes('@') && credencial.replace(/\D/g, '').length < 10) {
                return this.mostrarAuthFeedback('Informe um e-mail ou telefone válido.');
            }
        }

        try {
            if (this.modoCadastro) {
                if (
                    !nomeCompleto ||
                    !n ||
                    !username ||
                    !dataNascimento ||
                    !s
                ) {
                    return this.mostrarAuthFeedback('Preencha os campos obrigatórios do cadastro.');
                }

                if (!e) {
                    return this.mostrarAuthFeedback('Informe seu e-mail para criar a conta.');
                }

                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e)) {
                    return this.mostrarAuthFeedback('Informe um e-mail válido.');
                }

                if (!/^[a-zA-Z0-9._-]{3,30}$/.test(username)) {
                    return this.mostrarAuthFeedback('O username deve ter de 3 a 30 caracteres, sem espaços.');
                }

                const nascimento = new Date(`${dataNascimento}T00:00:00`);
                const hoje = new Date();
                const idade = hoje.getFullYear() - nascimento.getFullYear() -
                    ((hoje.getMonth() < nascimento.getMonth() ||
                        (hoje.getMonth() === nascimento.getMonth() && hoje.getDate() < nascimento.getDate())) ? 1 : 0);

                if (Number.isNaN(nascimento.getTime()) || idade < 13 || idade > 120) {
                    return this.mostrarAuthFeedback('Informe uma data de nascimento válida (idade mínima de 13 anos).');
                }

                if (telefone && telefone.replace(/\D/g, '').length < 10) {
                    return this.mostrarAuthFeedback('Informe um telefone válido ou deixe em branco.');
                }

                if (s.length < 8) {
                    return this.mostrarAuthFeedback('A senha precisa ter pelo menos 8 caracteres.');
                }

                if (s !== confirmarSenha) {
                    return this.mostrarAuthFeedback('As senhas não coincidem.');
                }

                this.definirAuthLoading(true);
                const res = await ApiService.criarUsuario(
                    nomeCompleto,
                    n,
                    username,
                    dataNascimento,
                    e,
                    telefone || null,
                    s,
                    interesses
                );
                if (res.ok) {
                    const usuario = await res.json();
                    usuario.interesses = interesses;
                    this.interessesSelecionados = [...interesses];
                    ApiService.salvarSessao(usuario);
                    this.posLogin();
                } else this.mostrarAuthFeedback('Não foi possível criar a conta. Verifique seus dados.');
            } else {
                const credencial = e;

                this.definirAuthLoading(true);
                const res = await ApiService.login(credencial, s);

                if (res.ok) {
                    const user = await res.json();
                    ApiService.salvarSessao(user);
                    this.posLogin();
                } else {
                    this.mostrarAuthFeedback('E-mail/telefone ou senha incorretos.');
                }
            }
        } catch (err) {
            console.error(err);
            this.mostrarAuthFeedback('Não foi possível conectar ao servidor. Tente novamente.');
        } finally {
            this.definirAuthLoading(false);
        }
    }

    posLogin() {
        const usuario = ApiService.getUsuarioLogado();
        this.interessesSelecionados = Array.isArray(usuario?.interesses) ? [...usuario.interesses] : [];
        this.fecharModal('auth-modal');
        this.esconderTelaBoasVindas();
        this.atualizarMenuLateral();
        this.carregarDadosGlobais();
        this.carregarConversas();
        this.conectarWebSocketChat();
    }

    fazerLogout() {

        ApiService.fazerLogout();
        this.interessesSelecionados = [];

        this.atualizarMenuLateral();

        this.mudarAba('feed');

        this.agendaIniciadaNaEntrada = false;
        this.mostrarTelaBoasVindas();
    }

    // --- CARREGAMENTO GLOBAL E PAGINADO ---
    async carregarDadosGlobais() {
        try {
            const [usuarios, comunidades, comentarios, votos, salvos] = await Promise.all([
                ApiService.listarUsuarios(),
                ApiService.listarComunidades().catch(() => []),
                ApiService.listarComentarios().catch(() => []),
                ApiService.listarVotos().catch(() => []),
                ApiService.listarPostsSalvos().catch(() => [])
            ]);

            this.listaUsuariosCompleta = usuarios;
            this.listaUsuariosCompleta.forEach(u => {
                const id = u.idUsuario || u.id;
                this.usuariosMap[id] = u.nome;
                this.usuariosFotosMap[id] = u.fotoPerfil;
            });

            this.listaComunidades = comunidades;
            comunidades.forEach(c =>
                this.comunidadesMap[c.idComunidade || c.id] = c.nome
            );
            this.carregarFiltroComunidadesEventos();

            this.comentariosPorPost = {};
            comentarios.forEach(c => {
                let idPost = c.idPost || c.id_post;
                if (!this.comentariosPorPost[idPost]) this.comentariosPorPost[idPost] = [];
                this.comentariosPorPost[idPost].push(c);
            });

            this.votos = votos;
            this.postsSalvos = salvos;
            this.renderizarSugestoesPessoas();

            // Carrega os primeiros posts sob demanda (primeira página)
            await this.carregarMaisPosts(true);

            // Atualiza a view que estiver visível depois dos dados compartilhados carregarem.
            if (this.comunidadeAtivaId) this.renderizarSubreddit(this.comunidadeAtivaId);
            else if (document.getElementById('view-eventos')?.classList.contains('active') && !this.agendaIniciadaNaEntrada) {
                this.carregarEventos();
            } else {
                this.renderizarFeedGeral();
                this.carregarEventosFeed();
            }

        } catch (e) {
            console.error(e);
            document.getElementById('feed-container').innerHTML = `Erro de conexão com servidor.`;
        }
    }

    async carregarMaisPosts(reset = false) {
        if (this.carregandoMaisPosts) return;
        if (!reset && !this.temMaisPosts) return;

        if (reset) {
            this.paginaFeed = 0;
            this.posts = [];
            this.temMaisPosts = true;
        }

        this.carregandoMaisPosts = true;
        const container = document.getElementById('feed-container');

        let loadingIndicator = document.getElementById('feed-loading-indicator');
        if (!loadingIndicator && container && container.parentNode) {
            loadingIndicator = document.createElement('div');
            loadingIndicator.id = 'feed-loading-indicator';
            loadingIndicator.style.cssText = 'text-align:center; padding:16px; color:var(--text-muted); font-size:14px;';
            loadingIndicator.innerHTML = '<span style="display:inline-block; width:14px; height:14px; border:2px solid var(--accent); border-top-color:transparent; border-radius:50%; animation:spin 1s linear infinite; vertical-align:middle; margin-right:8px;"></span>Carregando publicações...';
            container.parentNode.insertBefore(loadingIndicator, container.nextSibling);
        }
        if (loadingIndicator) loadingIndicator.style.display = 'block';

        try {
            const novosPosts = await ApiService.listarPosts(this.paginaFeed, this.tamanhoPaginaFeed);
            const postsArray = Array.isArray(novosPosts) ? novosPosts : (novosPosts.content || []);

            if (postsArray.length < this.tamanhoPaginaFeed) {
                this.temMaisPosts = false;
                if (loadingIndicator) {
                    loadingIndicator.innerHTML = (this.posts.length + postsArray.length > 0)
                        ? '<p style="color:var(--text-muted); font-size:13px; margin:16px 0;">Você chegou ao fim das publicações.</p>'
                        : '';
                }
            } else if (loadingIndicator) {
                loadingIndicator.style.display = 'none';
            }

            if (reset) {
                this.posts = postsArray;
            } else {
                const idsExistentes = new Set(this.posts.map(p => p.idPost || p.id));
                const postsFiltrados = postsArray.filter(p => !idsExistentes.has(p.idPost || p.id));
                this.posts = [...this.posts, ...postsFiltrados];
            }

            this.paginaFeed++;
            this.renderizarFeedGeral();
        } catch (erro) {
            console.error("Erro ao carregar posts paginados:", erro);
            if (loadingIndicator) loadingIndicator.style.display = 'none';
        } finally {
            this.carregandoMaisPosts = false;
        }
    }

    // --- LÓGICA DE SUBREDDIT E COMUNIDADES ---
    async carregarComunidades() {
        const container = document.getElementById('comunidades-container');
        try {
            const comunidades = await ApiService.listarComunidades();
            this.listaComunidades = comunidades;
            this.renderizarComunidades(comunidades);
        } catch (e) {
            container.innerHTML = "<div class='comunidade-empty'>Nenhuma comunidade pôde ser carregada.</div>";
        }
    }

    renderizarRecomendacoes() {
        const container = document.getElementById('feed-recomendados');
        if (!container) return;

        const interesses = this.getInteressesSelecionados();
        if (!interesses.length) {
            container.innerHTML = '<p class="feed-sidebar-empty">Escolha seus interesses no cadastro para receber sugestões personalizadas.</p>';
            return;
        }

        const recomendados = [];

        this.listaComunidades.forEach(comunidade => {
            const score = this.getInteresseScore(comunidade, interesses);
            if (score > 0) {
                recomendados.push({
                    tipo: 'comunidade',
                    titulo: comunidade.nome,
                    subtitulo: comunidade.categoria || 'Comunidade',
                    score,
                    id: comunidade.idComunidade || comunidade.id,
                    descricao: comunidade.descricao || 'Comunidade com afinidade ao seu perfil.'
                });
            }
        });

        this.listaEventos.forEach(evento => {
            const score = this.getInteresseScore(evento, interesses);
            if (score > 0) {
                recomendados.push({
                    tipo: 'evento',
                    titulo: evento.titulo,
                    subtitulo: evento.categoria || 'Evento',
                    score,
                    id: evento.id,
                    descricao: evento.localEvento || 'Evento com perfil parecido com você.'
                });
            }
        });

        recomendados.sort((a, b) => b.score - a.score);

        const itens = recomendados.slice(0, 4);

        if (!itens.length) {
            container.innerHTML = '<p class="feed-sidebar-empty">Ainda não temos sugestões estreitas para seus interesses.</p>';
            return;
        }

        container.innerHTML = itens.map(item => `
            <button class="feed-recomendado-item" onclick="${item.tipo === 'evento' ? `app.abrirDetalhesEvento(${item.id})` : `app.entrarSubreddit(${item.id})`}" type="button">
                <span>${this.escaparHtmlDestaque(item.subtitulo)}</span>
                <strong>${this.escaparHtmlDestaque(item.titulo)}</strong>
                <small>${this.escaparHtmlDestaque(item.descricao)}</small>
            </button>
        `).join('');
    }

    alternarSeguirUsuario(idUsuario) {
        const id = Number(idUsuario);
        if (this.usuariosSeguidos.has(id)) {
            this.usuariosSeguidos.delete(id);
        } else {
            this.usuariosSeguidos.add(id);
        }

        this.renderizarSugestoesPessoas();
    }

    renderizarSugestoesPessoas() {
        const container = document.getElementById('feed-sugestoes-pessoas');
        if (!container) return;

        const usuarioLogado = ApiService.getUsuarioLogado();
        const usuarioAtualId = usuarioLogado ? (usuarioLogado.idUsuario || usuarioLogado.id) : null;
        const interesses = this.getInteressesSelecionados();

        const candidatos = this.listaUsuariosCompleta
            .filter(usuario => {
                const id = usuario.idUsuario || usuario.id;
                if (!id || id === usuarioAtualId) return false;

                const comunidades = this.listaComunidades.filter(comunidade =>
                    (comunidade.membros || []).some(membro => (membro.idUsuario || membro.id) == id)
                );
                const eventos = this.listaEventos.filter(evento => evento.criadorId == id);
                const textoPerfil = [
                    usuario.nome,
                    usuario.username,
                    usuario.bio,
                    ...comunidades.map(comunidade => `${comunidade.nome} ${comunidade.categoria || ''}`),
                    ...eventos.map(evento => `${evento.titulo} ${evento.categoria || ''}`),
                ].join(' ').toLowerCase();

                let score = 0;
                if (interesses.length) {
                    interesses.forEach(interesse => {
                        if (textoPerfil.includes(interesse.toLowerCase())) score += 2;
                    });
                }

                score += comunidades.length;
                score += eventos.length;
                return score > 0;
            })
            .map(usuario => {
                const id = usuario.idUsuario || usuario.id;
                const comunidades = this.listaComunidades.filter(comunidade =>
                    (comunidade.membros || []).some(membro => (membro.idUsuario || membro.id) == id)
                );
                const eventos = this.listaEventos.filter(evento => evento.criadorId == id);
                const categorias = [...new Set([
                    ...comunidades.map(comunidade => comunidade.categoria || 'Geral'),
                    ...eventos.map(evento => evento.categoria || 'Geral')
                ])];
                let score = 0;
                if (interesses.length) {
                    const textoPerfil = `${usuario.nome} ${usuario.bio || ''} ${usuario.username || ''} ${categorias.join(' ')}`.toLowerCase();
                    interesses.forEach(interesse => {
                        if (textoPerfil.includes(interesse.toLowerCase())) score += 2;
                    });
                }
                score += comunidades.length * 2;
                score += eventos.length * 2;
                return { usuario, score };
            })
            .sort((a, b) => b.score - a.score)
            .slice(0, 4);

        if (!candidatos.length) {
            container.innerHTML = '<p class="feed-sidebar-empty">Ainda não há perfis parecidos para sugerir no momento.</p>';
            return;
        }

        container.innerHTML = candidatos.map(({ usuario }) => {
            const id = usuario.idUsuario || usuario.id;
            const seguindo = this.usuariosSeguidos.has(Number(id));
            return `
                <div class="feed-pessoa-item">
                    <div class="feed-pessoa-item-top">
                        <div class="avatar avatar-small">${this.escaparHtmlDestaque((usuario.nome || 'U').charAt(0).toUpperCase())}</div>
                        <div>
                            <strong>${this.escaparHtmlDestaque(usuario.nome || 'Usuário')}</strong>
                            <span>@${this.escaparHtmlDestaque(usuario.username || 'usuario')}</span>
                        </div>
                    </div>
                    <p>${this.escaparHtmlDestaque((usuario.bio || 'Interessado em viver experiências incríveis.').slice(0, 72))}</p>
                    <button class="feed-pessoa-btn ${seguindo ? 'seguindo' : ''}" onclick="app.alternarSeguirUsuario(${id})" type="button">${seguindo ? 'Seguindo' : 'Seguir'}</button>
                </div>
            `;
        }).join('');
    }

    renderizarComunidades(comunidades) {
        const container = document.getElementById('comunidades-container');
        if (!container) return;

        const comunidadesOrdenadas = this.ordenarPorInteresses(comunidades);

        if (!comunidadesOrdenadas.length) {
            container.innerHTML = '<div class="comunidade-empty">Nenhuma comunidade encontrada. Crie a primeira.</div>';
            return;
        }
        const eventosPorComunidade = this.listaEventos.reduce((total, evento) => {
            total[evento.comunidadeId] = (total[evento.comunidadeId] || 0) + 1;
            return total;
        }, {});
        container.innerHTML = '';
        comunidadesOrdenadas.forEach(c => {
            const idCom = c.idComunidade || c.id;
            const div = document.createElement('div');
            div.className = 'comunidade-card';

            const idUsuarioLogado = ApiService.getIdUsuarioLogado();

            const ehAdministrador =
                c.criador &&
                (c.criador.idUsuario || c.criador.id) == idUsuarioLogado;

            div.style.setProperty('--community-color', c.cor || '#EA3F74');
            const imagemComunidade = c.imagemComunidade ? `style="background-image:url('${this.urlCapaEvento(c.imagemComunidade)}')"` : '';
            div.innerHTML = `<div class="comunidade-card-top"><div class="comunidade-mark ${c.imagemComunidade ? 'has-image' : ''}" ${imagemComunidade}>${!c.imagemComunidade ? this.escaparHtmlDestaque((c.nome || 'C').charAt(0).toUpperCase()) : ''}</div><span>${this.escaparHtmlDestaque(c.categoria || 'Comunidade')}</span></div><h2>${this.escaparHtmlDestaque(c.nome)}</h2><p>${this.escaparHtmlDestaque(c.descricao || 'Uma comunidade para trocar ideias e viver experiências.')}</p><div class="comunidade-stats"><span>👥 ${c.membros ? c.membros.length : 0} membros</span><span>🎟 ${eventosPorComunidade[idCom] || 0} eventos</span></div><div class="comunidade-card-footer"><span>Por ${this.escaparHtmlDestaque(c.criador?.nome || 'Administrador')}</span><button class="btn-primary" onclick="app.entrarSubreddit(${idCom})">Acessar</button>${ehAdministrador ? `<button class="btn-compact" onclick="app.gerenciarComunidade(${idCom})">Gerenciar</button>` : ''}</div>`;

            div.addEventListener('click', evento => {
                if (!evento.target.closest('button')) this.entrarSubreddit(idCom);
            });

            container.appendChild(div);
        });
    }

    filtrarComunidades() {
        const termo = document.getElementById('comunidades-search')?.value.toLowerCase() || '';
        const ordem = document.getElementById('comunidades-ordenacao')?.value;
        let comunidades = this.listaComunidades.filter(c => `${c.nome} ${c.descricao} ${c.categoria || ''}`.toLowerCase().includes(termo));
        if (ordem === 'membros') comunidades.sort((a, b) => (b.membros?.length || 0) - (a.membros?.length || 0));
        if (ordem === 'recentes') comunidades = comunidades.reverse();
        this.renderizarComunidades(comunidades);
    }

    async criarComunidade() {
        if (!ApiService.getUsuarioLogado()) return alert("Faça login primeiro.");

        const nome = document.getElementById('comunidade-nome').value.trim();
        const desc = document.getElementById('comunidade-desc').value.trim();
        const categoria = document.getElementById('comunidade-categoria').value;
        const cor = document.getElementById('comunidade-cor').value;
        const imagem = document.getElementById('comunidade-imagem').files[0];
        const criadorId = ApiService.getIdUsuarioLogado();

        const res = await ApiService.criarComunidadeAPI(nome, desc, criadorId, categoria, cor);

        if (res.ok) {
            const comunidadeCriada = await res.json();
            if (imagem) await ApiService.enviarImagemComunidade(comunidadeCriada.id, imagem);
            this.fecharModal('comunidade-modal');
            document.getElementById('comunidade-nome').value = '';
            document.getElementById('comunidade-desc').value = '';
            document.getElementById('comunidade-categoria').value = '';
            document.getElementById('comunidade-cor').value = '#EA3F74';
            document.getElementById('comunidade-imagem').value = '';
            this.carregarComunidades();
        } else {
            alert("Não foi possível criar a comunidade.");
        }
    }

    entrarSubreddit(id, nome, desc) {
        this.salvarViewAtual('subreddit');

        sessionStorage.setItem(
            'comunidadeAtivaId',
            id
        );

        const usuarioLogado = ApiService.getIdUsuarioLogado();
        const botao = document.getElementById("btn-participar");

        this.comunidadeAtivaId = id;

        const comunidade = this.listaComunidades.find(
            c => (c.idComunidade || c.id) == id
        );

        nome = comunidade?.nome || nome;
        desc = comunidade?.descricao || desc;

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
                botao.style.background = "var(--danger)";
            } else {
                botao.innerText = "Entrar";
                botao.style.background = "var(--text-main)";
            }
        }

        // Estas linhas precisam ficar FORA do if/else
        // porque todo usuário deve conseguir acessar a comunidade.
        document.getElementById('sub-titulo').innerText = nome;
        document.getElementById('sub-desc').innerText = desc;
        const visual = document.getElementById('sub-community-visual');
        if (visual) {
            visual.style.backgroundColor = comunidade?.cor || '#EA3F74';
            visual.style.backgroundImage = comunidade?.imagemComunidade ? `url('${this.urlCapaEvento(comunidade.imagemComunidade)}')` : '';
            visual.innerText = comunidade?.imagemComunidade ? '' : (nome || 'C').charAt(0).toUpperCase();
        }

        document.querySelectorAll('.view-section')
            .forEach(el => el.classList.remove('active'));

        document.getElementById('view-subreddit')
            .classList.add('active');

        this.renderizarSubreddit(id);
        this.mudarAbaComunidade('posts');
    }

    mudarAbaComunidade(aba) {
        document.querySelectorAll('.comunidade-tab').forEach(tab => tab.classList.remove('active'));
        document.getElementById(`comunidade-tab-${aba}`)?.classList.add('active');
        if (aba === 'posts') return this.renderizarSubreddit(this.comunidadeAtivaId);
        if (aba === 'membros') {
            const comunidade = this.listaComunidades.find(c => (c.idComunidade || c.id) == this.comunidadeAtivaId);
            this.montarMembrosComunidade(comunidade?.membros || []);
            return;
        }
        const eventos = this.listaEventos.filter(evento => evento.comunidadeId == this.comunidadeAtivaId);
        const container = document.getElementById('subreddit-feed-container');
        container.innerHTML = eventos.length ? eventos.map(evento => `<div class="comunidade-evento-item"><div><span>${evento.dataEvento || ''}</span><strong>${this.escaparHtmlDestaque(evento.titulo)}</strong><small>${this.escaparHtmlDestaque(evento.localEvento || 'Local a confirmar')}</small></div><button class="btn-primary" onclick="app.abrirDetalhesEvento(${evento.id})">Ver evento</button></div>`).join('') : '<div class="comunidade-empty">Esta comunidade ainda não tem eventos.</div>';
    }

    montarMembrosComunidade(membros) {
        const container = document.getElementById('subreddit-feed-container');
        container.innerHTML = membros.length ? `<div class="membros-grid">${membros.map(membro => `<div class="membro-card"><div class="avatar">${this.escaparHtmlDestaque((membro.nome || 'U').charAt(0).toUpperCase())}</div><strong>${this.escaparHtmlDestaque(membro.nome || 'Usuário')}</strong><span>@${this.escaparHtmlDestaque(membro.username || '')}</span></div>`).join('')}</div>` : '<div class="comunidade-empty">Nenhum membro encontrado.</div>';
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
                    `${ApiService.API_URL}/comunidades/${this.comunidadeAtivaId}/participar/${idLogado}`,
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
                btn.style.background = "var(--danger)";
            } else {
                btn.innerText = "Entrar";
                btn.style.background = "var(--text-main)";
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
        let posts = [...this.posts];
        const idUsuario = ApiService.getIdUsuarioLogado();
        const imagem = document.getElementById("editar-comunidade-imagem")?.files?.[0];

        if (this.filtroFeed === 'comunidades') posts = posts.filter(post => post.idComunidade || post.id_comunidade);
        if (this.filtroFeed === 'meus') posts = posts.filter(post => (post.idUsuario || post.id_usuario) == idUsuario);
        if (this.ordenacaoFeed === 'comentados') posts.sort((a, b) => (this.comentariosPorPost[b.idPost || b.id] || []).length - (this.comentariosPorPost[a.idPost || a.id] || []).length);
        if (this.ordenacaoFeed === 'curtidos') posts.sort((a, b) => this.contarVotos(b.idPost || b.id) - this.contarVotos(a.idPost || a.id));

        this.montarCardsPosts(posts, 'feed-container', true);
    }

    mudarFiltroFeed(filtro) {
        this.filtroFeed = filtro;
        document.querySelectorAll('.feed-tab').forEach(tab => tab.classList.remove('active'));
        document.getElementById(`feed-tab-${filtro}`)?.classList.add('active');
        this.renderizarFeedGeral();
    }

    mudarOrdenacaoFeed(ordenacao) {
        this.ordenacaoFeed = ordenacao;
        this.renderizarFeedGeral();
    }

    contarVotos(idPost) {
        return this.votos.filter(voto => voto.idPost == idPost && voto.tipo === 'like').length;
    }

    votoDoUsuario(idPost) {
        const idUsuario = ApiService.getIdUsuarioLogado();
        return this.votos.find(voto => voto.idPost == idPost && voto.idUsuario == idUsuario && voto.tipo === 'like');
    }

    postEstaSalvo(idPost) {
        const idUsuario = ApiService.getIdUsuarioLogado();
        return this.postsSalvos.find(post => post.idPost == idPost && post.idUsuario == idUsuario);
    }

    async alternarCurtida(idPost) {
        const idUsuario = ApiService.getIdUsuarioLogado();
        if (!idUsuario) return alert('Faça login para curtir publicações.');
        const voto = this.votoDoUsuario(idPost);
        const resposta = voto
            ? await ApiService.deletarVoto(voto.idVoto)
            : await ApiService.criarVoto(idUsuario, idPost);
        if (!resposta.ok) return alert('Não foi possível atualizar a curtida.');
        this.votos = voto ? this.votos.filter(item => item.idVoto !== voto.idVoto) : [...this.votos, await resposta.json()];
        this.renderizarFeedGeral();
    }

    async alternarPostSalvo(idPost) {
        const idUsuario = ApiService.getIdUsuarioLogado();
        if (!idUsuario) return alert('Faça login para salvar publicações.');
        const salvo = this.postEstaSalvo(idPost);
        const resposta = salvo
            ? await ApiService.removerPostSalvo(salvo.id)
            : await ApiService.salvarPost(idUsuario, idPost);
        if (!resposta.ok) return alert('Não foi possível atualizar os salvos.');
        this.postsSalvos = salvo ? this.postsSalvos.filter(item => item.id !== salvo.id) : [...this.postsSalvos, await resposta.json()];
        this.renderizarFeedGeral();
    }

    async carregarEventosFeed() {
        const container = document.getElementById('feed-eventos-destaque');
        if (!container) return;
        try {
            const resultado = await ApiService.buscarEventos({ status: 'AGENDADO', page: 0, size: 6 });
            const eventos = this.ordenarPorInteresses(resultado.content || []).slice(0, 3);
            container.innerHTML = eventos.length ? eventos.map(evento => `<button class="feed-evento-item" onclick="app.abrirDetalhesEvento(${evento.id})"><span>${evento.dataEvento ? evento.dataEvento.split('-').reverse().join('/') : '--'}</span><strong>${this.escaparHtmlDestaque(evento.titulo)}</strong><small>${this.escaparHtmlDestaque(evento.localEvento || 'Local a confirmar')}</small></button>`).join('') : '<p class="feed-sidebar-empty">Nenhum evento agendado.</p>';
        } catch (erro) {
            container.innerHTML = '<p class="feed-sidebar-empty">Agenda indisponível no momento.</p>';
        }
    }

    // --- FUNÇÕES DE POSTS/COMENTARIOS REUTILIZÁVEIS ---
    async enviarPost() {
        const idLogado = ApiService.getIdUsuarioLogado();
        const titulo = document.getElementById('post-titulo').value.trim();
        const conteudo = document.getElementById('post-conteudo').value.trim();
        const comunidadeSelecionada = document.getElementById('post-comunidade-id')?.value;

        // Se this.comunidadeAtivaId existir, envia o post vinculado à comunidade
        const res = await ApiService.criarPost(titulo, conteudo, idLogado, comunidadeSelecionada || null);
        if (res.ok) {
            this.fecharModal('post-modal');
            document.getElementById('post-titulo').value = '';
            document.getElementById('post-conteudo').value = '';
            document.getElementById('post-comunidade-id').value = '';
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
            let fotoAutor = this.usuariosFotosMap[idAutor];
            let urlFotoAutor = ApiService.formatarUrlFotoPerfil(fotoAutor);
            let inicial = (nomeAutor || 'U').charAt(0).toUpperCase();

            let avatarHtml = urlFotoAutor
                ? `<img src="${urlFotoAutor}" class="avatar" style="object-fit:cover;" onerror="this.outerHTML='<div class=\\'avatar\\'>${inicial}</div>'">`
                : `<div class="avatar">${inicial}</div>`;

            let nomeComunidade = this.comunidadesMap[idComunidade];
            let dataPostagem = post.dataPostagem
                ? new Date(post.dataPostagem).toLocaleDateString('pt-BR')
                : 'Agora';

            const comentarios = this.comentariosPorPost[idPost] || [];
            let htmlComentarios = comentarios.slice(0, 2).map(c =>
                `<div class="comment-preview"><span>${this.escaparHtmlDestaque(this.usuariosMap[c.idUsuario || c.id_usuario] || 'User')}:</span>${this.escaparHtmlDestaque(c.conteudo)}</div>`
            ).join('');
            if (comentarios.length > 2) {
                htmlComentarios += `<button class="comments-more" onclick="app.abrirDetalhesPost(${idPost})">Ver todos os ${comentarios.length} comentários</button>`;
            }

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
            div.className = 'card post-card';
            div.tabIndex = 0;
            div.setAttribute('role', 'link');
            div.setAttribute('aria-label', `Abrir publicação: ${post.titulo}`);
            const curtido = this.votoDoUsuario(idPost);
            const salvo = this.postEstaSalvo(idPost);
            const totalCurtidas = this.contarVotos(idPost);
            div.innerHTML = `
                <div class="post-header-area">
                    ${avatarHtml}
                    <div>
                        <span class="post-author">${this.escaparHtmlDestaque(nomeAutor)}</span>
                        <div class="post-meta">${mostrarTagComunidade && nomeComunidade ? `em c/${this.escaparHtmlDestaque(nomeComunidade)}` : 'Feed global'} · ${dataPostagem}</div>
                    </div>
                    <button class="post-more" aria-label="Mais opções"><i class="material-icons">more_horiz</i></button>
                </div>
                <div class="post-title">${this.escaparHtmlDestaque(post.titulo)}</div>
               <div class="post-body">${this.escaparHtmlDestaque(post.conteudo)}</div>
               ${htmlComentarios}

                <div class="post-actions">
                    <button class="post-action ${curtido ? 'active' : ''}" onclick="app.alternarCurtida(${idPost})"><i class="material-icons">${curtido ? 'favorite' : 'favorite_border'}</i><span>${totalCurtidas}</span></button>
                    <button class="post-action" onclick="document.getElementById('comentario-${idPost}').focus()"><i class="material-icons">chat_bubble_outline</i><span>${comentarios.length}</span></button>
                    <button class="post-action ${salvo ? 'active' : ''}" onclick="app.alternarPostSalvo(${idPost})"><i class="material-icons">${salvo ? 'bookmark' : 'bookmark_border'}</i></button>
                </div>

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
                       <input id="comentario-${idPost}" type="text" placeholder="Escreva um comentário..." onkeydown="if(event.key === 'Enter') app.enviarComentario(${idPost}, this.nextElementSibling)">
<button onclick="app.enviarComentario(${idPost}, this)">Enviar</button>
                    </div>` : ''}
            `;
            div.addEventListener('click', evento => {
                if (evento.target.closest('button, input, textarea, select')) return;
                this.abrirDetalhesPost(idPost);
            });
            div.addEventListener('keydown', evento => {
                if (evento.key !== 'Enter' && evento.key !== ' ') return;
                evento.preventDefault();
                this.abrirDetalhesPost(idPost);
            });
            container.appendChild(div);
        });
    }

    async abrirDetalhesPost(idPost) {
        let post = this.posts.find(item => (item.idPost || item.id) == idPost);
        if (!post) {
            try {
                post = await ApiService.buscarPostPorId(idPost);
            } catch (erro) {
                return alert('Não foi possível abrir a publicação.');
            }
        }

        const container = document.getElementById('post-detalhes-conteudo');
        if (!container) return;

        // Busca comentários atualizados sob demanda para este post
        try {
            const comentariosPost = await ApiService.listarComentariosPorPost(idPost);
            if (comentariosPost && comentariosPost.length) {
                this.comentariosPorPost[idPost] = comentariosPost;
            }
        } catch (_) { }

        const idAutor = post.idUsuario || post.id_usuario;
        const nomeAutor = this.usuariosMap[idAutor] || 'Desconhecido';
        const fotoAutor = this.usuariosFotosMap[idAutor];
        const urlFotoAutor = ApiService.formatarUrlFotoPerfil(fotoAutor);
        const inicialAutor = (nomeAutor || 'U').charAt(0).toUpperCase();

        const avatarHeaderHtml = urlFotoAutor
            ? `<img src="${urlFotoAutor}" class="avatar" style="object-fit:cover;" onerror="this.outerHTML='<div class=\\'avatar\\'>${inicialAutor}</div>'">`
            : `<div class="avatar">${inicialAutor}</div>`;

        const idComunidade = post.idComunidade || post.id_comunidade;
        const nomeComunidade = this.comunidadesMap[idComunidade];
        const comentarios = this.comentariosPorPost[idPost] || [];
        const curtido = this.votoDoUsuario(idPost);
        const salvo = this.postEstaSalvo(idPost);
        const dataPostagem = post.dataPostagem
            ? new Date(post.dataPostagem).toLocaleDateString('pt-BR')
            : 'Agora';

        container.innerHTML = `
            <article class="post-detail-card">
                <div class="post-detail-header">
                    ${avatarHeaderHtml}
                    <div><strong>${this.escaparHtmlDestaque(nomeAutor)}</strong><span>${nomeComunidade ? `em c/${this.escaparHtmlDestaque(nomeComunidade)}` : 'Feed global'} · ${dataPostagem}</span></div>
                </div>
                <h1>${this.escaparHtmlDestaque(post.titulo)}</h1>
                <div class="post-detail-body">${this.escaparHtmlDestaque(post.conteudo)}</div>
                <div class="post-actions post-detail-actions">
                    <button class="post-action ${curtido ? 'active' : ''}" onclick="app.alternarCurtidaDetalhe(${idPost})"><i class="material-icons">${curtido ? 'favorite' : 'favorite_border'}</i><span>${this.contarVotos(idPost)}</span></button>
                    <button class="post-action ${salvo ? 'active' : ''}" onclick="app.alternarPostSalvoDetalhe(${idPost})"><i class="material-icons">${salvo ? 'bookmark' : 'bookmark_border'}</i><span>${salvo ? 'Salvo' : 'Salvar'}</span></button>
                </div>
                <section class="post-comments-section">
                    <div class="post-comments-heading"><h2>Comentários</h2><span>${comentarios.length}</span></div>
                    ${ApiService.getIdUsuarioLogado() ? `<div class="detail-comment-box"><input id="comentario-detalhe-${idPost}" type="text" placeholder="Escreva um comentário..." onkeydown="if(event.key === 'Enter') app.enviarComentarioDetalhe(${idPost})"><button onclick="app.enviarComentarioDetalhe(${idPost})">Comentar</button></div>` : '<p class="comments-login-note">Entre para participar da conversa.</p>'}
                    <div class="post-detail-comments">${comentarios.length ? comentarios.map(c => {
            const idC = c.idUsuario || c.id_usuario;
            const nomeC = this.usuariosMap[idC] || 'Usuário';
            const fotoC = this.usuariosFotosMap[idC];
            const urlFotoC = ApiService.formatarUrlFotoPerfil(fotoC);
            const iniC = (nomeC || 'U').charAt(0).toUpperCase();
            const avC = urlFotoC
                ? `<img src="${urlFotoC}" class="avatar detail-comment-avatar" style="object-fit:cover;" onerror="this.outerHTML='<div class=\\'avatar detail-comment-avatar\\'>${iniC}</div>'">`
                : `<div class="avatar detail-comment-avatar">${iniC}</div>`;
            return `<div class="detail-comment">${avC}<div><strong>${this.escaparHtmlDestaque(nomeC)}</strong><p>${this.escaparHtmlDestaque(c.conteudo)}</p></div></div>`;
        }).join('') : '<p class="comments-empty">Ainda não há comentários. Seja o primeiro a participar.</p>'}</div>
                </section>
            </article>
        `;

        this.salvarViewAtual('post-detalhes');
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.getElementById('view-post-detalhes').classList.add('active');
        document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));
        document.getElementById('tab-feed')?.classList.add('active');
    }

    async enviarComentarioDetalhe(idPost) {
        const input = document.getElementById(`comentario-detalhe-${idPost}`);
        if (!input) return;
        const conteudo = input.value.trim();
        if (!conteudo) return;
        const resposta = await ApiService.criarComentario(conteudo, ApiService.getIdUsuarioLogado(), idPost);
        if (!resposta.ok) return alert('Não foi possível enviar o comentário.');
        await this.carregarDadosGlobais();
        await this.abrirDetalhesPost(idPost);
    }

    async alternarCurtidaDetalhe(idPost) {
        await this.alternarCurtida(idPost);
        await this.abrirDetalhesPost(idPost);
    }

    async alternarPostSalvoDetalhe(idPost) {
        await this.alternarPostSalvo(idPost);
        await this.abrirDetalhesPost(idPost);
    }

    voltarDoPost() {
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.getElementById('view-feed').classList.add('active');
        document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));
        document.getElementById('tab-feed')?.classList.add('active');
        this.salvarViewAtual('feed');
        this.renderizarFeedGeral();
    }

    // --- ABA BUSCA ---
    filtrarUsuarios() {
        const txt = document.getElementById('search-input').value.toLowerCase();
        const filtro = document.getElementById('pessoas-filtro')?.value || 'todas';
        const organizadores = new Set(this.listaEventos.map(evento => String(evento.criadorId)));
        const membros = new Set(this.listaComunidades.flatMap(comunidade => (comunidade.membros || []).map(membro => String(membro.idUsuario || membro.id))));
        const pessoas = this.listaUsuariosCompleta.filter(usuario => {
            const id = String(usuario.idUsuario || usuario.id);
            const correspondeTexto = (usuario.nome || '').toLowerCase().includes(txt) || (usuario.username || '').toLowerCase().includes(txt);
            const correspondeFiltro = filtro === 'organizadores' ? organizadores.has(id) : filtro === 'comunidades' ? membros.has(id) : true;
            return correspondeTexto && correspondeFiltro;
        });
        this.renderizarUsuarios(pessoas);
    }

    renderizarUsuarios(lista) {
        const container = document.getElementById('users-container');
        container.innerHTML = '';
        if (!lista.length) {
            container.innerHTML = '<div class="pessoas-empty">Nenhuma pessoa encontrada com esses filtros.</div>';
            return;
        }
        lista.forEach(u => {
            const div = document.createElement('div');
            div.className = 'pessoa-card';
            div.tabIndex = 0;
            div.setAttribute('role', 'link');
            const id = u.idUsuario || u.id;
            const comunidades = this.listaComunidades.filter(comunidade => (comunidade.membros || []).some(membro => (membro.idUsuario || membro.id) == id));
            const eventos = this.listaEventos.filter(evento => evento.criadorId == id);
            div.innerHTML = `<div class="pessoa-card-main"><div class="avatar">${this.escaparHtmlDestaque((u.nome || 'U').charAt(0).toUpperCase())}</div><div><h2>${this.escaparHtmlDestaque(u.nome || 'Usuário')}</h2><span>@${this.escaparHtmlDestaque(u.username || 'usuario')}</span></div></div><p>${this.escaparHtmlDestaque(u.bio || 'Participa da comunidade SocialJoin.')}</p><div class="pessoa-card-stats"><span>${comunidades.length} comunidade(s)</span><span>${eventos.length} evento(s)</span></div>`;
            div.addEventListener('click', () => this.abrirPerfil(id));
            div.addEventListener('keydown', evento => {
                if (evento.key === 'Enter' || evento.key === ' ') {
                    evento.preventDefault();
                    this.abrirPerfil(id);
                }
            });
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

            let eventos = resultado.content || [];

            const categoria = document.getElementById('filtro-evento-categoria')?.value;
            const formato = document.getElementById('filtro-evento-formato')?.value;

            if (formato) {
                eventos = eventos.filter(evento => {
                    const online = /^(https?:\/\/|www\.)/i.test(evento.localEvento || '');
                    return formato === 'online' ? online : !online;
                });
            }

            eventos = this.ordenarPorInteresses(eventos);
            this.listaEventos = eventos;
            this.totalPaginasEventos = resultado.totalPages;
            this.renderizarRecomendacoes();
            this.renderizarSugestoesPessoas();

            await this.carregarEventoDestaqueMaisPopular();

            container.innerHTML = '';

            if (eventos.length === 0) {
                container.innerHTML =
                    '<p style="color:var(--text-muted); padding:16px;">Nenhum evento agendado no momento.</p>';
                this.totalPaginasEventos = 0;
                this.atualizarPaginacaoEventos();
                return;
            }

            const grupos = eventos.reduce((acumulado, evento) => {
                const chave = evento.dataEvento || 'sem-data';
                (acumulado[chave] ||= []).push(evento);
                return acumulado;
            }, {});

            for (const [data, eventosDoDia] of Object.entries(grupos)) {
                const grupo = document.createElement('section');
                grupo.className = 'eventos-grupo';
                grupo.innerHTML = `<h2 class="eventos-grupo-titulo">${this.formatarDataEvento(data)}</h2>`;
                const grade = document.createElement('div');
                grade.className = 'eventos-grid';
                grupo.appendChild(grade);
                container.appendChild(grupo);

                for (const evento of eventosDoDia) {

                    const div = document.createElement('div');
                    div.className = 'evento-card';

                    const statusDetalhes =
                        evento.situacaoTemporal ||
                        evento.status ||
                        'AGENDADO';

                    const statusDetalhesExibido =
                        statusDetalhes === 'ACONTECENDO_AGORA'
                            ? 'ACONTECENDO AGORA'
                            : statusDetalhes;
                    const eventoCancelado = statusDetalhes === 'CANCELADO';

                    const statusExibido =
                        statusDetalhes === 'ACONTECENDO_AGORA'
                            ? 'ACONTECENDO AGORA'
                            : statusDetalhes;

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

                    const quantidadeParticipantes =
                        evento.quantidadeParticipantes || 0;
                    const eventoLotado = evento.limiteParticipantes && quantidadeParticipantes >= evento.limiteParticipantes;
                    const idUsuario = ApiService.getIdUsuarioLogado();
                    const ehCriador = idUsuario && idUsuario == evento.criadorId;
                    const acao = ehCriador ? 'Organizador' : eventoLotado ? 'Evento lotado' : idUsuario ? 'Ver detalhes' : 'Entrar para participar';
                    div.innerHTML = `
                    <div class="evento-card-capa ${evento.imagemCapa ? '' : 'evento-card-capa-vazia'}" ${evento.imagemCapa ? `style="background-image:url('${this.urlCapaEvento(evento.imagemCapa)}')"` : ''}>
                        ${!evento.imagemCapa ? '<i class="material-icons">event</i>' : ''}
                        <span>${evento.categoria || 'Comunidade'}</span>
                    </div>
                    <div class="evento-card-body">
                        <div class="evento-card-meta"><span>${horarioInicioFormatado} - ${horarioFimFormatado}</span><b>${statusExibido}</b></div>
                        <h3>${evento.titulo}</h3>
                        <p>${evento.descricao || 'Sem descrição informada.'}</p>
                        <div class="evento-card-info"><span>📍 ${evento.localEvento}</span><span>👥 ${evento.limiteParticipantes ? `${quantidadeParticipantes}/${evento.limiteParticipantes}` : `${quantidadeParticipantes}`} participantes</span></div>
                        <button class="btn-primary evento-card-action" onclick="app.abrirDetalhesEvento(${evento.id})">${acao}</button>
                    </div>
                `;
                    grade.appendChild(div);
                }
            }


        } catch (e) {
            console.error(e);

            container.innerHTML =
                "<p style='padding:16px; color:red;'>Erro ao conectar com a API de Eventos.</p>";
        }
        this.atualizarPaginacaoEventos();
    }

    formatarDataEvento(data) {
        if (!data || data === 'sem-data') return 'Data a confirmar';
        return new Date(`${data}T00:00:00`).toLocaleDateString('pt-BR', {
            weekday: 'long', day: 'numeric', month: 'long'
        });
    }

    renderizarEventoDestaque(evento) {
        const container = document.getElementById('evento-destaque');
        if (!container) return;
        if (!evento) {
            container.innerHTML = '<div class="evento-destaque-vazio">Nenhum evento encontrado com esses filtros.</div>';
            return;
        }
        const data = evento.dataEvento ? new Date(`${evento.dataEvento}T00:00:00`).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' }).replace('.', '') : '--';
        container.innerHTML = `
            <div class="evento-destaque-copy"><span class="section-kicker">${evento.categoria || 'Em destaque'}</span><h2>${evento.titulo}</h2><p>${evento.descricao || 'Uma nova experiência está esperando por você.'}</p><div class="evento-destaque-details"><span>📅 ${data} · ${evento.horarioInicio?.substring(0, 5) || '--:--'}</span><span>📍 ${evento.localEvento || 'Local a confirmar'}</span></div><button class="btn-primary" onclick="app.abrirDetalhesEvento(${evento.id})">Ver detalhes <i class="material-icons">arrow_forward</i></button></div><div class="evento-destaque-art" ${evento.imagemCapa ? `style="background-image:linear-gradient(135deg,rgba(43,23,32,.2),rgba(234,63,116,.5)),url('${this.urlCapaEvento(evento.imagemCapa)}');background-size:cover;background-position:center;"` : ''}><i class="material-icons">celebration</i></div>
        `;
    }

    urlCapaEvento(caminho) {
        return caminho?.startsWith('http') ? caminho : `${ApiService.API_URL}/${caminho}`;
    }

    async mudarVisaoEventos(visao) {
        this.visaoEventos = visao;
        document.querySelectorAll('.eventos-tab').forEach(tab => tab.classList.remove('active'));
        document.getElementById(`eventos-tab-${visao}`)?.classList.add('active');
        if (visao === 'meus') {
            await this.carregarMeusEventos();
        } else {
            await this.carregarEventos();
        }
    }

    async carregarMeusEventos() {
        const container = document.getElementById('eventos-container');
        if (!container) return;
        const idUsuario = ApiService.getIdUsuarioLogado();
        if (!idUsuario) {
            container.innerHTML = '<div class="evento-destaque-vazio">Entre para acompanhar os eventos dos quais você participa.</div>';
            return;
        }
        container.innerHTML = 'Carregando seus eventos...';
        try {
            const eventos = await ApiService.listarEventosParticipando(idUsuario);
            this.listaEventos = eventos;
            await this.carregarEventoDestaqueMaisPopular();
            container.innerHTML = eventos.length ? eventos.map(evento => `<div class="meu-evento-row"><div><strong>${evento.titulo}</strong><span>${this.formatarDataEvento(evento.dataEvento)} · ${evento.localEvento}</span></div><button class="btn-primary" onclick="app.abrirDetalhesEvento(${evento.id})">Ver evento</button></div>`).join('') : '<div class="evento-destaque-vazio">Você ainda não está participando de nenhum evento.</div>';
        } catch (erro) {
            console.error(erro);
            container.innerHTML = '<div class="evento-destaque-vazio">Não foi possível carregar seus eventos.</div>';
        }
    }

    async criarEvento() {
        const idUsuario = ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            this.fecharModal('evento-modal');
            this.definirModoAuth(false);
            this.abrirModal('auth-modal');
            this.mostrarAuthFeedback("Faça login para organizar um evento!");
            return;
        }

        const titulo =
            document.getElementById('evento-titulo').value.trim();
        const descricao =
            document.getElementById('evento-desc').value.trim();
        const categoria =
            document.getElementById('evento-categoria').value;
        const capa =
            document.getElementById('evento-capa').files[0];
        const dataEvento =
            document.getElementById('evento-data').value;
        const horarioInicio =
            document.getElementById('evento-horario-inicio').value;
        const horarioFim =
            document.getElementById('evento-horario-fim').value;
        const encerramentoInscricoes =
            document.getElementById('evento-encerramento-inscricoes').value;
        const localEvento =
            document.getElementById('evento-local').value.trim();
        const comunidadeValor =
            document.getElementById('evento-comunidade-id').value;
        const limiteValor =
            document.getElementById('evento-limite').value;
        const exigeCheckin =
            document.getElementById('evento-checkin').checked;

        this.mostrarEventoFeedback('');

        if (!titulo || !dataEvento || !horarioInicio || !horarioFim || !localEvento) {
            return this.mostrarEventoFeedback(
                "Preencha todos os campos obrigatórios (Título, Categoria, Data, Horários e Local)."
            );
        }

        if (!categoria) {
            return this.mostrarEventoFeedback("Selecione uma categoria para o evento.");
        }

        const inicioEvento = new Date(`${dataEvento}T${horarioInicio}`);
        const fimEvento = new Date(`${dataEvento}T${horarioFim}`);
        const agora = new Date();

        if (fimEvento <= inicioEvento) {
            return this.mostrarEventoFeedback(
                "O horário de término deve ser posterior ao horário de início."
            );
        }

        if (inicioEvento <= agora) {
            return this.mostrarEventoFeedback(
                "A data e horário de início não podem estar no passado."
            );
        }

        if (encerramentoInscricoes) {
            const fimInscricoes = new Date(encerramentoInscricoes);
            if (fimInscricoes > inicioEvento) {
                return this.mostrarEventoFeedback(
                    "O encerramento das inscrições não pode acontecer após o início do evento."
                );
            }
            if (fimInscricoes <= agora) {
                return this.mostrarEventoFeedback(
                    "O encerramento das inscrições deve estar em uma data e horário futuros."
                );
            }
        }

        if (limiteValor && parseInt(limiteValor) < 1) {
            return this.mostrarEventoFeedback(
                "O limite de participantes deve ser de pelo menos 1 pessoa."
            );
        }

        const novoEvento = {
            titulo,
            descricao,
            categoria: categoria || null,
            dataEvento,
            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",
            encerramentoInscricoes: encerramentoInscricoes
                ? encerramentoInscricoes + ":00"
                : null,
            localEvento,
            criadorId: parseInt(idUsuario),
            comunidadeId: comunidadeValor
                ? parseInt(comunidadeValor)
                : null,
            limiteParticipantes: limiteValor
                ? parseInt(limiteValor)
                : null,
            exigeCheckin
        };

        try {
            this.definirEventoLoading(true);

            const res = await ApiService.criarEventoAPI(novoEvento);

            if (res.ok) {
                const eventoCriado = await res.json();
                const eventoId = eventoCriado.id || eventoCriado.idEvento;
                if (capa && eventoId) {
                    try {
                        await ApiService.enviarCapaEvento(eventoId, capa);
                    } catch (capaErr) {
                        console.error("Erro ao enviar capa do evento:", capaErr);
                    }
                }

                this.fecharModal('evento-modal');
                this.limparFormularioEvento();
                await this.carregarEventos();
                alert("🎉 Evento publicado com sucesso!");
            } else {
                this.mostrarEventoFeedback("Não foi possível criar o evento. Verifique os dados e tente novamente.");
            }
        } catch (error) {
            console.error(error);
            this.mostrarEventoFeedback("Erro de conexão ao criar o evento. Tente novamente.");
        } finally {
            this.definirEventoLoading(false);
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
        document.getElementById("editar-comunidade-categoria").value = comunidade.categoria || '';
        document.getElementById("editar-comunidade-cor").value = comunidade.cor || '#EA3F74';

        this.abrirModal("gerenciar-comunidade-modal");
    }

    async salvarEdicaoComunidade() {

        const nome = document.getElementById("editar-comunidade-nome").value.trim();
        const descricao = document.getElementById("editar-comunidade-desc").value.trim();
        const categoria = document.getElementById("editar-comunidade-categoria").value;
        const cor = document.getElementById("editar-comunidade-cor").value;

        const idComunidade =
            this.comunidadeEditando.idComunidade || this.comunidadeEditando.id;

        const idUsuario = ApiService.getIdUsuarioLogado();
        const imagem = document.getElementById("editar-comunidade-imagem")?.files?.[0];

        const resposta = await ApiService.atualizarComunidade(
            idComunidade,
            idUsuario,
            nome,
            descricao,
            categoria,
            cor
        );

        if (resposta.ok) {
            if (imagem) await ApiService.enviarImagemComunidade(idComunidade, imagem);
            this.fecharModal("gerenciar-comunidade-modal");
            document.getElementById("editar-comunidade-imagem").value = '';

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

        document.getElementById('editar-evento-categoria').value =
            evento.categoria || '';

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

        document.getElementById('editar-evento-encerramento-inscricoes').value =
            evento.encerramentoInscricoes
                ? evento.encerramentoInscricoes.substring(0, 16)
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

        const categoria =
            document.getElementById('editar-evento-categoria').value;

        const dataEvento =
            document.getElementById('editar-evento-data').value;

        const horarioInicio =
            document.getElementById('editar-evento-horario-inicio').value;

        const horarioFim =
            document.getElementById('editar-evento-horario-fim').value;

        const encerramentoInscricoes =
            document.getElementById(
                'editar-evento-encerramento-inscricoes'
            ).value;

        const localEvento =
            document.getElementById('editar-evento-local').value.trim();

        const comunidadeValor =
            document.getElementById('editar-evento-comunidade').value;

        const limiteValor =
            document.getElementById('editar-evento-limite').value;

        const exigeCheckin =
            document.getElementById('editar-evento-checkin').checked;

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

        const inicioEvento = new Date(
            `${dataEvento}T${horarioInicio}`
        );

        const fimEvento = new Date(
            `${dataEvento}T${horarioFim}`
        );

        if (fimEvento <= inicioEvento) {
            return alert(
                "O horário de fim deve ser depois do horário de início."
            );
        }

        if (encerramentoInscricoes) {

            const fimInscricoes =
                new Date(encerramentoInscricoes);

            if (fimInscricoes > inicioEvento) {
                return alert(
                    "O encerramento das inscrições não pode acontecer depois do início do evento."
                );
            }
        }

        const eventoAtualizado = {
            titulo,
            descricao,
            categoria: categoria || null,
            dataEvento,

            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",

            encerramentoInscricoes:
                encerramentoInscricoes
                    ? encerramentoInscricoes + ":00"
                    : null,

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

            await this.abrirDetalhesEvento(idEvento);

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

            await this.abrirDetalhesEvento(idEvento);

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

        const categoria =
            document.getElementById('filtro-evento-categoria')
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

            categoria:
                categoria || null,

            dataInicio,
            dataFim
        };

        this.paginaEventos = 0;

        if (this.visaoEventos === 'meus') await this.carregarMeusEventos();
        else await this.carregarEventos();
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

        this.salvarViewAtual('evento-detalhes');

        sessionStorage.setItem(
            'eventoDetalhesId',
            idEvento
        );

        let evento = this.listaEventos.find(
            e => (e.idEvento || e.id) == idEvento
        );

        if (!evento) {
            try {
                evento =
                    await ApiService.buscarEventoPorId(idEvento);
            } catch (erro) {
                console.error(erro);
                return alert("Não foi possível abrir este evento.");
            }
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

        let limiteInscricao;

        if (evento.encerramentoInscricoes) {
            limiteInscricao = new Date(evento.encerramentoInscricoes);
        } else {
            limiteInscricao = new Date(
                `${evento.dataEvento}T${evento.horarioInicio}`
            );
        }

        const inscricoesEncerradas =
            new Date() >= limiteInscricao;

        const situacaoEvento =
            evento.situacaoTemporal ||
            evento.status ||
            'AGENDADO';

        const situacaoEventoExibida =
            situacaoEvento === 'ACONTECENDO_AGORA'
                ? 'ACONTECENDO AGORA'
                : situacaoEvento;

        const eventoEncerrado =
            situacaoEvento === 'ENCERRADO';

        const container =
            document.getElementById('evento-detalhes-conteudo');

        const statusClasse =
            situacaoEvento === 'CANCELADO'
                ? 'cancelado'
                : situacaoEvento === 'ENCERRADO'
                    ? 'encerrado'
                    : situacaoEvento === 'ACONTECENDO_AGORA'
                        ? 'agora'
                        : 'agendado';

        const limiteParticipantesTexto =
            evento.limiteParticipantes
                ? `${quantidadeParticipantes} de ${evento.limiteParticipantes}`
                : `${quantidadeParticipantes}`;

        const limiteInscricaoFormatado =
            limiteInscricao.toLocaleString('pt-BR', {
                dateStyle: 'short',
                timeStyle: 'short'
            });

        container.innerHTML = `
    <article class="evento-detalhes-card">

        ${evento.imagemCapa
                ? `
                <div
                    class="evento-detalhes-hero"
                    style="
                        background-image:
                        url('${this.urlCapaEvento(evento.imagemCapa)}');
                    "
                >
                    <div class="evento-detalhes-hero-overlay"></div>

                    ${evento.categoria
                    ? `
                            <span class="evento-detalhes-categoria">
                                ${this.escaparHtmlDestaque(evento.categoria)}
                            </span>
                        `
                    : ''
                }
                </div>
            `
                : `
                <div class="evento-detalhes-hero evento-detalhes-hero-vazio">
                    <i class="material-icons">event</i>

                    ${evento.categoria
                    ? `
                            <span class="evento-detalhes-categoria">
                                ${this.escaparHtmlDestaque(evento.categoria)}
                            </span>
                        `
                    : ''
                }
                </div>
            `
            }

        <div class="evento-detalhes-conteudo">

            <header class="evento-detalhes-header">

                <div class="evento-detalhes-titulo-area">

                    <span class="evento-detalhes-kicker">
                        <i class="material-icons">event_available</i>
                        Evento
                    </span>

                    <h1>
                        ${this.escaparHtmlDestaque(evento.titulo || 'Evento')}
                    </h1>

                    <p class="evento-detalhes-organizador">
                        Organizado por
                        <strong>
                            ${this.escaparHtmlDestaque(nomeCriador)}
                        </strong>
                    </p>

                </div>

                <span class="
                    evento-status-badge
                    ${statusClasse}
                ">
                    ${situacaoEventoExibida}
                </span>

            </header>


            <section class="evento-detalhes-resumo">

                <div class="evento-info-card">
                    <div class="evento-info-icon">
                        <i class="material-icons">
                            calendar_today
                        </i>
                    </div>

                    <div>
                        <span>Data</span>
                        <strong>
                            ${dataFormatada || 'A confirmar'}
                        </strong>
                    </div>
                </div>


                <div class="evento-info-card">
                    <div class="evento-info-icon">
                        <i class="material-icons">
                            schedule
                        </i>
                    </div>

                    <div>
                        <span>Horário</span>
                        <strong>
                            ${horarioInicioFormatado}
                            às
                            ${horarioFimFormatado}
                        </strong>
                    </div>
                </div>


                <div class="evento-info-card">
                    <div class="evento-info-icon">
                        <i class="material-icons">
                            place
                        </i>
                    </div>

                    <div>
                        <span>Local</span>
                        <strong>
                            ${this.escaparHtmlDestaque(
                evento.localEvento ||
                'A confirmar'
            )}
                        </strong>
                    </div>
                </div>


                <div class="evento-info-card">
                    <div class="evento-info-icon">
                        <i class="material-icons">
                            groups
                        </i>
                    </div>

                    <div>
                        <span>Participantes</span>
                        <strong>
                            ${limiteParticipantesTexto}
                        </strong>
                    </div>
                </div>

            </section>


            <section class="evento-detalhes-section">

                <div class="evento-detalhes-section-title">
                    <i class="material-icons">
                        subject
                    </i>

                    <div>
                        <span>Sobre o evento</span>
                        <small>
                            Informações e descrição
                        </small>
                    </div>
                </div>

                <p class="evento-detalhes-descricao">
                    ${this.escaparHtmlDestaque(
                evento.descricao ||
                'Nenhuma descrição foi adicionada para este evento.'
            )}
                </p>

            </section>


            <section class="evento-detalhes-section">

                <div class="evento-detalhes-section-title">
                    <i class="material-icons">
                        info
                    </i>

                    <div>
                        <span>Informações adicionais</span>
                        <small>
                            Participação e acesso
                        </small>
                    </div>
                </div>

                <div class="evento-detalhes-adicionais">

                    ${nomeComunidade
                ? `
                            <div class="evento-detalhe-linha">
                                <i class="material-icons">
                                    forum
                                </i>

                                <div>
                                    <span>Comunidade</span>
                                    <strong>
                                        ${this.escaparHtmlDestaque(nomeComunidade)}
                                    </strong>
                                </div>
                            </div>
                        `
                : ''
            }

                    <div class="evento-detalhe-linha">
                        <i class="material-icons">
                            confirmation_number
                        </i>

                        <div>
                            <span>Controle de entrada</span>
                            <strong>
                                ${evento.exigeCheckin
                ? 'Check-in obrigatório pelo aplicativo'
                : 'Check-in não obrigatório'
            }
                            </strong>
                        </div>
                    </div>


                    <div class="evento-detalhe-linha">
                        <i class="material-icons">
                            event_busy
                        </i>

                        <div>
                            <span>Inscrições até</span>
                            <strong>
                                ${limiteInscricaoFormatado}
                            </strong>
                        </div>
                    </div>

                </div>

            </section>


            <footer class="evento-detalhes-footer">

                <div class="evento-detalhes-footer-texto">
                    <span>Participação</span>

                    <strong>
                        ${eventoCancelado
                ? 'Este evento foi cancelado'
                : eventoEncerrado
                    ? 'Este evento já foi encerrado'
                    : usuarioParticipa
                        ? 'Você está participando deste evento'
                        : 'Garanta sua participação'
            }
                    </strong>
                </div>


                <div class="evento-detalhes-actions">

                    ${!eventoCancelado &&
                !eventoEncerrado &&
                idUsuarioLogado &&
                !ehCriador
                ? usuarioParticipa
                    ? `
                                <button
                                    type="button"
                                    class="evento-action-secondary"
                                    onclick="app.sairDoEvento(${idEvento})"
                                >
                                    <i class="material-icons">
                                        logout
                                    </i>

                                    Sair do evento
                                </button>
                            `
                    : inscricoesEncerradas
                        ? `
                                    <button
                                        type="button"
                                        class="evento-action-disabled"
                                        disabled
                                    >
                                        Inscrições encerradas
                                    </button>
                                `
                        : eventoLotado
                            ? `
                                        <button
                                            type="button"
                                            class="evento-action-disabled"
                                            disabled
                                        >
                                            Evento lotado
                                        </button>
                                    `
                            : `
                                       <button
    type="button"
    class="btn-primary evento-participar-btn"
    onclick="app.participarEvento(${idEvento})">
    <i class="material-icons">person_add_alt</i>
    <span>Participar</span>
</button>
                                    `
                : ''
            }


                    ${ehCriador
                ? `
                            <button
                                type="button"
                                class="evento-action-primary"
                                onclick="app.gerenciarEvento(${idEvento})"
                            >
                                <i class="material-icons">
                                    settings
                                </i>

                                Gerenciar evento
                            </button>
                        `
                : ''
            }

                </div>

            </footer>

        </div>

    </article>
`;
        document.querySelectorAll('.view-section')
            .forEach(el => el.classList.remove('active'));

        document.getElementById('view-evento-detalhes')
            .classList.add('active');
    }

    voltarParaEventos() {
        this.mudarAba('eventos');
    }

    async abrirPerfil(idUsuario) {

        this.salvarViewAtual('perfil');
        sessionStorage.setItem(
            'perfilUsuarioId',
            idUsuario
        );

        try {

            const viewAtual =
                document.querySelector('.view-section.active');

            if (viewAtual && viewAtual.id !== 'view-perfil') {
                this.viewAntesDoPerfil =
                    viewAtual.id.replace('view-', '');
            }

            const usuario =
                await ApiService.buscarUsuarioPorId(idUsuario);

            const postsUsuario =
                await ApiService.listarPostsPorUsuario(idUsuario);

            const idLogado =
                ApiService.getIdUsuarioLogado();

            const ehProprioPerfil =
                idLogado && idLogado == idUsuario;

            const inicial =
                usuario.nome
                    ? usuario.nome.charAt(0).toUpperCase()
                    : '?';

            const container =
                document.getElementById('perfil-conteudo');
            const comunidadesUsuario = this.listaComunidades.filter(comunidade => (comunidade.membros || []).some(membro => (membro.idUsuario || membro.id) == idUsuario));
            const eventosUsuario = this.listaEventos.filter(evento => evento.criadorId == idUsuario);

            container.innerHTML = `
    <div class="card perfil-hero">

        <div style="
            display:flex;
            align-items:center;
            gap:16px;
            margin-bottom:24px;
        ">

           ${(() => {
                    const fotoUrl = ApiService.formatarUrlFotoPerfil(usuario.fotoPerfil);
                    return fotoUrl
                        ? `
        <img
            src="${fotoUrl}?v=${Date.now()}"
            alt="Foto de perfil"
            style="
                width:72px;
                height:72px;
                border-radius:50%;
                object-fit:cover;
                flex-shrink:0;
            "
            onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
        >
        <div class="avatar"
             style="
                display:none;
                width:72px;
                height:72px;
                font-size:28px;
             ">
            ${inicial}
        </div>
      `
                        : `
        <div class="avatar"
             style="
                width:72px;
                height:72px;
                font-size:28px;
             ">
            ${inicial}
        </div>
      `;
                })()
                }

            <div>
                <h2 style="margin:0;">
                    ${usuario.nome}
                </h2>

                <p class="perfil-username"
                   style="
                       margin:4px 0 0 0;
                       color:var(--text-muted);
                   ">
                    @${usuario.username}
                </p>
            </div>

        </div>

        <div class="perfil-stats">
            <div><strong>${postsUsuario.length}</strong><span>Publicações</span></div>
            <div><strong>${comunidadesUsuario.length}</strong><span>Comunidades</span></div>
            <div><strong>${eventosUsuario.length}</strong><span>Eventos</span></div>
        </div>

        <div style="
            border-top:1px solid var(--border-color);
            padding-top:20px;
        ">

            <h3 style="margin-top:0;">
                Sobre
            </h3>

            <p style="
                color:var(--text-muted);
                line-height:1.6;
                margin-bottom:0;
            ">
                ${usuario.bio ||
                'Este usuário ainda não adicionou uma bio.'
                }
            </p>

        </div>

      ${ehProprioPerfil ? `
    <button
        type="button"
        class="btn-primary btn-editar-perfil"
        onclick="app.abrirEdicaoPerfil()"
    >
        <i class="material-icons">edit</i>
        <span>Editar perfil</span>
    </button>
` : idLogado ? `
    <button
        type="button"
        class="btn-message-profile"
        onclick="app.iniciarConversa(${idUsuario})"
    >
        Mensagem
    </button>
` : ''}

    </div>

    <div class="perfil-tabs">

        <div
            class="perfil-tab active"
            id="perfil-tab-publicacoes"
            onclick="app.mostrarAbaPerfil('publicacoes', ${idUsuario})">
            Publicações
        </div>

        <div
            class="perfil-tab"
            id="perfil-tab-comunidades"
            onclick="app.mostrarAbaPerfil('comunidades', ${idUsuario})">
            Comunidades
        </div>

        <div
            class="perfil-tab"
            id="perfil-tab-eventos"
            onclick="app.mostrarAbaPerfil('eventos', ${idUsuario})">
            Eventos
        </div>

    </div>

    <div id="perfil-conteudo-abas"></div>
`;

            document.querySelectorAll('.view-section')
                .forEach(el => el.classList.remove('active'));

            document.getElementById('view-perfil')
                .classList.add('active');

            this.renderizarPostsPerfil(postsUsuario);

        } catch (erro) {

            console.error(erro);
            alert("Não foi possível carregar o perfil.");
        }

    }

    async abrirMeuPerfil() {

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return alert("Faça login primeiro.");
        }

        await this.abrirPerfil(idUsuario);
    }

    voltarDoPerfil() {

        document.querySelectorAll('.view-section')
            .forEach(el => el.classList.remove('active'));

        const viewAnterior =
            document.getElementById(
                `view-${this.viewAntesDoPerfil}`
            );

        if (viewAnterior) {
            viewAnterior.classList.add('active');
        } else {
            document.getElementById('view-feed')
                .classList.add('active');
        }

        document.querySelectorAll('.nav-btn')
            .forEach(el => el.classList.remove('active'));

        const botaoAnterior =
            document.getElementById(
                `tab-${this.viewAntesDoPerfil}`
            );

        if (botaoAnterior) {
            botaoAnterior.classList.add('active');
        }
    }

    async abrirEdicaoPerfil() {

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return;
        }

        try {

            const usuario =
                await ApiService.buscarUsuarioPorId(idUsuario);

            document.getElementById(
                'editar-perfil-nome'
            ).value = usuario.nome || '';

            document.getElementById(
                'editar-perfil-username'
            ).value = usuario.username || '';

            document.getElementById(
                'editar-perfil-bio'
            ).value = usuario.bio || '';

            this.abrirModal('editar-perfil-modal');

        } catch (erro) {

            console.error(erro);
            alert("Não foi possível carregar os dados do perfil.");
        }
    }

    async salvarPerfil() {

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return;
        }

        const nome =
            document.getElementById(
                'editar-perfil-nome'
            ).value.trim();

        const username =
            document.getElementById(
                'editar-perfil-username'
            ).value.trim();

        const bio =
            document.getElementById(
                'editar-perfil-bio'
            ).value.trim();

        if (!nome) {
            return alert("O nome não pode ficar vazio.");
        }

        if (!username) {
            return alert("O username não pode ficar vazio.");
        }

        if (bio.length > 300) {
            return alert(
                "A bio pode ter no máximo 300 caracteres."
            );
        }

        try {

            const resposta =
                await ApiService.atualizarPerfil(
                    idUsuario,
                    nome,
                    username,
                    bio
                );

            if (!resposta.ok) {
                return alert(
                    "Não foi possível atualizar o perfil."
                );
            }

            const usuarioAtualizado =
                await resposta.json();

            // Atualiza também o usuário salvo no navegador
            ApiService.salvarSessao(usuarioAtualizado);

            this.fecharModal('editar-perfil-modal');

            // Atualiza o nome mostrado no menu lateral
            this.atualizarMenuLateral();

            // Renderiza novamente o perfil já atualizado
            await this.abrirPerfil(idUsuario);

            alert("Perfil atualizado com sucesso!");

        } catch (erro) {

            console.error(erro);

            alert(
                "Erro de conexão ao atualizar o perfil."
            );
        }
    }

    renderizarPostsPerfil(posts) {

        const container =
            document.getElementById('perfil-conteudo-abas');

        if (!container) {
            return;
        }

        if (!posts || posts.length === 0) {
            container.innerHTML = `
            <p style="color:var(--text-muted);">
                Este usuário ainda não publicou nada.
            </p>
        `;
            return;
        }

        container.innerHTML = '';

        posts.forEach(post => {

            const div = document.createElement('div');
            div.className = 'card';

            const nomeComunidade =
                post.idComunidade
                    ? this.comunidadesMap[post.idComunidade]
                    : null;

            div.innerHTML = `
            <h3 style="margin-top:0;">
                ${post.titulo}
            </h3>

            ${nomeComunidade
                    ? `
                        <small style="color:var(--text-muted);">
                            Publicado em ${nomeComunidade}
                        </small>
                    `
                    : ''
                }

            <p style="
                margin-top:12px;
                color:var(--text-muted);
            ">
                ${post.conteudo}
            </p>
        `;

            container.appendChild(div);
        });
    }

    renderizarComunidadesPerfil(comunidades, idUsuario) {

        const container =
            document.getElementById('perfil-conteudo-abas');

        if (!container) {
            return;
        }

        if (!comunidades || comunidades.length === 0) {
            container.innerHTML = `
            <p style="color:var(--text-muted);">
                Este usuário ainda não participa de nenhuma comunidade.
            </p>
        `;
            return;
        }

        container.innerHTML = '';

        comunidades.forEach(comunidade => {

            const idComunidade =
                comunidade.idComunidade || comunidade.id;

            const idAdministrador =
                comunidade.criador?.idUsuario ||
                comunidade.criador?.id;

            const ehAdministrador =
                idAdministrador == idUsuario;

            const div = document.createElement('div');

            div.className = 'list-item';

            div.innerHTML = `
            <div class="list-item-info">

                <div style="
                    display:flex;
                    align-items:center;
                    gap:8px;
                    margin-bottom:4px;
                ">
                    <h3 style="margin:0;">
                        ${comunidade.nome}
                    </h3>

                    ${ehAdministrador
                    ? `
                                <span style="
                                    font-size:11px;
                                    font-weight:700;
                                    padding:3px 7px;
                                    border-radius:12px;
                                    background:var(--bg-light);
                                    color:var(--primary-blue);
                                ">
                                    Administrador
                                </span>
                            `
                    : ''
                }
                </div>

                <p>
                    ${comunidade.descricao || 'Sem descrição.'}
                </p>

                <small style="color:var(--text-muted);">
                    ${comunidade.membros
                    ? comunidade.membros.length
                    : 0
                } membro(s)
                </small>

            </div>

            <button
                class="btn-primary"
                onclick="app.abrirComunidadeDoPerfil(${idComunidade})">
                Acessar
            </button>
        `;

            container.appendChild(div);
        });
    }
    renderizarEventoDestaque(evento) {
        const container =
            document.getElementById('evento-destaque');

        if (!container) return;

        if (!evento) {
            container.innerHTML = `
            <div class="evento-destaque-vazio">
                Nenhum evento encontrado com esses filtros.
            </div>
        `;
            return;
        }

        const data = evento.dataEvento
            ? new Date(
                `${evento.dataEvento}T00:00:00`
            ).toLocaleDateString('pt-BR', {
                day: '2-digit',
                month: 'short'
            }).replace('.', '')
            : '--';

        const horario =
            evento.horarioInicio?.substring(0, 5) ||
            '--:--';

        const titulo =
            this.escaparHtmlDestaque(
                evento.titulo || 'Evento'
            );

        const descricao =
            this.escaparHtmlDestaque(
                evento.descricao ||
                'Confira os detalhes deste evento.'
            );

        const local =
            this.escaparHtmlDestaque(
                evento.localEvento ||
                'Local a confirmar'
            );

        const categoria =
            this.escaparHtmlDestaque(
                evento.categoria ||
                'Evento'
            );

        const imagem = evento.imagemCapa
            ? `
            <div
                class="evento-destaque-imagem"
                style="
                    background-image:
                    url('${this.urlCapaEvento(evento.imagemCapa)}');
                "
            ></div>
        `
            : `
            <div class="
                evento-destaque-imagem
                evento-destaque-imagem-vazia
            ">
                <i class="material-icons">
                    event
                </i>
            </div>
        `;

        container.innerHTML = `
        <div class="evento-destaque-container">

            ${imagem}

            <div class="evento-destaque-copy">

                <div class="evento-destaque-topo">
                    <span class="evento-destaque-badge">
                        ${categoria}
                    </span>

                    <span class="evento-destaque-data">
                        ${data}
                    </span>
                </div>

                <h2 class="evento-destaque-titulo">
                    ${titulo}
                </h2>

                <p class="evento-destaque-descricao">
                    ${descricao}
                </p>

                <div class="evento-destaque-info">

                    <span>
                        <i class="material-icons">
                            schedule
                        </i>
                        ${horario}
                    </span>

                    <span>
                        <i class="material-icons">
                            location_on
                        </i>
                        ${local}
                    </span>

                </div>

                <button
                    type="button"
                    class="evento-destaque-btn"
                    onclick="
                        app.abrirDetalhesEvento(${evento.id})
                    "
                >
                    Ver detalhes

                    <i class="material-icons">
                        arrow_forward
                    </i>
                </button>

            </div>

        </div>
    `;
    }

    async carregarEventoDestaqueMaisPopular() {
        try {
            const resultado = await ApiService.buscarEventos({
                page: 0,
                size: 100
            });

            const eventos =
                Array.isArray(resultado)
                    ? resultado
                    : (resultado.content || []);

            if (!eventos.length) {
                this.renderizarEventoDestaque(null);
                return;
            }

            const eventoMaisPopular =
                [...eventos].sort((a, b) => {
                    const participantesA =
                        Number(a.quantidadeParticipantes || 0);

                    const participantesB =
                        Number(b.quantidadeParticipantes || 0);

                    return participantesB - participantesA;
                })[0];

            this.renderizarEventoDestaque(
                eventoMaisPopular
            );

        } catch (erro) {
            console.error(
                'Erro ao carregar evento em destaque:',
                erro
            );

            this.renderizarEventoDestaque(null);
        }
    }

    async abrirEventoDoPerfil(idEvento) {
        await this.abrirDetalhesEvento(idEvento);
    }

    async mostrarAbaPerfil(aba, idUsuario) {

        document.querySelectorAll('.perfil-tab')
            .forEach(tab => tab.classList.remove('active'));

        const abaSelecionada =
            document.getElementById(`perfil-tab-${aba}`);

        if (abaSelecionada) {
            abaSelecionada.classList.add('active');
        }

        if (aba === 'publicacoes') {

            const posts =
                await ApiService.listarPostsPorUsuario(idUsuario);

            this.renderizarPostsPerfil(posts);
            return;
        }

        if (aba === 'comunidades') {

            const comunidades =
                await ApiService.listarComunidadesPorUsuario(
                    idUsuario
                );

            this.renderizarComunidadesPerfil(
                comunidades,
                idUsuario
            );

            return;
        }

        if (aba === 'eventos') {

            const eventos =
                await ApiService.listarEventosPorUsuario(
                    idUsuario
                );

            this.renderizarEventosPerfil(eventos);

            return;
        }
    }

    async abrirComunidadeDoPerfil(idComunidade) {

        await this.carregarComunidades();

        const comunidade =
            this.listaComunidades.find(
                c => (c.idComunidade || c.id) == idComunidade
            );

        if (!comunidade) {
            return alert("Comunidade não encontrada.");
        }

        this.entrarSubreddit(
            idComunidade,
            comunidade.nome,
            comunidade.descricao
        );
    }

    async salvarFotoPerfil() {

        console.log("1 - salvarFotoPerfil foi chamada");

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        console.log("2 - ID:", idUsuario);

        const input =
            document.getElementById('editar-perfil-foto');

        console.log("3 - input:", input);

        const foto = input?.files?.[0];

        console.log("4 - foto:", foto);

        if (!foto) {
            return alert("Selecione uma imagem.");
        }

        if (!foto.type.startsWith('image/')) {
            return alert("Selecione um arquivo de imagem.");
        }

        if (foto.size > 5 * 1024 * 1024) {
            return alert("A imagem deve ter no máximo 5 MB.");
        }
        try {

            console.log("5 - chamando ApiService");

            const resposta =
                await ApiService.atualizarFotoPerfil(
                    idUsuario,
                    foto
                );

            console.log("6 - resposta:", resposta);
            console.log("7 - status:", resposta.status);

            if (!resposta.ok) {

                const erro = await resposta.text();

                console.error("Resposta do backend:", erro);

                return alert(
                    "Não foi possível alterar a foto."
                );
            }

            const usuarioAtualizado =
                await resposta.json();

            const usuarioSessao =
                ApiService.getUsuarioLogado();

            ApiService.salvarSessao({
                ...usuarioSessao,
                fotoPerfil: usuarioAtualizado.fotoPerfil
            });

            this.usuariosFotosMap[idUsuario] = usuarioAtualizado.fotoPerfil;

            input.value = '';

            this.fecharModal('editar-perfil-modal');

            await this.abrirPerfil(idUsuario);

            this.atualizarMenuLateral();

            alert("Foto alterada com sucesso!");
        } catch (erro) {

            console.error(
                "ERRO NO UPLOAD:",
                erro
            );

            alert("Erro ao enviar a foto.");
        }
    }

    salvarViewAtual(view) {
        sessionStorage.setItem('viewAtual', view);
    }

    getViewSalva() {
        return sessionStorage.getItem('viewAtual') || 'feed';
    }

    async carregarConversas() {
        const idUsuario = ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            this.listaConversas = [];
            this.renderizarConversas();
            return;
        }

        try {
            this.listaConversas =
                await ApiService.listarConversasDoUsuario(idUsuario);

            this.renderizarConversas();

        } catch (erro) {
            console.error('Erro ao carregar conversas:', erro);
        }
    }

    renderizarConversas(conversas = this.listaConversas, termoBusca = '') {
        const container =
            document.getElementById('chat-conversations');

        if (!container) {
            return;
        }

        if (conversas.length === 0) {
            const mensagemVazia = termoBusca
                ? 'Nenhuma conversa encontrada.'
                : 'Nenhuma conversa ainda.';

            container.innerHTML = `
            <p class="chat-empty">
                ${mensagemVazia}
            </p>
        `;
            return;
        }

        container.innerHTML = '';

        conversas.forEach(conversa => {
            const item = document.createElement('div');

            item.className = 'chat-conversation-item';

            if (this.conversaAtiva && String(conversa.idConversa) === String(this.conversaAtiva.idConversa)) {
                item.classList.add('active');
            }

            const nome =
                conversa.nomeOutroUsuario || 'Usuário';

            const username =
                conversa.usernameOutroUsuario
                    ? `@${conversa.usernameOutroUsuario}`
                    : '';

            const inicial =
                nome.charAt(0).toUpperCase();

            item.innerHTML = `
            <div class="chat-conversation-avatar">
                ${inicial}
            </div>

            <div class="chat-conversation-info">
                <strong>${nome}</strong>
                <span>${username}</span>
            </div>
        `;

            item.addEventListener('click', () => {
                this.abrirConversa(conversa);
            });

            container.appendChild(item);
        });
    }

    async abrirConversa(conversa) {
        this.conversaAtiva = conversa;

        const janela =
            document.getElementById('chat-window');

        const nome =
            document.getElementById('chat-user-name');

        const username =
            document.getElementById('chat-user-username');

        const avatar =
            document.getElementById('chat-user-avatar');

        const status =
            document.getElementById('chat-user-status');

        if (!janela) {
            return;
        }

        const nomeExibicao =
            conversa.nomeOutroUsuario || 'Usuário';

        nome.textContent = nomeExibicao;

        username.textContent =
            conversa.usernameOutroUsuario
                ? `@${conversa.usernameOutroUsuario}`
                : 'Usuário';

        status.textContent = 'online';
        status.classList.add('active');

        avatar.textContent =
            nomeExibicao
                .charAt(0)
                .toUpperCase();

        janela.classList.add('active');

        await this.carregarMensagens(
            conversa.idConversa
        );
    }

    async carregarMensagens(idConversa) {
        const container =
            document.getElementById('chat-messages');

        if (!container) {
            return;
        }

        container.innerHTML = `
        <p class="chat-empty">
            Carregando...
        </p>
    `;

        try {
            const mensagens =
                await ApiService.listarMensagens(idConversa);

            this.renderizarMensagens(mensagens);

        } catch (erro) {
            console.error(
                'Erro ao carregar mensagens:',
                erro
            );

            container.innerHTML = `
            <p class="chat-empty">
                Não foi possível carregar as mensagens.
            </p>
        `;
        }
    }

    renderizarMensagens(mensagens) {
        const container =
            document.getElementById('chat-messages');

        if (!container) {
            return;
        }

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (mensagens.length === 0) {
            container.innerHTML =
                `<p class="chat-empty">
                Nenhuma mensagem ainda.
            </p>`;

            return;
        }

        container.innerHTML = '';

        mensagens.forEach(mensagem => {

            const enviadaPorMim =
                String(mensagem.idRemetente) ===
                String(idUsuario);

            const linha =
                document.createElement('div');

            linha.className =
                enviadaPorMim
                    ? 'chat-message-row sent'
                    : 'chat-message-row received';


            const bolha =
                document.createElement('div');

            bolha.className =
                'chat-message-bubble';


            const autor =
                document.createElement('span');

            autor.className =
                'chat-message-author';

            autor.textContent =
                enviadaPorMim
                    ? 'Você'
                    : mensagem.nomeRemetente || 'Usuário';


            const conteudo =
                document.createElement('span');

            conteudo.className =
                'chat-message-content';

            conteudo.textContent =
                mensagem.conteudo;


            bolha.appendChild(autor);
            bolha.appendChild(conteudo);

            linha.appendChild(bolha);

            container.appendChild(linha);
        });

        container.scrollTop =
            container.scrollHeight;
    }

    async enviarMensagemChat(event) {
        event.preventDefault();

        if (!this.conversaAtiva) {
            return;
        }

        const form = document.getElementById('chat-message-form');
        const input = document.getElementById('chat-message-input');
        const botaoEnviar = form?.querySelector('button[type="submit"]');

        if (!input || !form) {
            return;
        }

        const conteudo = input.value.trim();

        if (!conteudo) {
            return;
        }

        const idUsuario = ApiService.getIdUsuarioLogado();

        form.classList.add('sending');
        input.disabled = true;
        botaoEnviar.disabled = true;
        botaoEnviar.textContent = 'Enviando...';

        try {
            await ApiService.enviarMensagem(
                this.conversaAtiva.idConversa,
                idUsuario,
                conteudo
            );

            input.value = '';
            await this.carregarMensagens(this.conversaAtiva.idConversa);
            input.focus();

        } catch (erro) {
            console.error(
                'Erro ao enviar mensagem:',
                erro
            );

            alert(
                erro.message ||
                'Não foi possível enviar a mensagem.'
            );
        } finally {
            form.classList.remove('sending');
            input.disabled = false;
            botaoEnviar.disabled = false;
            botaoEnviar.textContent = 'Enviar';
            input.focus();
        }
    }

    async iniciarConversa(idOutroUsuario) {
        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            alert('Você precisa estar logado para enviar mensagens.');
            return;
        }

        if (String(idUsuario) === String(idOutroUsuario)) {
            return;
        }

        try {
            const conversa =
                await ApiService.criarOuBuscarConversa(
                    idUsuario,
                    idOutroUsuario
                );

            // Atualiza a lista da lateral
            await this.carregarConversas();

            // Abre imediatamente a conversa criada/encontrada
            await this.abrirConversa(conversa);

        } catch (erro) {
            console.error(
                'Erro ao iniciar conversa:',
                erro
            );

            alert(
                erro.message ||
                'Não foi possível iniciar a conversa.'
            );
        }
    }

    conectarWebSocketChat() {

        const idUsuario =
            ApiService.getIdUsuarioLogado();

        if (!idUsuario) {
            return;
        }

        if (
            this.chatSocket &&
            this.chatSocket.readyState === WebSocket.OPEN
        ) {
            return;
        }

        const url =
            `ws://localhost:8080/ws/chat?usuarioId=${idUsuario}`;

        this.chatSocket =
            new WebSocket(url);


        this.chatSocket.addEventListener(
            'open',
            () => {
                console.log(
                    'CHAT WS: conectado'
                );
            }
        );

        this.chatSocket.addEventListener(
            'message',
            (event) => {

                try {

                    const mensagem =
                        JSON.parse(event.data);

                    console.log(
                        'CHAT WS: mensagem recebida',
                        mensagem
                    );

                    this.receberMensagemWebSocket(
                        mensagem
                    );

                } catch (erro) {

                    console.error(
                        'CHAT WS: erro ao processar mensagem',
                        erro
                    );

                }

            }
        );


        this.chatSocket.addEventListener(
            'close',
            () => {
                console.log(
                    'CHAT WS: desconectado'
                );
            }
        );


        this.chatSocket.addEventListener(
            'error',
            (erro) => {
                console.error(
                    'CHAT WS: erro',
                    erro
                );
            }
        );
    }

    async receberMensagemWebSocket(mensagem) {

        if (!mensagem) {
            return;
        }

        /*
         * Atualiza a lista lateral.
         * Por enquanto é simples e seguro.
         */
        await this.carregarConversas();


        /*
         * Se a conversa recebida estiver aberta,
         * recarrega o histórico imediatamente.
         */
        if (
            this.conversaAtiva &&
            String(this.conversaAtiva.idConversa) ===
            String(mensagem.idConversa)
        ) {

            await this.carregarMensagens(
                mensagem.idConversa
            );

        }

    }
}


window.app = new AppController();
window.app.inicializar();