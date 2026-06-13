using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.DAO;
using RedeSocialEventosAdmin.Models;
using RedeSocialEventosAdmin.Utils;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmUsuarioMockCadastro : Form
    {
        private readonly UsuarioDAO _usuarioDAO;
        private readonly Usuario _usuarioExistente;
        private readonly bool _isEdicao;

        // Construtor para Inserção (Novo Usuário)
        public FrmUsuarioMockCadastro()
        {
            InitializeComponent();
            _usuarioDAO = new UsuarioDAO();
            _isEdicao = false;
            lblOperacao.Text = "Cadastrar Novo Usuário";
        }

        // Construtor para Edição (Usuário Existente)
        public FrmUsuarioMockCadastro(Usuario usuario)
        {
            InitializeComponent();
            _usuarioDAO = new UsuarioDAO();
            _usuarioExistente = usuario;
            _isEdicao = true;
            lblOperacao.Text = "Editar Usuário Existente";
            PreencherCampos();
        }

        private void PreencherCampos()
        {
            txtNome.Text = _usuarioExistente.Nome;
            txtEmail.Text = _usuarioExistente.Email;
            txtSenha.Text = _usuarioExistente.Senha;
        }

        private void btnSalvar_Click(object sender, EventArgs e)
        {
            string nome = txtNome.Text.Trim();
            string email = txtEmail.Text.Trim();
            string senha = txtSenha.Text;

            // Validações de Negócio Requeridas
            if (Validador.CampoVazio(nome) || Validador.CampoVazio(email) || Validador.CampoVazio(senha))
            {
                MessageBox.Show("Todos os campos do formulário são de preenchimento obrigatório.", "Erro de Validação", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!Validador.ValidarEmail(email))
            {
                MessageBox.Show("Formato de correio eletrônico (E-mail) inválido.", "Erro de Validação", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!Validador.ValidarSenha(senha))
            {
                MessageBox.Show("Por motivos de segurança, a senha de acesso deve possuir o tamanho mínimo de 6 caracteres.", "Erro de Validação", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                // Verificar se o email já está cadastrado para evitar violação da constraint UNIQUE do banco
                Usuario emailVerificacao = _usuarioDAO.BuscarPorEmail(email);
                if (emailVerificacao != null && (!_isEdicao || emailVerificacao.IdUsuario != _usuarioExistente.IdUsuario))
                {
                    MessageBox.Show("Este e-mail já encontra-se vinculado a outra conta no banco de dados.", "Conflito de Dados", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                if (_isEdicao)
                {
                    _usuarioExistente.Nome = nome;
                    _usuarioExistente.Email = email;
                    _usuarioExistente.Senha = senha;

                    if (_usuarioDAO.Atualizar(_usuarioExistente))
                    {
                        MessageBox.Show("Os dados do usuário foram atualizados com sucesso.", "Sucesso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        this.DialogResult = DialogResult.OK;
                        this.Close();
                    }
                }
                else
                {
                    Usuario novoUsuario = new Usuario
                    {
                        Nome = nome,
                        Email = email,
                        Senha = senha
                    };

                    if (_usuarioDAO.Inserir(novoUsuario))
                    {
                        MessageBox.Show("Novo usuário registrado com sucesso no banco corporativo.", "Sucesso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        this.DialogResult = DialogResult.OK;
                        this.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Erro operacional durante a persistência: {ex.Message}", "Falha Crítica", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnCancelar_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
    }
}