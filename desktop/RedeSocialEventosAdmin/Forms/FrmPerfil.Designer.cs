namespace RedeSocialEventosAdmin.Forms
{
  partial class FrmPerfil
  {
    private System.ComponentModel.IContainer components = null;
    private System.Windows.Forms.Label lblHeaderTitle;
    private System.Windows.Forms.Label lblSubInfo;
    private Guna.UI2.WinForms.Guna2Panel pnlCardPerfil;
    private FontAwesome.Sharp.IconPictureBox picAvatar;
    private System.Windows.Forms.Label lblNomeAdmin;
    private System.Windows.Forms.Label lblEmailAdmin;
    private System.Windows.Forms.Label lblUsernameAdmin;
    private Guna.UI2.WinForms.Guna2Chip chipRoleBadge;
    private Guna.UI2.WinForms.Guna2Chip chipStatusBadge;
    private System.Windows.Forms.Label lblDataCriacaoAdmin;
    private Guna.UI2.WinForms.Guna2GroupBox grpPermissoes;
    private System.Windows.Forms.Label lblPerm1;
    private System.Windows.Forms.Label lblPerm2;
    private System.Windows.Forms.Label lblPerm3;
    private System.Windows.Forms.Label lblPerm4;
    private System.Windows.Forms.Label lblPerm5;
    private Guna.UI2.WinForms.Guna2Panel pnlInfoSistema;
    private System.Windows.Forms.Label lblInfoSysTitulo;
    private System.Windows.Forms.Label lblSysHost;
    private System.Windows.Forms.Label lblSysDb;
    private System.Windows.Forms.Label lblSysAuth;

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
      this.lblHeaderTitle = new System.Windows.Forms.Label();
      this.lblSubInfo = new System.Windows.Forms.Label();
      this.pnlCardPerfil = new Guna.UI2.WinForms.Guna2Panel();
      this.lblDataCriacaoAdmin = new System.Windows.Forms.Label();
      this.chipStatusBadge = new Guna.UI2.WinForms.Guna2Chip();
      this.chipRoleBadge = new Guna.UI2.WinForms.Guna2Chip();
      this.lblUsernameAdmin = new System.Windows.Forms.Label();
      this.lblEmailAdmin = new System.Windows.Forms.Label();
      this.lblNomeAdmin = new System.Windows.Forms.Label();
      this.picAvatar = new FontAwesome.Sharp.IconPictureBox();
      this.grpPermissoes = new Guna.UI2.WinForms.Guna2GroupBox();
      this.lblPerm5 = new System.Windows.Forms.Label();
      this.lblPerm4 = new System.Windows.Forms.Label();
      this.lblPerm3 = new System.Windows.Forms.Label();
      this.lblPerm2 = new System.Windows.Forms.Label();
      this.lblPerm1 = new System.Windows.Forms.Label();
      this.pnlInfoSistema = new Guna.UI2.WinForms.Guna2Panel();
      this.lblSysAuth = new System.Windows.Forms.Label();
      this.lblSysDb = new System.Windows.Forms.Label();
      this.lblSysHost = new System.Windows.Forms.Label();
      this.lblInfoSysTitulo = new System.Windows.Forms.Label();
      this.pnlCardPerfil.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.picAvatar)).BeginInit();
      this.grpPermissoes.SuspendLayout();
      this.pnlInfoSistema.SuspendLayout();
      this.SuspendLayout();
      // 
      // lblHeaderTitle
      // 
      this.lblHeaderTitle.AutoSize = true;
      this.lblHeaderTitle.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold);
      this.lblHeaderTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblHeaderTitle.Location = new System.Drawing.Point(25, 20);
      this.lblHeaderTitle.Name = "lblHeaderTitle";
      this.lblHeaderTitle.Size = new System.Drawing.Size(262, 30);
      this.lblHeaderTitle.TabIndex = 0;
      this.lblHeaderTitle.Text = "Perfil do Administrador";
      // 
      // lblSubInfo
      // 
      this.lblSubInfo.AutoSize = true;
      this.lblSubInfo.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblSubInfo.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblSubInfo.Location = new System.Drawing.Point(27, 52);
      this.lblSubInfo.Name = "lblSubInfo";
      this.lblSubInfo.Size = new System.Drawing.Size(390, 17);
      this.lblSubInfo.TabIndex = 1;
      this.lblSubInfo.Text = "Credenciais autenticadas e privilégios absolutos de administração.";
      // 
      // pnlCardPerfil
      // 
      this.pnlCardPerfil.BackColor = System.Drawing.Color.White;
      this.pnlCardPerfil.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.pnlCardPerfil.BorderRadius = 14;
      this.pnlCardPerfil.BorderThickness = 1;
      this.pnlCardPerfil.Controls.Add(this.lblDataCriacaoAdmin);
      this.pnlCardPerfil.Controls.Add(this.chipStatusBadge);
      this.pnlCardPerfil.Controls.Add(this.chipRoleBadge);
      this.pnlCardPerfil.Controls.Add(this.lblUsernameAdmin);
      this.pnlCardPerfil.Controls.Add(this.lblEmailAdmin);
      this.pnlCardPerfil.Controls.Add(this.lblNomeAdmin);
      this.pnlCardPerfil.Controls.Add(this.picAvatar);
      this.pnlCardPerfil.Location = new System.Drawing.Point(25, 90);
      this.pnlCardPerfil.Name = "pnlCardPerfil";
      this.pnlCardPerfil.Size = new System.Drawing.Size(460, 260);
      this.pnlCardPerfil.TabIndex = 2;
      // 
      // lblDataCriacaoAdmin
      // 
      this.lblDataCriacaoAdmin.AutoSize = true;
      this.lblDataCriacaoAdmin.Font = new System.Drawing.Font("Segoe UI", 9F);
      this.lblDataCriacaoAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(148)))), ((int)(((byte)(163)))), ((int)(((byte)(184)))));
      this.lblDataCriacaoAdmin.Location = new System.Drawing.Point(125, 205);
      this.lblDataCriacaoAdmin.Name = "lblDataCriacaoAdmin";
      this.lblDataCriacaoAdmin.Size = new System.Drawing.Size(176, 15);
      this.lblDataCriacaoAdmin.TabIndex = 6;
      this.lblDataCriacaoAdmin.Text = "Membro desde: 01/01/2026";
      // 
      // chipStatusBadge
      // 
      this.chipStatusBadge.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(209)))), ((int)(((byte)(250)))), ((int)(((byte)(229)))));
      this.chipStatusBadge.Font = new System.Drawing.Font("Segoe UI", 8F, System.Drawing.FontStyle.Bold);
      this.chipStatusBadge.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(5)))), ((int)(((byte)(150)))), ((int)(((byte)(105)))));
      this.chipStatusBadge.Location = new System.Drawing.Point(260, 160);
      this.chipStatusBadge.Name = "chipStatusBadge";
      this.chipStatusBadge.Size = new System.Drawing.Size(100, 28);
      this.chipStatusBadge.TabIndex = 5;
      this.chipStatusBadge.Text = "ATIVO";
      // 
      // chipRoleBadge
      // 
      this.chipRoleBadge.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.chipRoleBadge.Font = new System.Drawing.Font("Segoe UI", 8F, System.Drawing.FontStyle.Bold);
      this.chipRoleBadge.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.chipRoleBadge.Location = new System.Drawing.Point(125, 160);
      this.chipRoleBadge.Name = "chipRoleBadge";
      this.chipRoleBadge.Size = new System.Drawing.Size(125, 28);
      this.chipRoleBadge.TabIndex = 4;
      this.chipRoleBadge.Text = "SUPER ADMIN";
      // 
      // lblUsernameAdmin
      // 
      this.lblUsernameAdmin.AutoSize = true;
      this.lblUsernameAdmin.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Bold);
      this.lblUsernameAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(99)))), ((int)(((byte)(102)))), ((int)(((byte)(241)))));
      this.lblUsernameAdmin.Location = new System.Drawing.Point(125, 65);
      this.lblUsernameAdmin.Name = "lblUsernameAdmin";
      this.lblUsernameAdmin.Size = new System.Drawing.Size(56, 19);
      this.lblUsernameAdmin.TabIndex = 3;
      this.lblUsernameAdmin.Text = "@admin";
      // 
      // lblEmailAdmin
      // 
      this.lblEmailAdmin.AutoSize = true;
      this.lblEmailAdmin.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblEmailAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblEmailAdmin.Location = new System.Drawing.Point(125, 95);
      this.lblEmailAdmin.Name = "lblEmailAdmin";
      this.lblEmailAdmin.Size = new System.Drawing.Size(130, 17);
      this.lblEmailAdmin.TabIndex = 2;
      this.lblEmailAdmin.Text = "admin@socialjoin.com";
      // 
      // lblNomeAdmin
      // 
      this.lblNomeAdmin.AutoSize = true;
      this.lblNomeAdmin.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Bold);
      this.lblNomeAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblNomeAdmin.Location = new System.Drawing.Point(125, 30);
      this.lblNomeAdmin.Name = "lblNomeAdmin";
      this.lblNomeAdmin.Size = new System.Drawing.Size(206, 25);
      this.lblNomeAdmin.TabIndex = 1;
      this.lblNomeAdmin.Text = "Administrador Master";
      // 
      // picAvatar
      // 
      this.picAvatar.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.picAvatar.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.picAvatar.IconChar = FontAwesome.Sharp.IconChar.UserShield;
      this.picAvatar.IconColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.picAvatar.IconFont = FontAwesome.Sharp.IconFont.Auto;
      this.picAvatar.IconSize = 55;
      this.picAvatar.Location = new System.Drawing.Point(25, 30);
      this.picAvatar.Name = "picAvatar";
      this.picAvatar.Size = new System.Drawing.Size(80, 80);
      this.picAvatar.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
      this.picAvatar.TabIndex = 0;
      this.picAvatar.TabStop = false;
      // 
      // grpPermissoes
      // 
      this.grpPermissoes.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.grpPermissoes.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.grpPermissoes.BorderRadius = 14;
      this.grpPermissoes.Controls.Add(this.lblPerm5);
      this.grpPermissoes.Controls.Add(this.lblPerm4);
      this.grpPermissoes.Controls.Add(this.lblPerm3);
      this.grpPermissoes.Controls.Add(this.lblPerm2);
      this.grpPermissoes.Controls.Add(this.lblPerm1);
      this.grpPermissoes.CustomBorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.grpPermissoes.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Bold);
      this.grpPermissoes.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.grpPermissoes.Location = new System.Drawing.Point(510, 90);
      this.grpPermissoes.Name = "grpPermissoes";
      this.grpPermissoes.Size = new System.Drawing.Size(505, 260);
      this.grpPermissoes.TabIndex = 3;
      this.grpPermissoes.Text = "Privilégios Administrativos Absolutos";
      // 
      // lblPerm5
      // 
      this.lblPerm5.AutoSize = true;
      this.lblPerm5.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblPerm5.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.lblPerm5.Location = new System.Drawing.Point(20, 205);
      this.lblPerm5.Name = "lblPerm5";
      this.lblPerm5.Size = new System.Drawing.Size(390, 17);
      this.lblPerm5.TabIndex = 4;
      this.lblPerm5.Text = "âœ” Exportação de relatórios executivos e métricas consolidadas.";
      // 
      // lblPerm4
      // 
      this.lblPerm4.AutoSize = true;
      this.lblPerm4.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblPerm4.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.lblPerm4.Location = new System.Drawing.Point(20, 168);
      this.lblPerm4.Name = "lblPerm4";
      this.lblPerm4.Size = new System.Drawing.Size(435, 17);
      this.lblPerm4.TabIndex = 3;
      this.lblPerm4.Text = "âœ” Moderação e exclusão direta de qualquer publicação ou comentário.";
      // 
      // lblPerm3
      // 
      this.lblPerm3.AutoSize = true;
      this.lblPerm3.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblPerm3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.lblPerm3.Location = new System.Drawing.Point(20, 131);
      this.lblPerm3.Name = "lblPerm3";
      this.lblPerm3.Size = new System.Drawing.Size(445, 17);
      this.lblPerm3.TabIndex = 2;
      this.lblPerm3.Text = "âœ” Criação, edição e exclusão de comunidades e gerenciamento de membros.";
      // 
      // lblPerm2
      // 
      this.lblPerm2.AutoSize = true;
      this.lblPerm2.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblPerm2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.lblPerm2.Location = new System.Drawing.Point(20, 94);
      this.lblPerm2.Name = "lblPerm2";
      this.lblPerm2.Size = new System.Drawing.Size(440, 17);
      this.lblPerm2.TabIndex = 1;
      this.lblPerm2.Text = "âœ” Criação, alteração de status e cancelamento/exclusão total de eventos.";
      // 
      // lblPerm1
      // 
      this.lblPerm1.AutoSize = true;
      this.lblPerm1.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblPerm1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.lblPerm1.Location = new System.Drawing.Point(20, 57);
      this.lblPerm1.Name = "lblPerm1";
      this.lblPerm1.Size = new System.Drawing.Size(465, 17);
      this.lblPerm1.TabIndex = 0;
      this.lblPerm1.Text = "âœ” Atribuição e revogação de qualquer Role e Status em contas de usuários.";
      // 
      // pnlInfoSistema
      // 
      this.pnlInfoSistema.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.pnlInfoSistema.BackColor = System.Drawing.Color.White;
      this.pnlInfoSistema.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.pnlInfoSistema.BorderRadius = 14;
      this.pnlInfoSistema.BorderThickness = 1;
      this.pnlInfoSistema.Controls.Add(this.lblSysAuth);
      this.pnlInfoSistema.Controls.Add(this.lblSysDb);
      this.pnlInfoSistema.Controls.Add(this.lblSysHost);
      this.pnlInfoSistema.Controls.Add(this.lblInfoSysTitulo);
      this.pnlInfoSistema.Location = new System.Drawing.Point(25, 370);
      this.pnlInfoSistema.Name = "pnlInfoSistema";
      this.pnlInfoSistema.Size = new System.Drawing.Size(990, 140);
      this.pnlInfoSistema.TabIndex = 4;
      // 
      // lblSysAuth
      // 
      this.lblSysAuth.AutoSize = true;
      this.lblSysAuth.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblSysAuth.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblSysAuth.Location = new System.Drawing.Point(25, 95);
      this.lblSysAuth.Name = "lblSysAuth";
      this.lblSysAuth.Size = new System.Drawing.Size(325, 17);
      this.lblSysAuth.TabIndex = 3;
      this.lblSysAuth.Text = "Nível de Segurança: Restrição Obrigatória 'Role Admin'";
      // 
      // lblSysDb
      // 
      this.lblSysDb.AutoSize = true;
      this.lblSysDb.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblSysDb.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblSysDb.Location = new System.Drawing.Point(25, 68);
      this.lblSysDb.Name = "lblSysDb";
      this.lblSysDb.Size = new System.Drawing.Size(262, 17);
      this.lblSysDb.TabIndex = 2;
      this.lblSysDb.Text = "Banco de Dados: cl203108 (MySQL Server)";
      // 
      // lblSysHost
      // 
      this.lblSysHost.AutoSize = true;
      this.lblSysHost.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblSysHost.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblSysHost.Location = new System.Drawing.Point(25, 42);
      this.lblSysHost.Name = "lblSysHost";
      this.lblSysHost.Size = new System.Drawing.Size(298, 17);
      this.lblSysHost.TabIndex = 1;
      this.lblSysHost.Text = "Servidor Corporativo: 143.106.241.3 (Conectado)";
      // 
      // lblInfoSysTitulo
      // 
      this.lblInfoSysTitulo.AutoSize = true;
      this.lblInfoSysTitulo.Font = new System.Drawing.Font("Segoe UI", 11F, System.Drawing.FontStyle.Bold);
      this.lblInfoSysTitulo.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblInfoSysTitulo.Location = new System.Drawing.Point(25, 15);
      this.lblInfoSysTitulo.Name = "lblInfoSysTitulo";
      this.lblInfoSysTitulo.Size = new System.Drawing.Size(188, 20);
      this.lblInfoSysTitulo.TabIndex = 0;
      this.lblInfoSysTitulo.Text = "Infraestrutura do Sistema";
      // 
      // FrmPerfil
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.ClientSize = new System.Drawing.Size(1040, 640);
      this.Controls.Add(this.pnlInfoSistema);
      this.Controls.Add(this.grpPermissoes);
      this.Controls.Add(this.pnlCardPerfil);
      this.Controls.Add(this.lblSubInfo);
      this.Controls.Add(this.lblHeaderTitle);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
      this.Name = "FrmPerfil";
      this.Text = "Meu Perfil";
      this.Load += new System.EventHandler(this.FrmPerfil_Load);
      this.pnlCardPerfil.ResumeLayout(false);
      this.pnlCardPerfil.PerformLayout();
      ((System.ComponentModel.ISupportInitialize)(this.picAvatar)).EndInit();
      this.grpPermissoes.ResumeLayout(false);
      this.grpPermissoes.PerformLayout();
      this.pnlInfoSistema.ResumeLayout(false);
      this.pnlInfoSistema.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();
    }
  }
}
