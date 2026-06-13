using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.DAO;
using RedeSocialEventosAdmin.Models;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmDashboard : Form
    {
        private readonly DashboardDAO _dashboardDAO;

        public FrmDashboard()
        {
            InitializeComponent();
            _dashboardDAO = new DashboardDAO();
        }

        private void FrmDashboard_Load(object sender, EventArgs e)
        {
            CarregarEstatisticasCards();
            CarregarUltimosUsuariosGrid();
        }

        private void CarregarEstatisticasCards()
        {
            try
            {
                DashboardStats stats = _dashboardDAO.ObterEstatisticasGerais();

                lblTotalUsuarios.Text = stats.TotalUsuarios.ToString("N0");
                lblUsuariosHoje.Text = stats.UsuariosHoje.ToString("N0");
                lblTotalPosts.Text = stats.TotalPosts.ToString("N0");
                lblTotalComentarios.Text = stats.TotalComentarios.ToString("N0");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Falha ao carregar cards métricos: {ex.Message}", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void CarregarUltimosUsuariosGrid()
        {
            try
            {
                dgvUltimosUsuarios.DataSource = _dashboardDAO.ObterUltimosUsuarios(7);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Falha ao carregar listagem recente: {ex.Message}", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}