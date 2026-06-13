using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.DAO;
using RedeSocialEventosAdmin.Models;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmUsuarios : Form
    {
        private readonly UsuarioDAO _usuarioDAO;

        public FrmUsuarios()
        {
            InitializeComponent();
            _usuarioDAO = new UsuarioDAO();
        }

        private void FrmUsuarios_Load(object sender, EventArgs e)
        {
            AtualizarGrid();
        }

        private void AtualizarGrid()
        {
            try
            {
                dgvUsuarios.DataSource = _usuarioDAO.Listar();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Erro ao carregar lista de usuários: {ex.Message}", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void txtPesquisa_TextChanged(object sender, EventArgs e)
        {
            string termo = txtPesquisa.Text.Trim();
            if (string.IsNullOrEmpty(termo))
            {
                AtualizarGrid();
            }
            else
            {
                try
                {
                    dgvUsuarios.DataSource = _usuarioDAO.Pesquisar(termo);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Erro ao pesquisar: {ex.Message}", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void btnNovo_Click(object sender, EventArgs e)
        {
            FrmUsuarioMockCadastro frmCad = new FrmUsuarioMockCadastro();
            if (frmCad.ShowDialog() == DialogResult.OK)
            {
                AtualizarGrid();
            }
        }

        private void btnEditar_Click(object sender, EventArgs e)
        {
            if (dgvUsuarios.SelectedRows.Count == 0)
            {
                MessageBox.Show("Selecione um usuário na tabela para realizar a edição.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            long idSelecionado = Convert.ToInt64(dgvUsuarios.SelectedRows[0].Cells["ID"].Value);
            Usuario userParaEditar = _usuarioDAO.BuscarPorId(idSelecionado);

            if (userParaEditar != null)
            {
                FrmUsuarioMockCadastro frmEdit = new FrmUsuarioMockCadastro(userParaEditar);
                if (frmEdit.ShowDialog() == DialogResult.OK)
                {
                    AtualizarGrid();
                }
            }
        }

        private void btnExcluir_Click(object sender, EventArgs e)
        {
            if (dgvUsuarios.SelectedRows.Count == 0)
            {
                MessageBox.Show("Selecione um usuário na tabela para realizar a exclusão.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            long idSelecionado = Convert.ToInt64(dgvUsuarios.SelectedRows[0].Cells["ID"].Value);
            string nomeSelecionado = dgvUsuarios.SelectedRows[0].Cells["Nome"].Value.ToString();

            DialogResult resultado = MessageBox.Show($"ATENÇÃO: A remoção do usuário '{nomeSelecionado}' irá excluir todos os seus posts, comentários e interações de forma definitiva devido às regras de integridade física.\n\nDeseja continuar?", "Confirmação de Exclusão Cascata", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

            if (resultado == DialogResult.Yes)
            {
                try
                {
                    if (_usuarioDAO.Excluir(idSelecionado))
                    {
                        MessageBox.Show("Usuário e todas as dependências foram deletados com sucesso.", "Sucesso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        AtualizarGrid();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Erro crítico na deleção: {ex.Message}", "Falha", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }
    }
}