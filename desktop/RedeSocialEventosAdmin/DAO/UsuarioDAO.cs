using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;
using RedeSocialEventosAdmin.Models;

namespace RedeSocialEventosAdmin.DAO
{
    public class UsuarioDAO
    {
        public bool ValidarLogin(string email, string senha)
        {
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "SELECT COUNT(1) FROM usuarios WHERE email = @email AND senha = @senha";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@senha", senha); // Em produção, utilize Hash (SHA256/BCrypt)

                    try
                    {
                        conn.Open();
                        int resultado = Convert.ToInt32(cmd.ExecuteScalar());
                        return resultado > 0;
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Erro ao validar login: " + ex.Message);
                    }
                }
            }
        }

        public bool Inserir(Usuario usuario)
        {
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "INSERT INTO usuarios (nome, email, senha, data_criacao) VALUES (@nome, @email, @senha, NOW())";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@nome", usuario.Nome);
                    cmd.Parameters.AddWithValue("@email", usuario.Email);
                    cmd.Parameters.AddWithValue("@senha", usuario.Senha);

                    try
                    {
                        conn.Open();
                        return cmd.ExecuteNonQuery() > 0;
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Erro ao inserir usuário: " + ex.Message);
                    }
                }
            }
        }

        public bool Atualizar(Usuario usuario)
        {
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "UPDATE usuarios SET nome = @nome, email = @email, senha = @senha WHERE id_usuario = @id";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@nome", usuario.Nome);
                    cmd.Parameters.AddWithValue("@email", usuario.Email);
                    cmd.Parameters.AddWithValue("@senha", usuario.Senha);
                    cmd.Parameters.AddWithValue("@id", usuario.IdUsuario);

                    try
                    {
                        conn.Open();
                        return cmd.ExecuteNonQuery() > 0;
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Erro ao atualizar usuário: " + ex.Message);
                    }
                }
            }
        }

        public bool Excluir(long idUsuario)
        {
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                conn.Open();
                using (MySqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // Excluir dependências em cascata manualmente para evitar quebras de FK no MySQL corporativo
                        string delVotosComent = "DELETE FROM votos_comentario WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delVotosComent, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delComentarios = "DELETE FROM comentarios WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delComentarios, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delVotos = "DELETE FROM votos WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delVotos, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delInteracoes = "DELETE FROM interacoes_usuario WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delInteracoes, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delMembros = "DELETE FROM membros_comunidade WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delMembros, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delPostsSalvos = "DELETE FROM posts_salvos WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delPostsSalvos, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delEstatisticas = "DELETE FROM estatisticas_usuario WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delEstatisticas, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delPosts = "DELETE FROM posts WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delPosts, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            cmd.ExecuteNonQuery();
                        }

                        string delUsuario = "DELETE FROM usuarios WHERE id_usuario = @id";
                        using (MySqlCommand cmd = new MySqlCommand(delUsuario, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@id", idUsuario);
                            int linhasAfetadas = cmd.ExecuteNonQuery();

                            trans.Commit();
                            return linhasAfetadas > 0;
                        }
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        throw new Exception("Erro transacional ao remover usuário e vínculos: " + ex.Message);
                    }
                }
            }
        }

        public Usuario BuscarPorId(long idUsuario)
        {
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "SELECT id_usuario, nome, email, senha, data_criacao FROM usuarios WHERE id_usuario = @id";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idUsuario);
                    try
                    {
                        conn.Open();
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new Usuario
                                {
                                    IdUsuario = Convert.ToInt64(reader["id_usuario"]),
                                    Nome = reader["nome"].ToString(),
                                    Email = reader["email"].ToString(),
                                    Senha = reader["senha"].ToString(),
                                    DataCriacao = Convert.ToDateTime(reader["data_criacao"])
                                };
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Erro ao buscar usuário por ID: " + ex.Message);
                    }
                }
            }
            return null;
        }

        public Usuario BuscarPorEmail(string email)
        {
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "SELECT id_usuario, nome, email, senha, data_criacao FROM usuarios WHERE email = @email";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    try
                    {
                        conn.Open();
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new Usuario
                                {
                                    IdUsuario = Convert.ToInt64(reader["id_usuario"]),
                                    Nome = reader["nome"].ToString(),
                                    Email = reader["email"].ToString(),
                                    Senha = reader["senha"].ToString(),
                                    DataCriacao = Convert.ToDateTime(reader["data_criacao"])
                                };
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Erro ao buscar usuário por Email: " + ex.Message);
                    }
                }
            }
            return null;
        }

        public DataTable Listar()
        {
            DataTable dt = new DataTable();
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "SELECT id_usuario AS 'ID', nome AS 'Nome', email AS 'E-mail', data_criacao AS 'Data de Criação' FROM usuarios ORDER BY id_usuario DESC";
                using (MySqlDataAdapter da = new MySqlDataAdapter(sql, conn))
                {
                    try
                    {
                        da.Fill(dt);
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("Erro ao listar usuários: " + ex.Message);
                    }
                }
            }
            return dt;
        }

        public DataTable Pesquisar(string termo)
        {
            DataTable dt = new DataTable();
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "SELECT id_usuario AS 'ID', nome AS 'Nome', email AS 'E-mail', data_criacao AS 'Data de Criação' FROM usuarios WHERE nome LIKE @termo OR email LIKE @termo ORDER BY id_usuario DESC";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@termo", "%" + termo + "%");
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        try
                        {
                            da.Fill(dt);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("Erro ao pesquisar usuários: " + ex.Message);
                        }
                    }
                }
            }
            return dt;
        }
    }
}