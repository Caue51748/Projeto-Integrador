namespace RedeSocialEventosAdmin.Forms
{
    partial class FrmPerfil
    {
        private System.ComponentModel.IContainer components = null;
        private Guna.UI2.WinForms.Guna2Panel pnlCardPerfil;
        private FontAwesome.Sharp.IconPictureBox picAvatar;
        private System.Windows.Forms.Label lblNomeAdmin;
        private System.Windows.Forms.Label lblEmailAdmin;
        private System.Windows.Forms.Label lblDataCriacaoAdmin;
        private System.Windows.Forms.Label lblRotuloData;
        private System.Windows.Forms.Label lblRotuloEmail;
        private System.Windows.Forms.Label lblRotuloNome;

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
            this.pnlCardPerfil = new Guna.UI2.WinForms.Guna2Panel();
            this.picAvatar = new FontAwesome.Sharp.IconPictureBox();
            this.lblNomeAdmin = new System.Windows.Forms.Label();
            this.lblEmailAdmin = new System.Windows.Forms.Label();
            this.lblDataCriacaoAdmin = new System.Windows.Forms.Label();
            this.lblRotuloNome = new System.Windows.Forms.Label();
            this.lblRotuloEmail = new System.Windows.Forms.Label();
            this.lblRotuloData = new System.Windows.Forms.Label();
            this.pnlCardPerfil.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picAvatar)).BeginInit();
            this.SuspendLayout();
            // 
            // pnlCardPerfil
            // 
            this.pnlCardPerfil.BackColor = System.Drawing.Color.Transparent;
            this.pnlCardPerfil.BorderRadius = 10;
            this.pnlCardPerfil.Controls.Add(this.lblRotuloData);
            this.pnlCardPerfil.Controls.Add(this.lblRotuloEmail);
            this.pnlCardPerfil.Controls.Add(this.lblRotuloNome);
            this.pnlCardPerfil.Controls.Add(this.lblDataCriacaoAdmin);
            this.pnlCardPerfil.Controls.Add(this.lblEmailAdmin);
            this.pnlCardPerfil.Controls.Add(this.lblNomeAdmin);
            this.pnlCardPerfil.Controls.Add(this.picAvatar);
            this.pnlCardPerfil.FillColor = System.Drawing.Color.White;
            this.pnlCardPerfil.Location = new System.Drawing.Point(40, 40);
            this.pnlCardPerfil.Name = "pnlCardPerfil";
            this.pnlCardPerfil.Size = new System.Drawing.Size(500, 380);
            this.pnlCardPerfil.TabIndex = 0;
            // 
            // picAvatar
            // 
            this.picAvatar.BackColor = System.Drawing.Color.Transparent;
            this.picAvatar.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(156)))), ((int)(((byte)(163)))), ((int)(((byte)(175)))));
            this.picAvatar.IconChar = FontAwesome.Sharp.IconChar.UserCircle;
            this.picAvatar.IconColor = System.Drawing.Color.FromArgb(((int)(((byte)(156)))), ((int)(((byte)(163)))), ((int)(((byte)(175)))));
            this.picAvatar.IconFont = FontAwesome.Sharp.IconFont.Auto;
            this.picAvatar.IconSize = 100;
            this.picAvatar.Location = new System.Drawing.Point(200, 30);
            this.picAvatar.Name = "picAvatar";
            this.picAvatar.Size = new System.Drawing.Size(100, 100);
            this.picAvatar.TabIndex = 0;
            this.picAvatar.TabStop = false;
            // 
            // lblNomeAdmin
            // 
            this.lblNomeAdmin.AutoSize = true;
            this.lblNomeAdmin.Font = new System.Drawing.Font("Segoe UI", 12, System.Drawing.FontStyle.Bold);
            this.lblNomeAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblNomeAdmin.Location = new System.Drawing.Point(180, 185);
            this.lblNomeAdmin.Name = "lblNomeAdmin";
            this.lblNomeAdmin.Size = new System.Drawing.Size(57, 21);
            this.lblNomeAdmin.TabIndex = 1;
            this.lblNomeAdmin.Text = "Nome";
            // 
            // lblEmailAdmin
            // 
            this.lblEmailAdmin.AutoSize = true;
            this.lblEmailAdmin.Font = new System.Drawing.Font("Segoe UI", 12);
            this.lblEmailAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            this.lblEmailAdmin.Location = new System.Drawing.Point(180, 245);
            this.lblEmailAdmin.Name = "lblEmailAdmin";
            this.lblEmailAdmin.Size = new System.Drawing.Size(54, 21);
            this.lblEmailAdmin.TabIndex = 2;
            this.lblEmailAdmin.Text = "E-mail";
            // 
            // lblDataCriacaoAdmin
            // 
            this.lblDataCriacaoAdmin.AutoSize = true;
            this.lblDataCriacaoAdmin.Font = new System.Drawing.Font("Segoe UI", 12);
            this.lblDataCriacaoAdmin.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(107)))), ((int)(((byte)(114)))), ((int)(((byte)(128)))));
            this.lblDataCriacaoAdmin.Location = new System.Drawing.Point(180, 305);
            this.lblDataCriacaoAdmin.Name = "lblDataCriacaoAdmin";
            this.lblDataCriacaoAdmin.Size = new System.Drawing.Size(42, 21);
            this.lblDataCriacaoAdmin.TabIndex = 3;
            this.lblDataCriacaoAdmin.Text = "Data";
            // 
            // lblRotuloNome
            // 
            this.lblRotuloNome.AutoSize = true;
            this.lblRotuloNome.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblRotuloNome.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(156)))), ((int)(((byte)(163)))), ((int)(((byte)(175)))));
            this.lblRotuloNome.Location = new System.Drawing.Point(40, 185);
            this.lblRotuloNome.Name = "lblRotuloNome";
            this.lblRotuloNome.Size = new System.Drawing.Size(121, 19);
            this.lblRotuloNome.TabIndex = 4;
            this.lblRotuloNome.Text = "NOME USUÁRIO:";
            // 
            // lblRotuloEmail
            // 
            this.lblRotuloEmail.AutoSize = true;
            this.lblRotuloEmail.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblRotuloEmail.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(156)))), ((int)(((byte)(163)))), ((int)(((byte)(175)))));
            this.lblRotuloEmail.Location = new System.Drawing.Point(40, 247);
            this.lblRotuloEmail.Name = "lblRotuloEmail";
            this.lblRotuloEmail.Size = new System.Drawing.Size(61, 19);
            this.lblRotuloEmail.TabIndex = 5;
            this.lblRotuloEmail.Text = "EMAIL:";
            // 
            // lblRotuloData
            // 
            this.lblRotuloData.AutoSize = true;
            this.lblRotuloData.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblRotuloData.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(156)))), ((int)(((byte)(163)))), ((int)(((byte)(175)))));
            this.lblRotuloData.Location = new System.Drawing.Point(40, 307);
            this.lblRotuloData.Name = "lblRotuloData";
            this.lblRotuloData.Size = new System.Drawing.Size(117, 19);
            this.lblRotuloData.TabIndex = 6;
            this.lblRotuloData.Text = "CADASTRADO EM:";
            // 
            // FrmPerfil
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(247)))), ((int)(((byte)(250)))));
            this.ClientSize = new System.Drawing.Size(1040, 640);
            this.Controls.Add(this.pnlCardPerfil);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "FrmPerfil";
            this.Text = "Perfil de Acesso";
            this.Load += new System.EventHandler(this.FrmPerfil_Load);
            this.pnlCardPerfil.ResumeLayout(false);
            this.pnlCardPerfil.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picAvatar)).EndInit();
            this.ResumeLayout(false);
        }
    }
}