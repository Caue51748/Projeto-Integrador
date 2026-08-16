// api_service.js
export class ApiService {
    static API_URL = 'http://localhost:8080';

    static getUsuarioLogado() { return JSON.parse(localStorage.getItem('usuarioLogado')); }
    static salvarSessao(usuario) { localStorage.setItem('usuarioLogado', JSON.stringify(usuario)); }
    static fazerLogout() { localStorage.removeItem('usuarioLogado'); }
    static getIdUsuarioLogado() {
        const user = this.getUsuarioLogado();
        return user ? (user.idUsuario || user.id_usuario || user.id) : null;
    }

    // --- USUÁRIOS ---
    static async listarUsuarios() { return await (await fetch(`${this.API_URL}/usuarios`)).json(); }
    static async criarUsuario(nome, email, senha) {
        return await fetch(`${this.API_URL}/usuarios`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ nome, email, senha })
        });
    }

    // --- POSTS E COMENTÁRIOS ---
    static async listarPosts() { return await (await fetch(`${this.API_URL}/posts`)).json(); }

    static async criarPost(titulo, conteudo, idUsuario, idComunidade = null) {
        let bodyObj = { titulo, conteudo, idUsuario: parseInt(idUsuario) };
        if (idComunidade !== null) { bodyObj.idComunidade = parseInt(idComunidade); } // Se tiver comunidade, envia junto

        return await fetch(`${this.API_URL}/posts`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(bodyObj)
        });
    }

    static async listarComentarios() { return await (await fetch(`${this.API_URL}/comentarios`)).json(); }
    static async criarComentario(conteudo, idUsuario, idPost) {
        return await fetch(`${this.API_URL}/comentarios`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ conteudo, idUsuario: parseInt(idUsuario), idPost: parseInt(idPost) })
        });
    }

    // --- COMUNIDADES ---
    static async listarComunidades() {
        return await (await fetch(`${this.API_URL}/comunidades`)).json();
    }

    static async criarComunidadeAPI(nome, descricao, criadorId) {
        return await fetch(`${this.API_URL}/comunidades`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                nome,
                descricao,
                criadorId
            })
        });
    }

    // --- EVENTOS  ---
    static async listarEventos() {
        const response = await fetch(`${this.API_URL}/api/eventos`);
        return await response.json();
    }

    static async criarEventoAPI(eventoData) {
        return await fetch(`${this.API_URL}/api/eventos`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(eventoData)
        });
    }

    static async atualizarComunidade(idComunidade, idUsuario, nome, descricao) {
        return await fetch(`${this.API_URL}/comunidades/${idComunidade}/usuario/${idUsuario}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                nome,
                descricao
            })
        });
    }

    static async excluirComunidade(idComunidade, idUsuario) {
        return await fetch(`${this.API_URL}/comunidades/${idComunidade}/usuario/${idUsuario}`, { method: "DELETE" });
    }

    static async removerMembro(idComunidade, idMembro, idSolicitante) {
        return await fetch(
            `${this.API_URL}/comunidades/${idComunidade}/membros/${idMembro}/usuario/${idSolicitante}`,
            {
                method: "DELETE"
            }
        );
    }

    static async deletarPost(idPost, idUsuario) {
        return await fetch(
            `${this.API_URL}/posts/${idPost}/usuario/${idUsuario}`,
            {
                method: "DELETE"
            }
        );
    }
}