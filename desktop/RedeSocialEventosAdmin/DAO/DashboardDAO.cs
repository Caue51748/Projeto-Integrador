using System;
using System.Data;
using MySql.Data.MySqlClient;
using RedeSocialEventosAdmin.Models;

namespace RedeSocialEventosAdmin.DAO
{
    public class DashboardDAO
    {
        public DashboardStats ObterEstatisticasGerais()
        {
            DashboardStats stats = new DashboardStats();
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                try
                {
                    conn.Open();

                    // 1. Total Usuários
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(1) FROM usuarios", conn))
                    {
                        stats.TotalUsuarios = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // 2. Cadastrados Hoje
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(1) FROM usuarios WHERE DATE(data_criacao) = CURDATE()", conn))
                    {
                        stats.UsuariosHoje = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // 3. Total de Posts
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(1) FROM posts", conn))
                    {
                        stats.TotalPosts = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // 4. Total de Comentários
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(1) FROM comentarios", conn))
                    {
                        stats.TotalComentarios = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Erro ao carregar dados do Dashboard: " + ex.Message);
                }
            }
            return stats;
        }

        public DataTable ObterUltimosUsuarios(int limite)
        {
            DataTable dt = new DataTable();
            using (MySqlConnection conn = Conexao.GetConnection())
            {
                string sql = "SELECT id_usuario AS 'ID', nome AS 'Nome', email AS 'E-mail', data_criacao AS 'Data Cadastro' FROM usuarios ORDER BY data_criacao DESC LIMIT @limite";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@limite", limite);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        try
                        {
                            da.Fill(dt);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("Erro ao obter últimos usuários cadastrados: " + ex.Message);
                        }
                    }
                }
            }
            return dt;
        }
    }
}