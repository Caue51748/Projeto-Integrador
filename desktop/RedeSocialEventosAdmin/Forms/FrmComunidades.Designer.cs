namespace RedeSocialEventosAdmin.Forms
{
  partial class FrmComunidades
  {
    private System.ComponentModel.IContainer components = null;
    private Guna.UI2.WinForms.Guna2TextBox txtPesquisa;
    private Guna.UI2.WinForms.Guna2Button btnNovo;
    private Guna.UI2.WinForms.Guna2Button btnEditar;
    private Guna.UI2.WinForms.Guna2Button btnMembros;
    private Guna.UI2.WinForms.Guna2Button btnExcluir;
    private Guna.UI2.WinForms.Guna2Button btnRefresh;
    private Guna.UI2.WinForms.Guna2DataGridView dgvComunidades;
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
      this.btnNovo = new Guna.UI2.WinForms.Guna2Button();
      this.btnEditar = new Guna.UI2.WinForms.Guna2Button();
      this.btnMembros = new Guna.UI2.WinForms.Guna2Button();
      this.btnExcluir = new Guna.UI2.WinForms.Guna2Button();
      this.btnRefresh = new Guna.UI2.WinForms.Guna2Button();
      this.dgvComunidades = new Guna.UI2.WinForms.Guna2DataGridView();
      this.lblHeaderTitle = new System.Windows.Forms.Label();
      this.lblTotalRegistros = new System.Windows.Forms.Label();
      this.pnlFiltros = new Guna.UI2.WinForms.Guna2Panel();
      this.pnlFiltros.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dgvComunidades)).BeginInit();
      this.SuspendLayout();
      // 
      // lblHeaderTitle
      // 
      this.lblHeaderTitle.AutoSize = true;
      this.lblHeaderTitle.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold);
      this.lblHeaderTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblHeaderTitle.Location = new System.Drawing.Point(25, 20);
      this.lblHeaderTitle.Name = "lblHeaderTitle";
      this.lblHeaderTitle.Size = new System.Drawing.Size(324, 30);
      this.lblHeaderTitle.TabIndex = 0;
      this.lblHeaderTitle.Text = "Gerenciamento de Comunidades";
      // 
      // lblTotalRegistros
      // 
      this.lblTotalRegistros.AutoSize = true;
      this.lblTotalRegistros.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblTotalRegistros.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblTotalRegistros.Location = new System.Drawing.Point(27, 52);
      this.lblTotalRegistros.Name = "lblTotalRegistros";
      this.lblTotalRegistros.Size = new System.Drawing.Size(232, 17);
      this.lblTotalRegistros.TabIndex = 1;
      this.lblTotalRegistros.Text = "Carregando total de comunidades...";
      // 
      // pnlFiltros
      // 
      this.pnlFiltros.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.pnlFiltros.BackColor = System.Drawing.Color.Transparent;
      this.pnlFiltros.Controls.Add(this.btnRefresh);
      this.pnlFiltros.Controls.Add(this.btnExcluir);
      this.pnlFiltros.Controls.Add(this.btnMembros);
      this.pnlFiltros.Controls.Add(this.btnEditar);
      this.pnlFiltros.Controls.Add(this.btnNovo);
      this.pnlFiltros.Controls.Add(this.txtPesquisa);
      this.pnlFiltros.Location = new System.Drawing.Point(25, 80);
      this.pnlFiltros.Name = "pnlFiltros";
      this.pnlFiltros.Size = new System.Drawing.Size(990, 50);
      this.pnlFiltros.TabIndex = 2;
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
      this.txtPesquisa.Location = new System.Drawing.Point(0, 5);
      this.txtPesquisa.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
      this.txtPesquisa.Name = "txtPesquisa";
      this.txtPesquisa.PlaceholderText = " Buscar por nome, categoria ou criador...";
      this.txtPesquisa.SelectedText = "";
      this.txtPesquisa.Size = new System.Drawing.Size(350, 38);
      this.txtPesquisa.TabIndex = 0;
      this.txtPesquisa.TextChanged += new System.EventHandler(this.txtPesquisa_TextChanged);
      // 
      // btnNovo
      // 
      this.btnNovo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnNovo.BorderRadius = 8;
      this.btnNovo.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnNovo.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.btnNovo.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
      this.btnNovo.ForeColor = System.Drawing.Color.White;
      this.btnNovo.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(67)))), ((int)(((byte)(56)))), ((int)(((byte)(202)))));
      this.btnNovo.Location = new System.Drawing.Point(490, 5);
      this.btnNovo.Name = "btnNovo";
      this.btnNovo.Size = new System.Drawing.Size(140, 38);
      this.btnNovo.TabIndex = 1;
      this.btnNovo.Text = "+ Nova Comunidade";
      this.btnNovo.Click += new System.EventHandler(this.btnNovo_Click);
      // 
      // btnEditar
      // 
      this.btnEditar.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnEditar.BorderRadius = 8;
      this.btnEditar.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnEditar.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.btnEditar.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
      this.btnEditar.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.btnEditar.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.btnEditar.Location = new System.Drawing.Point(640, 5);
      this.btnEditar.Name = "btnEditar";
      this.btnEditar.Size = new System.Drawing.Size(95, 38);
      this.btnEditar.TabIndex = 2;
      this.btnEditar.Text = "âœ Editar";
      this.btnEditar.Click += new System.EventHandler(this.btnEditar_Click);
      // 
      // btnMembros
      // 
      this.btnMembros.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnMembros.BorderRadius = 8;
      this.btnMembros.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnMembros.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.btnMembros.Font = new System.Drawing.Font("Segoe UI", 8.5F, System.Drawing.FontStyle.Bold);
      this.btnMembros.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.btnMembros.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.btnMembros.Location = new System.Drawing.Point(745, 5);
      this.btnMembros.Name = "btnMembros";
      this.btnMembros.Size = new System.Drawing.Size(125, 38);
      this.btnMembros.TabIndex = 3;
      this.btnMembros.Text = " Ver Membros";
      this.btnMembros.Click += new System.EventHandler(this.btnMembros_Click);
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
      this.btnExcluir.Location = new System.Drawing.Point(880, 5);
      this.btnExcluir.Name = "btnExcluir";
      this.btnExcluir.Size = new System.Drawing.Size(70, 38);
      this.btnExcluir.TabIndex = 4;
      this.btnExcluir.Text = "";
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
      this.btnRefresh.Location = new System.Drawing.Point(955, 5);
      this.btnRefresh.Name = "btnRefresh";
      this.btnRefresh.Size = new System.Drawing.Size(35, 38);
      this.btnRefresh.TabIndex = 5;
      this.btnRefresh.Text = "";
      this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
      // 
      // dgvComunidades
      // 
      this.dgvComunidades.AllowUserToAddRows = false;
      this.dgvComunidades.AllowUserToDeleteRows = false;
      this.dgvComunidades.AllowUserToResizeRows = false;
      dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvComunidades.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
      this.dgvComunidades.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.dgvComunidades.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvComunidades.BackgroundColor = System.Drawing.Color.White;
      this.dgvComunidades.BorderStyle = System.Windows.Forms.BorderStyle.None;
      this.dgvComunidades.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvComunidades.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
      dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
      dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
      this.dgvComunidades.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
      this.dgvComunidades.ColumnHeadersHeight = 42;
      dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle3.BackColor = System.Drawing.Color.White;
      dataGridViewCellStyle3.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      dataGridViewCellStyle3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
      this.dgvComunidades.DefaultCellStyle = dataGridViewCellStyle3;
      this.dgvComunidades.EnableHeadersVisualStyles = false;
      this.dgvComunidades.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvComunidades.Location = new System.Drawing.Point(25, 140);
      this.dgvComunidades.MultiSelect = false;
      this.dgvComunidades.Name = "dgvComunidades";
      this.dgvComunidades.ReadOnly = true;
      this.dgvComunidades.RowHeadersVisible = false;
      this.dgvComunidades.RowTemplate.Height = 36;
      this.dgvComunidades.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
      this.dgvComunidades.Size = new System.Drawing.Size(990, 470);
      this.dgvComunidades.TabIndex = 3;
      this.dgvComunidades.ThemeStyle.AlternatingRowsStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvComunidades.ThemeStyle.BackColor = System.Drawing.Color.White;
      this.dgvComunidades.ThemeStyle.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvComunidades.ThemeStyle.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.dgvComunidades.ThemeStyle.HeaderStyle.BorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      this.dgvComunidades.ThemeStyle.HeaderStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      this.dgvComunidades.ThemeStyle.HeaderStyle.ForeColor = System.Drawing.Color.White;
      this.dgvComunidades.ThemeStyle.ReadOnly = true;
      this.dgvComunidades.ThemeStyle.RowsStyle.BackColor = System.Drawing.Color.White;
      this.dgvComunidades.ThemeStyle.RowsStyle.BorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvComunidades.ThemeStyle.RowsStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.dgvComunidades.ThemeStyle.RowsStyle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.dgvComunidades.ThemeStyle.RowsStyle.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.dgvComunidades.ThemeStyle.RowsStyle.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.dgvComunidades.DoubleClick += new System.EventHandler(this.btnEditar_Click);
      // 
      // FrmComunidades
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.ClientSize = new System.Drawing.Size(1040, 640);
      this.Controls.Add(this.dgvComunidades);
      this.Controls.Add(this.pnlFiltros);
      this.Controls.Add(this.lblTotalRegistros);
      this.Controls.Add(this.lblHeaderTitle);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
      this.Name = "FrmComunidades";
      this.Text = "Gerenciamento de Comunidades";
      this.Load += new System.EventHandler(this.FrmComunidades_Load);
      this.pnlFiltros.ResumeLayout(false);
      ((System.ComponentModel.ISupportInitialize)(this.dgvComunidades)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();
    }
  }
}
