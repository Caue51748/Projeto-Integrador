// api_service.js

export class ApiService {
    static API_URL = 'http://localhost:8080';

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
        if (!user) return null;
        return user.idUsuario || user.id_usuario || user.id;
    }

    static async listarUsuarios() {
        const res = await fetch(`${this.API_URL}/usuarios`);
        return await res.json();
    }
    static async criarUsuario(nome, email, senha) {
        return await fetch(`${this.API_URL}/usuarios`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ nome, email, senha })
        });
    }

    static async listarPosts() {
        const res = await fetch(`${this.API_URL}/posts`);
        return await res.json();
    }
    static async criarPost(titulo, conteudo, idUsuario) {
        return await fetch(`${this.API_URL}/posts`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ titulo, conteudo, idUsuario: parseInt(idUsuario) }) 
        });
    }

    static async listarComentarios() {
        const res = await fetch(`${this.API_URL}/comentarios`);
        return await res.json();
    }
    static async criarComentario(conteudo, idUsuario, idPost) {
        return await fetch(`${this.API_URL}/comentarios`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ conteudo, idUsuario: parseInt(idUsuario), idPost: parseInt(idPost) })
        });
    }

    // --- COMUNIDADES ---
    static async listarComunidades() {
        try {
            const res = await fetch(`${this.API_URL}/comunidades`);
            if (!res.ok) throw new Error("Endpoint não existe ainda");
            return await res.json();
        } catch (e) {
            // Retorna lista falsa caso o Java ainda não tenha a rota /comunidades
            return [
                { nome: "Desenvolvedores Java", descricao: "Grupo para debater Spring Boot e APIs." },
                { nome: "Flutter Brasil", descricao: "Tudo sobre desenvolvimento mobile com Dart." }
            ];
        }
    }
    static async criarComunidadeAPI(nome, descricao) {
        try {
            return await fetch(`${this.API_URL}/comunidades`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ nome, descricao })
            });
        } catch (e) {
            return { ok: false, text: () => "Backend de comunidades não configurado." };
        }
    }
}