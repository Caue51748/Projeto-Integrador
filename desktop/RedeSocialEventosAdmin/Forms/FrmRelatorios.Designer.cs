namespace RedeSocialEventosAdmin.Forms
{
    partial class FrmRelatorios
    {
        private System.ComponentModel.IContainer components = null;
        private Guna.UI2.WinForms.Guna2Panel pnlFundoRelatorio;
        private System.Windows.Forms.Label lblHeaderRelatorio;
        private System.Windows.Forms.Label lblLUsuarios;
        private System.Windows.Forms.Label lblLPosts;
        private System.Windows.Forms.Label lblLComentarios;
        private System.Windows.Forms.Label lblQtdUsuarios;
        private System.Windows.Forms.Label lblQtdPosts;
        private System.Windows.Forms.Label lblQtdComentarios;
        private System.Windows.Forms.Label lblDataGeracao;
        private Guna.UI2.WinForms.Guna2Separator separator1;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.pnlFundoRelatorio = new Guna.UI2.WinForms.Guna2Panel();
            this.lblHeaderRelatorio = new System.Windows.Forms.Label();
            this.lblLUsuarios = new System.Windows.Forms.Label();
            this.lblLPosts = new System.Windows.Forms.Label();
            this.lblLComentarios = new System.Windows.Forms.Label();
            this.lblQtdUsuarios = new System.Windows.Forms.Label();
            this.lblQtdPosts = new System.Windows.Forms.Label();
            this.lblQtdComentarios = new System.Windows.Forms.Label();
            this.lblDataGeracao = new System.Windows.Forms.Label();
            this.separator1 = new Guna.UI2.WinForms.Guna2Separator();
            this.pnlFundoRelatorio.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlFundoRelatorio
            // 
            this.pnlFundoRelatorio.BackColor = System.Drawing.Color.Transparent;
            this.pnlFundoRelatorio.BorderRadius = 10;
            this.pnlFundoRelatorio.Controls.Add(this.separator1);
            this.pnlFundoRelatorio.Controls.Add(this.lblDataGeracao);
            this.pnlFundoRelatorio.Controls.Add(this.lblQtdComentarios);
            this.pnlFundoRelatorio.Controls.Add(this.lblQtdPosts);
            this.pnlFundoRelatorio.Controls.Add(this.lblQtdUsuarios);
            this.pnlFundoRelatorio.Controls.Add(this.lblLComentarios);
            this.pnlFundoRelatorio.Controls.Add(this.lblLPosts);
            this.pnlFundoRelatorio.Controls.Add(this.lblLUsuarios);
            this.pnlFundoRelatorio.Controls.Add(this.lblHeaderRelatorio);
            this.pnlFundoRelatorio.FillColor = System.Drawing.Color.White;
            this.pnlFundoRelatorio.Location = new System.Drawing.Point(40, 40);
            this.pnlFundoRelatorio.Name = "pnlFundoRelatorio";
            this.pnlFundoRelatorio.Size = new System.Drawing.Size(700, 420);
            this.pnlFundoRelatorio.TabIndex = 0;
            // 
            // lblHeaderRelatorio
            // 
            this.lblHeaderRelatorio.AutoSize = true;
            this.lblHeaderRelatorio.Font = new System.Drawing.Font("Segoe UI", 16, System.Drawing.FontStyle.Bold);
            this.lblHeaderRelatorio.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblHeaderRelatorio.Location = new System.Drawing.Point(35, 30);
            this.lblHeaderRelatorio.Name = "lblHeaderRelatorio";
            this.lblHeaderRelatorio.Size = new System.Drawing.Size(325, 30);
            this.lblHeaderRelatorio.TabIndex = 0;
            this.lblHeaderRelatorio.Text = "Relatório Consolidado da Rede";
            // 
            // lblLUsuarios
            // 
            this.lblLUsuarios.AutoSize = true;
            this.lblLUsuarios.Font = new System.Drawing.Font("Segoe UI", 12);
            this.lblLUsuarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            this.lblLUsuarios.Location = new System.Drawing.Point(40, 120);
            this.lblLUsuarios.Name = "lblLUsuarios";
            this.lblLUsuarios.Size = new System.Drawing.Size(173, 21);
            this.lblLUsuarios.TabIndex = 1;
            this.lblLUsuarios.Text = "Quantidade de Usuários:";
            // 
            // lblLPosts
            // 
            this.lblLPosts.AutoSize = true;
            this.lblLPosts.Font = new System.Drawing.Font("Segoe UI", 12);
            this.lblLPosts.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            this.lblLPosts.Location = new System.Drawing.Point(40, 180);
            this.lblLPosts.Name = "lblLPosts";
            this.lblLPosts.Size = new System.Drawing.Size(148, 21);
            this.lblLPosts.TabIndex = 2;
            this.lblLPosts.Text = "Quantidade de Posts:";
            // 
            // lblLComentarios
            // 
            this.lblLComentarios.AutoSize = true;
            this.lblLComentarios.Font = new System.Drawing.Font("Segoe UI", 12);
            this.lblLComentarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            this.lblLComentarios.Location = new System.Drawing.Point(40, 240);
            this.lblLComentarios.Name = "lblLComentarios";
            this.lblLComentarios.Size = new System.Drawing.Size(200, 21);
            this.lblLComentarios.TabIndex = 3;
            this.lblLComentarios.Text = "Quantidade de Comentários:";
            // 
            // lblQtdUsuarios
            // 
            this.lblQtdUsuarios.AutoSize = true;
            this.lblQtdUsuarios.Font = new System.Drawing.Font("Segoe UI", 12, System.Drawing.FontStyle.Bold);
            this.lblQtdUsuarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblQtdUsuarios.Location = new System.Drawing.Point(300, 120);
            this.lblQtdUsuarios.Name = "lblQtdUsuarios";
            this.lblQtdUsuarios.Size = new System.Drawing.Size(19, 21);
            this.lblQtdUsuarios.TabIndex = 4;
            this.lblQtdUsuarios.Text = "0";
            // 
            // lblQtdPosts
            // 
            this.lblQtdPosts.AutoSize = true;
            this.lblQtdPosts.Font = new System.Drawing.Font("Segoe UI", 12, System.Drawing.FontStyle.Bold);
            this.lblQtdPosts.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblQtdPosts.Location = new System.Drawing.Point(300, 180);
            this.lblQtdPosts.Name = "lblQtdPosts";
            this.lblQtdPosts.Size = new System.Drawing.Size(19, 21);
            this.lblQtdPosts.TabIndex = 5;
            this.lblQtdPosts.Text = "0";
            // 
            // lblQtdComentarios
            // 
            this.lblQtdComentarios.AutoSize = true;
            this.lblQtdComentarios.Font = new System.Drawing.Font("Segoe UI", 12, System.Drawing.FontStyle.Bold);
            this.lblQtdComentarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblQtdComentarios.Location = new System.Drawing.Point(300, 240);
            this.lblQtdComentarios.Name = "lblQtdComentarios";
            this.lblQtdComentarios.Size = new System.Drawing.Size(19, 21);
            this.lblQtdComentarios.TabIndex = 6;
            this.lblQtdComentarios.Text = "0";
            // 
            // lblDataGeracao
            // 
            this.lblDataGeracao.AutoSize = true;
            this.lblDataGeracao.Font = new System.Drawing.Font("Segoe UI", 9, System.Drawing.FontStyle.Italic);
            this.lblDataGeracao.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(107)))), ((int)(((byte)(114)))), ((int)(((byte)(128)))));
            this.lblDataGeracao.Location = new System.Drawing.Point(40, 360);
            this.lblDataGeracao.Name = "lblDataGeracao";
            this.lblDataGeracao.Size = new System.Drawing.Size(95, 15);
            this.lblDataGeracao.TabIndex = 7;
            this.lblDataGeracao.Text = "Data de extração";
            // 
            // separator1
            // 
            this.separator1.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(243)))), ((int)(((byte)(244)))), ((int)(((byte)(246)))));
            this.separator1.Location = new System.Drawing.Point(40, 75);
            this.separator1.Name = "separator1";
            this.separator1.Size = new System.Drawing.Size(620, 10);
            this.separator1.TabIndex = 8;
            // 
            // FrmRelatorios
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(247)))), ((int)(((byte)(250)))));
            this.ClientSize = new System.Drawing.Size(1040, 640);
            this.Controls.Add(this.pnlFundoRelatorio);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "FrmRelatorios";
            this.Text = "Relatórios Gerenciais";
            this.Load += new System.EventHandler(this.FrmRelatorios_Load);
            this.pnlFundoRelatorio.ResumeLayout(false);
            this.pnlFundoRelatorio.PerformLayout();
            this.ResumeLayout(false);
        }
    }
}