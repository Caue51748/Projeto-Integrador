using System;
using System.Drawing;
using System.Windows.Forms;
using FontAwesome.Sharp;

namespace RedeSocialEventosAdmin.Forms
{
    public partial class FrmPrincipal : Form
    {
        private IconButton btnAtual;
        private Form frmAtivo;

        public FrmPrincipal()
        {
            InitializeComponent();
            // Inicializa a tela abrindo o dashboard por padrão
            MudarTela(btnDashboard, new FrmDashboard());
        }

        private void AtivarBotao(object remetente)
        {
            if (remetente != null)
            {
                DesativarBotao();
                btnAtual = (IconButton)remetente;
                btnAtual.BackColor = Color.FromArgb(37, 99, 235); // Cor de Destaque Primária (#2563EB)
                btnAtual.ForeColor = Color.White;
                btnAtual.IconColor = Color.White;
            }
        }

        private void DesativarBotao()
        {
            foreach (Control btnMenu in pnlMenuLateral.Controls)
            {
                if (btnMenu.GetType() == typeof(IconButton))
                {
                    btnMenu.BackColor = Color.FromArgb(17, 24, 39); // Fundo Lateral (#111827)
                    btnMenu.ForeColor = Color.FromArgb(156, 163, 175); // Cor de texto desativado
                    ((IconButton)btnMenu).IconColor = Color.FromArgb(156, 163, 175);
                }
            }
        }

        private void MudarTela(IconButton botao, Form novoForm)
        {
            AtivarBotao(botao);

            if (frmAtivo != null)
            {
                frmAtivo.Close();
            }

            frmAtivo = novoForm;
            novoForm.TopLevel = false;
            novoForm.FormBorderStyle = FormBorderStyle.None;
            novoForm.Dock = DockStyle.Fill;
            pnlConteudo.Controls.Add(novoForm);
            pnlConteudo.Tag = novoForm;
            novoForm.BringToFront();
            novoForm.Show();
            lblTituloJanela.Text = botao.Text;
        }

        private void btnDashboard_Click(object sender, EventArgs e) => MudarTela(btnDashboard, new FrmDashboard());
        private void btnUsuarios_Click(object sender, EventArgs e) => MudarTela(btnUsuarios, new FrmUsuarios());
        private void btnPerfil_Click(object sender, EventArgs e) => MudarTela(btnPerfil, new FrmPerfil());
        private void btnRelatorios_Click(object sender, EventArgs e) => MudarTela(btnRelatorios, new FrmRelatorios());

        private void btnSair_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Deseja realmente sair e fechar o sistema administrativo?", "Confirmação de Saída", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (result == DialogResult.Yes)
            {
                Application.Exit();
            }
        }
    }
}