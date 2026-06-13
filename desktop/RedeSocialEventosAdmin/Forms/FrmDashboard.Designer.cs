namespace RedeSocialEventosAdmin.Forms
{
    partial class FrmDashboard
    {
        private System.ComponentModel.IContainer components = null;
        private Guna.UI2.WinForms.Guna2Panel card1;
        private Guna.UI2.WinForms.Guna2Panel card2;
        private Guna.UI2.WinForms.Guna2Panel card3;
        private Guna.UI2.WinForms.Guna2Panel card4;
        private System.Windows.Forms.Label lblTotalUsuarios;
        private System.Windows.Forms.Label lblTxtCard1;
        private System.Windows.Forms.Label lblUsuariosHoje;
        private System.Windows.Forms.Label lblTxtCard2;
        private System.Windows.Forms.Label lblTotalPosts;
        private System.Windows.Forms.Label lblTxtCard3;
        private System.Windows.Forms.Label lblTotalComentarios;
        private System.Windows.Forms.Label lblTxtCard4;
        private Guna.UI2.WinForms.Guna2DataGridView dgvUltimosUsuarios;
        private System.Windows.Forms.Label lblTituloGrid;

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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            this.card1 = new Guna.UI2.WinForms.Guna2Panel();
            this.lblTotalUsuarios = new System.Windows.Forms.Label();
            this.lblTxtCard1 = new System.Windows.Forms.Label();
            this.card2 = new Guna.UI2.WinForms.Guna2Panel();
            this.lblUsuariosHoje = new System.Windows.Forms.Label();
            this.lblTxtCard2 = new System.Windows.Forms.Label();
            this.card3 = new Guna.UI2.WinForms.Guna2Panel();
            this.lblTotalPosts = new System.Windows.Forms.Label();
            this.lblTxtCard3 = new System.Windows.Forms.Label();
            this.card4 = new Guna.UI2.WinForms.Guna2Panel();
            this.lblTotalComentarios = new System.Windows.Forms.Label();
            this.lblTxtCard4 = new System.Windows.Forms.Label();
            this.dgvUltimosUsuarios = new Guna.UI2.WinForms.Guna2DataGridView();
            this.lblTituloGrid = new System.Windows.Forms.Label();
            this.card1.SuspendLayout();
            this.card2.SuspendLayout();
            this.card3.SuspendLayout();
            this.card4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvUltimosUsuarios)).BeginInit();
            this.SuspendLayout();
            // 
            // card1
            // 
            this.card1.BackColor = System.Drawing.Color.Transparent;
            this.card1.BorderRadius = 8;
            this.card1.Controls.Add(this.lblTotalUsuarios);
            this.card1.Controls.Add(this.lblTxtCard1);
            this.card1.FillColor = System.Drawing.Color.White;
            this.card1.Location = new System.Drawing.Point(30, 30);
            this.card1.Name = "card1";
            this.card1.Size = new System.Drawing.Size(220, 110);
            this.card1.TabIndex = 0;
            // 
            // lblTotalUsuarios
            // 
            this.lblTotalUsuarios.Font = new System.Drawing.Font("Segoe UI", 22, System.Drawing.FontStyle.Bold);
            this.lblTotalUsuarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblTotalUsuarios.Location = new System.Drawing.Point(15, 45);
            this.lblTotalUsuarios.Name = "lblTotalUsuarios";
            this.lblTotalUsuarios.Size = new System.Drawing.Size(190, 45);
            this.lblTotalUsuarios.TabIndex = 1;
            this.lblTotalUsuarios.Text = "0";
            // 
            // lblTxtCard1
            // 
            this.lblTxtCard1.AutoSize = true;
            this.lblTxtCard1.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblTxtCard1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(107)))), ((int)(((byte)(114)))), ((int)(((byte)(128)))));
            this.lblTxtCard1.Location = new System.Drawing.Point(15, 15);
            this.lblTxtCard1.Name = "lblTxtCard1";
            this.lblTxtCard1.Size = new System.Drawing.Size(102, 19);
            this.lblTxtCard1.TabIndex = 0;
            this.lblTxtCard1.Text = "Total Usuários";
            // 
            // card2
            // 
            this.card2.BackColor = System.Drawing.Color.Transparent;
            this.card2.BorderRadius = 8;
            this.card2.Controls.Add(this.lblUsuariosHoje);
            this.card2.Controls.Add(this.lblTxtCard2);
            this.card2.FillColor = System.Drawing.Color.White;
            this.card2.Location = new System.Drawing.Point(280, 30);
            this.card2.Name = "card2";
            this.card2.Size = new System.Drawing.Size(220, 110);
            this.card2.TabIndex = 2;
            // 
            // lblUsuariosHoje
            // 
            this.lblUsuariosHoje.Font = new System.Drawing.Font("Segoe UI", 22, System.Drawing.FontStyle.Bold);
            this.lblUsuariosHoje.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(37)))), ((int)(((byte)(99)))), ((int)(((byte)(235)))));
            this.lblUsuariosHoje.Location = new System.Drawing.Point(15, 45);
            this.lblUsuariosHoje.Name = "lblUsuariosHoje";
            this.lblUsuariosHoje.Size = new System.Drawing.Size(190, 45);
            this.lblUsuariosHoje.TabIndex = 1;
            this.lblUsuariosHoje.Text = "0";
            // 
            // lblTxtCard2
            // 
            this.lblTxtCard2.AutoSize = true;
            this.lblTxtCard2.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblTxtCard2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(107)))), ((int)(((byte)(114)))), ((int)(((byte)(128)))));
            this.lblTxtCard2.Location = new System.Drawing.Point(15, 15);
            this.lblTxtCard2.Name = "lblTxtCard2";
            this.lblTxtCard2.Size = new System.Drawing.Size(123, 19);
            this.lblTxtCard2.TabIndex = 0;
            this.lblTxtCard2.Text = "Cadastrados Hoje";
            // 
            // card3
            // 
            this.card3.BackColor = System.Drawing.Color.Transparent;
            this.card3.BorderRadius = 8;
            this.card3.Controls.Add(this.lblTotalPosts);
            this.card3.Controls.Add(this.lblTxtCard3);
            this.card3.FillColor = System.Drawing.Color.White;
            this.card3.Location = new System.Drawing.Point(530, 30);
            this.card3.Name = "card3";
            this.card3.Size = new System.Drawing.Size(220, 110);
            this.card3.TabIndex = 2;
            // 
            // lblTotalPosts
            // 
            this.lblTotalPosts.Font = new System.Drawing.Font("Segoe UI", 22, System.Drawing.FontStyle.Bold);
            this.lblTotalPosts.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblTotalPosts.Location = new System.Drawing.Point(15, 45);
            this.lblTotalPosts.Name = "lblTotalPosts";
            this.lblTotalPosts.Size = new System.Drawing.Size(190, 45);
            this.lblTotalPosts.TabIndex = 1;
            this.lblTotalPosts.Text = "0";
            // 
            // lblTxtCard3
            // 
            this.lblTxtCard3.AutoSize = true;
            this.lblTxtCard3.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblTxtCard3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(107)))), ((int)(((byte)(114)))), ((int)(((byte)(128)))));
            this.lblTxtCard3.Location = new System.Drawing.Point(15, 15);
            this.lblTxtCard3.Name = "lblTxtCard3";
            this.lblTxtCard3.Size = new System.Drawing.Size(81, 19);
            this.lblTxtCard3.TabIndex = 0;
            this.lblTxtCard3.Text = "Total Posts";
            // 
            // card4
            // 
            this.card4.BackColor = System.Drawing.Color.Transparent;
            this.card4.BorderRadius = 8;
            this.card4.Controls.Add(this.lblTotalComentarios);
            this.card4.Controls.Add(this.lblTxtCard4);
            this.card4.FillColor = System.Drawing.Color.White;
            this.card4.Location = new System.Drawing.Point(780, 30);
            this.card4.Name = "card4";
            this.card4.Size = new System.Drawing.Size(220, 110);
            this.card4.TabIndex = 3;
            // 
            // lblTotalComentarios
            // 
            this.lblTotalComentarios.Font = new System.Drawing.Font("Segoe UI", 22, System.Drawing.FontStyle.Bold);
            this.lblTotalComentarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblTotalComentarios.Location = new System.Drawing.Point(15, 45);
            this.lblTotalComentarios.Name = "lblTotalComentarios";
            this.lblTotalComentarios.Size = new System.Drawing.Size(190, 45);
            this.lblTotalComentarios.TabIndex = 1;
            this.lblTotalComentarios.Text = "0";
            // 
            // lblTxtCard4
            // 
            this.lblTxtCard4.AutoSize = true;
            this.lblTxtCard4.Font = new System.Drawing.Font("Segoe UI", 10, System.Drawing.FontStyle.Bold);
            this.lblTxtCard4.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(107)))), ((int)(((byte)(114)))), ((int)(((byte)(128)))));
            this.lblTxtCard4.Location = new System.Drawing.Point(15, 15);
            this.lblTxtCard4.Name = "lblTxtCard4 click";
            this.lblTxtCard4.Size = new System.Drawing.Size(133, 19);
            this.lblTxtCard4.TabIndex = 0;
            this.lblTxtCard4.Text = "Total Comentários";
            // 
            // dgvUltimosUsuarios
            // 
            this.dgvUltimosUsuarios.AllowUserToAddRows = false;
            this.dgvUltimosUsuarios.AllowUserToDeleteRows = false;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.White;
            this.dgvUltimosUsuarios.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvUltimosUsuarios.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvUltimosUsuarios.BackgroundColor = System.Drawing.Color.White;
            this.dgvUltimosUsuarios.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvUltimosUsuarios.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
            this.dgvUltimosUsuarios.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(37)))), ((int)(((byte)(99)))), ((int)(((byte)(235)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Segoe UI", 10.5F, System.Drawing.FontStyle.Bold);
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvUltimosUsuarios.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.dgvUltimosUsuarios.ColumnHeadersHeight = 40;
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.White;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Segoe UI", 10.5F);
            dataGridViewCellStyle3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(233)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(37)))), ((int)(((byte)(99)))), ((int)(((byte)(235)))));
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvUltimosUsuarios.DefaultCellStyle = dataGridViewCellStyle3;
            this.dgvUltimosUsuarios.EnableHeadersVisualStyles = false;
            this.dgvUltimosUsuarios.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(243)))), ((int)(((byte)(244)))), ((int)(((byte)(246)))));
            this.dgvUltimosUsuarios.Location = new System.Drawing.Point(30, 210);
            this.dgvUltimosUsuarios.Name = "dgvUltimosUsuarios";
            this.dgvUltimosUsuarios.ReadOnly = true;
            this.dgvUltimosUsuarios.RowHeadersVisible = false;
            this.dgvUltimosUsuarios.RowTemplate.Height = 35;
            this.dgvUltimosUsuarios.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvUltimosUsuarios.Size = new System.Drawing.Size(970, 400);
            this.dgvUltimosUsuarios.TabIndex = 4;
            this.dgvUltimosUsuarios.ThemeStyle.AlternatingRowsStyle.BackColor = System.Drawing.Color.White;
            this.dgvUltimosUsuarios.ThemeStyle.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(37)))), ((int)(((byte)(99)))), ((int)(((byte)(235)))));
            this.dgvUltimosUsuarios.ThemeStyle.HeaderStyle.BorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
            this.dgvUltimosUsuarios.ThemeStyle.HeaderStyle.Font = new System.Drawing.Font("Segoe UI", 10.5F, System.Drawing.FontStyle.Bold);
            this.dgvUltimosUsuarios.ThemeStyle.HeaderStyle.ForeColor = System.Drawing.Color.White;
            this.dgvUltimosUsuarios.ThemeStyle.ReadOnly = true;
            this.dgvUltimosUsuarios.ThemeStyle.RowsStyle.BackColor = System.Drawing.Color.White;
            this.dgvUltimosUsuarios.ThemeStyle.RowsStyle.BorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
            this.dgvUltimosUsuarios.ThemeStyle.RowsStyle.Font = new System.Drawing.Font("Segoe UI", 10.5F);
            this.dgvUltimosUsuarios.ThemeStyle.RowsStyle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            this.dgvUltimosUsuarios.ThemeStyle.RowsStyle.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(233)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
            this.dgvUltimosUsuarios.ThemeStyle.RowsStyle.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(37)))), ((int)(((byte)(99)))), ((int)(((byte)(235)))));
            // 
            // lblTituloGrid
            // 
            this.lblTituloGrid.AutoSize = true;
            this.lblTituloGrid.Font = new System.Drawing.Font("Segoe UI", 14, System.Drawing.FontStyle.Bold);
            this.lblTituloGrid.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(65)))), ((int)(((byte)(81)))));
            this.lblTituloGrid.Location = new System.Drawing.Point(25, 175);
            this.lblTituloGrid.Name = "lblTituloGrid";
            this.lblTituloGrid.Size = new System.Drawing.Size(263, 25);
            this.lblTituloGrid.TabIndex = 5;
            this.lblTituloGrid.Text = "Últimos Usuários Cadastrados";
            // 
            // FrmDashboard
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(247)))), ((int)(((byte)(250)))));
            this.ClientSize = new System.Drawing.Size(1040, 640);
            this.Controls.Add(this.lblTituloGrid);
            this.Controls.Add(this.dgvUltimosUsuarios);
            this.Controls.Add(this.card4);
            this.Controls.Add(this.card3);
            this.Controls.Add(this.card2);
            this.Controls.Add(this.card1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "FrmDashboard";
            this.Text = "Dashboard";
            this.Load += new System.EventHandler(this.FrmDashboard_Load);
            this.card1.ResumeLayout(false);
            this.card1.PerformLayout();
            this.card2.ResumeLayout(false);
            this.card2.PerformLayout();
            this.card3.ResumeLayout(false);
            this.card3.PerformLayout();
            this.card4.ResumeLayout(false);
            this.card4.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvUltimosUsuarios)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();
        }
    }
}