using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.DAO;
using RedeSocialEventosAdmin.Models;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmPerfil : Form
    {
        private readonly UsuarioDAO _usuarioDAO;

        public FrmPerfil()
        {
            InitializeComponent();
            _usuarioDAO = new UsuarioDAO();
        }

        private void FrmPerfil_Load(object sender, EventArgs e)
        {
            CarregarDadosSessao();
        }

        private void CarregarDadosSessao()
        {
            try
            {
                string emailLogado = Program.EmailUsuarioLogado;
                Usuario admin = _usuarioDAO.BuscarPorEmail(emailLogado);

                if (admin != null)
                {
                    lblNomeAdmin.Text = admin.Nome;
                    lblEmailAdmin.Text = admin.Email;
                    lblDataCriacaoAdmin.Text = admin.DataCriacao.ToString("dd/MM/yyyy HH:mm:ss");
                }
                else
                {
                    lblNomeAdmin.Text = "Administrador Padrão";
                    lblEmailAdmin.Text = emailLogado;
                    lblDataCriacaoAdmin.Text = DateTime.Now.ToString("dd/MM/yyyy");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Erro ao carregar dados do seu perfil: {ex.Message}", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}