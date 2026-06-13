using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.DAO;
using RedeSocialEventosAdmin.Models;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmRelatorios : Form
    {
        private readonly DashboardDAO _dashboardDAO;

        public FrmRelatorios()
        {
            InitializeComponent();
            _dashboardDAO = new DashboardDAO();
        }

        private void FrmRelatorios_Load(object sender, EventArgs e)
        {
            GerarEstatisticasRelatorio();
        }

        private void GerarEstatisticasRelatorio()
        {
            try
            {
                DashboardStats stats = _dashboardDAO.ObterEstatisticasGerais();

                lblQtdUsuarios.Text = stats.TotalUsuarios.ToString();
                lblQtdPosts.Text = stats.TotalPosts.ToString();
                lblQtdComentarios.Text = stats.TotalComentarios.ToString();

                lblDataGeracao.Text = $"Relatório Sintético extraído em: {DateTime.Now:dd/MM/yyyy às HH:mm:ss}";
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Erro ao consolidar relatório relacional: {ex.Message}", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}