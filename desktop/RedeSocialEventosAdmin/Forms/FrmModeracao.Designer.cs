namespace RedeSocialEventosAdmin.Forms
{
  partial class FrmModeracao
  {
    private System.ComponentModel.IContainer components = null;
    private Guna.UI2.WinForms.Guna2TextBox txtPesquisa;
    private Guna.UI2.WinForms.Guna2Button btnExcluir;
    private Guna.UI2.WinForms.Guna2Button btnRefresh;
    private Guna.UI2.WinForms.Guna2Button btnTabPosts;
    private Guna.UI2.WinForms.Guna2Button btnTabComentarios;
    private Guna.UI2.WinForms.Guna2DataGridView dgvConteudo;
    private System.Windows.Forms.Label lblHeaderTitle;
    private System.Windows.Forms.Label lblTotalRegistros;
    private Guna.UI2.WinForms.Guna2Panel pnlFiltros;

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
      this.txtPesquisa = new Guna.UI2.WinForms.Guna2TextBox();
      this.btnExcluir = new Guna.UI2.WinForms.Guna2Button();
      this.btnRefresh = new Guna.UI2.WinForms.Guna2Button();
      this.btnTabPosts = new Guna.UI2.WinForms.Guna2Button();
      this.btnTabComentarios = new Guna.UI2.WinForms.Guna2Button();
      this.dgvConteudo = new Guna.UI2.WinForms.Guna2DataGridView();
      this.lblHeaderTitle = new System.Windows.Forms.Label();
      this.lblTotalRegistros = new System.Windows.Forms.Label();
      this.pnlFiltros = new Guna.UI2.WinForms.Guna2Panel();
      this.pnlFiltros.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dgvConteudo)).BeginInit();
      this.SuspendLayout();
      // 
      // lblHeaderTitle
      // 
      this.lblHeaderTitle.AutoSize = true;
      this.lblHeaderTitle.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold);
      this.lblHeaderTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblHeaderTitle.Location = new System.Drawing.Point(25, 20);
      this.lblHeaderTitle.Name = "lblHeaderTitle";
      this.lblHeaderTitle.Size = new System.Drawing.Size(395, 30);
      this.lblHeaderTitle.TabIndex = 0;
      this.lblHeaderTitle.Text = "Moderação e Auditoria de Conteúdo";
      // 
      // lblTotalRegistros
      // 
      this.lblTotalRegistros.AutoSize = true;
      this.lblTotalRegistros.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblTotalRegistros.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblTotalRegistros.Location = new System.Drawing.Point(27, 52);
      this.lblTotalRegistros.Name = "lblTotalRegistros";
      this.lblTotalRegistros.Size = new System.Drawing.Size(270, 17);
      this.lblTotalRegistros.TabIndex = 1;
      this.lblTotalRegistros.Text = "Monitore e modere posts e comentários...";
      // 
      // pnlFiltros
      // 
      this.pnlFiltros.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.pnlFiltros.BackColor = System.Drawing.Color.Transparent;
      this.pnlFiltros.Controls.Add(this.btnTabPosts);
      this.pnlFiltros.Controls.Add(this.btnTabComentarios);
      this.pnlFiltros.Controls.Add(this.btnRefresh);
      this.pnlFiltros.Controls.Add(this.btnExcluir);
      this.pnlFiltros.Controls.Add(this.txtPesquisa);
      this.pnlFiltros.Location = new System.Drawing.Point(25, 80);
      this.pnlFiltros.Name = "pnlFiltros";
      this.pnlFiltros.Size = new System.Drawing.Size(990, 50);
      this.pnlFiltros.TabIndex = 2;
      // 
      // btnTabPosts
      // 
      this.btnTabPosts.BorderRadius = 8;
      this.btnTabPosts.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnTabPosts.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.btnTabPosts.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
      this.btnTabPosts.ForeColor = System.Drawing.Color.White;
      this.btnTabPosts.Location = new System.Drawing.Point(0, 5);
      this.btnTabPosts.Name = "btnTabPosts";
      this.btnTabPosts.Size = new System.Drawing.Size(140, 38);
      this.btnTabPosts.TabIndex = 0;
      this.btnTabPosts.Text = " Publicações";
      this.btnTabPosts.Click += new System.EventHandler(this.btnTabPosts_Click);
      // 
      // btnTabComentarios
      // 
      this.btnTabComentarios.BorderRadius = 8;
      this.btnTabComentarios.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnTabComentarios.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.btnTabComentarios.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
      this.btnTabComentarios.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.btnTabComentarios.Location = new System.Drawing.Point(150, 5);
      this.btnTabComentarios.Name = "btnTabComentarios";
      this.btnTabComentarios.Size = new System.Drawing.Size(140, 38);
      this.btnTabComentarios.TabIndex = 1;
      this.btnTabComentarios.Text = " Comentários";
      this.btnTabComentarios.Click += new System.EventHandler(this.btnTabComentarios_Click);
      // 
      // txtPesquisa
      // 
      this.txtPesquisa.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.txtPesquisa.BorderRadius = 8;
      this.txtPesquisa.Cursor = System.Windows.Forms.Cursors.IBeam;
      this.txtPesquisa.DefaultText = "";
      this.txtPesquisa.FocusedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(99)))), ((int)(((byte)(102)))), ((int)(((byte)(241)))));
      this.txtPesquisa.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.txtPesquisa.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.txtPesquisa.HoverState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.txtPesquisa.Location = new System.Drawing.Point(310, 5);
      this.txtPesquisa.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
      this.txtPesquisa.Name = "txtPesquisa";
      this.txtPesquisa.PlaceholderText = " Buscar por conteúdo, autor ou título...";
      this.txtPesquisa.SelectedText = "";
      this.txtPesquisa.Size = new System.Drawing.Size(380, 38);
      this.txtPesquisa.TabIndex = 2;
      this.txtPesquisa.TextChanged += new System.EventHandler(this.txtPesquisa_TextChanged);
      // 
      // btnExcluir
      // 
      this.btnExcluir.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnExcluir.BorderRadius = 8;
      this.btnExcluir.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnExcluir.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(254)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
      this.btnExcluir.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
      this.btnExcluir.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
      this.btnExcluir.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(254)))), ((int)(((byte)(202)))), ((int)(((byte)(202)))));
      this.btnExcluir.Location = new System.Drawing.Point(790, 5);
      this.btnExcluir.Name = "btnExcluir";
      this.btnExcluir.Size = new System.Drawing.Size(150, 38);
      this.btnExcluir.TabIndex = 3;
      this.btnExcluir.Text = " Remover Item";
      this.btnExcluir.Click += new System.EventHandler(this.btnExcluir_Click);
      // 
      // btnRefresh
      // 
      this.btnRefresh.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnRefresh.BorderRadius = 8;
      this.btnRefresh.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnRefresh.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.btnRefresh.Font = new System.Drawing.Font("Segoe UI", 10F);
      this.btnRefresh.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.btnRefresh.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.btnRefresh.Location = new System.Drawing.Point(950, 5);
      this.btnRefresh.Name = "btnRefresh";
      this.btnRefresh.Size = new System.Drawing.Size(40, 38);
      this.btnRefresh.TabIndex = 4;
      this.btnRefresh.Text = "";
      this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
      // 
      // dgvConteudo
      // 
      this.dgvConteudo.AllowUserToAddRows = false;
      this.dgvConteudo.AllowUserToDeleteRows = false;
      this.dgvConteudo.AllowUserToResizeRows = false;
      dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvConteudo.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
      this.dgvConteudo.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.dgvConteudo.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvConteudo.BackgroundColor = System.Drawing.Color.White;
      this.dgvConteudo.BorderStyle = System.Windows.Forms.BorderStyle.None;
      this.dgvConteudo.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvConteudo.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
      dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
      dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
      this.dgvConteudo.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
      this.dgvConteudo.ColumnHeadersHeight = 42;
      dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle3.BackColor = System.Drawing.Color.White;
      dataGridViewCellStyle3.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      dataGridViewCellStyle3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
      this.dgvConteudo.DefaultCellStyle = dataGridViewCellStyle3;
      this.dgvConteudo.EnableHeadersVisualStyles = false;
      this.dgvConteudo.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvConteudo.Location = new System.Drawing.Point(25, 140);
      this.dgvConteudo.MultiSelect = false;
      this.dgvConteudo.Name = "dgvConteudo";
      this.dgvConteudo.ReadOnly = true;
      this.dgvConteudo.RowHeadersVisible = false;
      this.dgvConteudo.RowTemplate.Height = 36;
      this.dgvConteudo.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
      this.dgvConteudo.Size = new System.Drawing.Size(990, 470);
      this.dgvConteudo.TabIndex = 3;
      this.dgvConteudo.ThemeStyle.AlternatingRowsStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvConteudo.ThemeStyle.BackColor = System.Drawing.Color.White;
      this.dgvConteudo.ThemeStyle.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvConteudo.ThemeStyle.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.dgvConteudo.ThemeStyle.HeaderStyle.BorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      this.dgvConteudo.ThemeStyle.HeaderStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      this.dgvConteudo.ThemeStyle.HeaderStyle.ForeColor = System.Drawing.Color.White;
      this.dgvConteudo.ThemeStyle.ReadOnly = true;
      this.dgvConteudo.ThemeStyle.RowsStyle.BackColor = System.Drawing.Color.White;
      this.dgvConteudo.ThemeStyle.RowsStyle.BorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvConteudo.ThemeStyle.RowsStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.dgvConteudo.ThemeStyle.RowsStyle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.dgvConteudo.ThemeStyle.RowsStyle.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.dgvConteudo.ThemeStyle.RowsStyle.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      // 
      // FrmModeracao
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.ClientSize = new System.Drawing.Size(1040, 640);
      this.Controls.Add(this.dgvConteudo);
      this.Controls.Add(this.pnlFiltros);
      this.Controls.Add(this.lblTotalRegistros);
      this.Controls.Add(this.lblHeaderTitle);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
      this.Name = "FrmModeracao";
      this.Text = "Moderação de Conteúdo";
      this.Load += new System.EventHandler(this.FrmModeracao_Load);
      this.pnlFiltros.ResumeLayout(false);
      ((System.ComponentModel.ISupportInitialize)(this.dgvConteudo)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();
    }
  }
}
