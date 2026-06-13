using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.DAO;
using RedeSocialEventosAdmin.Utils;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmLogin : Form
    {
        private readonly UsuarioDAO _usuarioDAO;

        public FrmLogin()
        {
            InitializeComponent();
            _usuarioDAO = new UsuarioDAO();
        }

        private void btnEntrar_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string senha = txtSenha.Text;

            if (Validador.CampoVazio(email) || Validador.CampoVazio(senha))
            {
                MessageBox.Show("Preencha todos os campos obrigatórios.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!Validador.ValidarEmail(email))
            {
                MessageBox.Show("O e-mail digitado possui formato inválido.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                bool logado = _usuarioDAO.ValidarLogin(email, senha);
                if (logado)
                {
                    // Armazena o email de sessão estaticamente na aplicação
                    Program.EmailUsuarioLogado = email;

                    this.Hide();
                    FrmPrincipal principal = new FrmPrincipal();
                    principal.ShowDialog();
                    this.Close();
                }
                else
                {
                    MessageBox.Show("E-mail ou senha incorretos.", "Erro de Autenticação", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ocorreu um erro no servidor: {ex.Message}", "Erro Crítico", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnFechar_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }
}