// api_service.js

export class ApiService {
    static API_URL = 'http://localhost:8080';

    // --- AUTENTICAÇÃO LOCAL ---
    static getUsuarioLogado() {
        return JSON.parse(localStorage.getItem('usuarioLogado'));
    }

    static salvarSessao(usuario) {
        localStorage.setItem('usuarioLogado', JSON.stringify(usuario));
    }

    static fazerLogout() {
        localStorage.removeItem('usuarioLogado');
    }

    static getIdUsuarioLogado() {
        const user = this.getUsuarioLogado();
        return user ? (user.idUsuario || user.id_usuario || user.id) : null;
    }

    // --- REQUISIÇÕES AO BANCO ---
    static async listarUsuarios() {
        const res = await fetch(`${this.API_URL}/usuarios`);
        return await res.json();
    }

    static async criarUsuario(nome, email, senha) {
        const res = await fetch(`${this.API_URL}/usuarios`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ nome, email, senha })
        });
        return res;
    }

    static async listarPosts() {
        const res = await fetch(`${this.API_URL}/posts`);
        return await res.json();
    }

    static async criarPost(titulo, conteudo, idUsuario) {
        const res = await fetch(`${this.API_URL}/posts`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ titulo, conteudo, idUsuario })
        });
        return res;
    }

    static async listarComentarios() {
        const res = await fetch(`${this.API_URL}/comentarios`);
        return await res.json();
    }

    static async criarComentario(conteudo, idUsuario, idPost) {
        const res = await fetch(`${this.API_URL}/comentarios`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ conteudo, idUsuario, idPost })
        });
        return res;
    }
}