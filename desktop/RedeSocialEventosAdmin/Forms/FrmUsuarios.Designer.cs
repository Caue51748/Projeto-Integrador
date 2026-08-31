namespace RedeSocialEventosAdmin.Forms
{
  partial class FrmUsuarios
  {
    private System.ComponentModel.IContainer components = null;
    private Guna.UI2.WinForms.Guna2TextBox txtPesquisa;
    private Guna.UI2.WinForms.Guna2Button btnNovo;
    private Guna.UI2.WinForms.Guna2Button btnEditar;
    private Guna.UI2.WinForms.Guna2Button btnStatusToggle;
    private Guna.UI2.WinForms.Guna2Button btnExcluir;
    private Guna.UI2.WinForms.Guna2Button btnRefresh;
    private Guna.UI2.WinForms.Guna2ComboBox cmbFiltroRole;
    private Guna.UI2.WinForms.Guna2ComboBox cmbFiltroStatus;
    private Guna.UI2.WinForms.Guna2DataGridView dgvUsuarios;
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
      this.btnStatusToggle = new Guna.UI2.WinForms.Guna2Button();
      this.btnExcluir = new Guna.UI2.WinForms.Guna2Button();
      this.btnRefresh = new Guna.UI2.WinForms.Guna2Button();
      this.cmbFiltroRole = new Guna.UI2.WinForms.Guna2ComboBox();
      this.cmbFiltroStatus = new Guna.UI2.WinForms.Guna2ComboBox();
      this.dgvUsuarios = new Guna.UI2.WinForms.Guna2DataGridView();
      this.lblHeaderTitle = new System.Windows.Forms.Label();
      this.lblTotalRegistros = new System.Windows.Forms.Label();
      this.pnlFiltros = new Guna.UI2.WinForms.Guna2Panel();
      this.pnlFiltros.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dgvUsuarios)).BeginInit();
      this.SuspendLayout();
      // 
      // lblHeaderTitle
      // 
      this.lblHeaderTitle.AutoSize = true;
      this.lblHeaderTitle.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold);
      this.lblHeaderTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblHeaderTitle.Location = new System.Drawing.Point(25, 20);
      this.lblHeaderTitle.Name = "lblHeaderTitle";
      this.lblHeaderTitle.Size = new System.Drawing.Size(282, 30);
      this.lblHeaderTitle.TabIndex = 0;
      this.lblHeaderTitle.Text = "Usuários e Permissões";
      // 
      // lblTotalRegistros
      // 
      this.lblTotalRegistros.AutoSize = true;
      this.lblTotalRegistros.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblTotalRegistros.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblTotalRegistros.Location = new System.Drawing.Point(27, 52);
      this.lblTotalRegistros.Name = "lblTotalRegistros";
      this.lblTotalRegistros.Size = new System.Drawing.Size(193, 17);
      this.lblTotalRegistros.TabIndex = 1;
      this.lblTotalRegistros.Text = "Carregando total de contas...";
      // 
      // pnlFiltros
      // 
      this.pnlFiltros.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.pnlFiltros.BackColor = System.Drawing.Color.Transparent;
      this.pnlFiltros.Controls.Add(this.btnRefresh);
      this.pnlFiltros.Controls.Add(this.btnExcluir);
      this.pnlFiltros.Controls.Add(this.btnStatusToggle);
      this.pnlFiltros.Controls.Add(this.btnEditar);
      this.pnlFiltros.Controls.Add(this.btnNovo);
      this.pnlFiltros.Controls.Add(this.cmbFiltroStatus);
      this.pnlFiltros.Controls.Add(this.cmbFiltroRole);
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
      this.txtPesquisa.PlaceholderText = " Buscar por nome, email ou username...";
      this.txtPesquisa.SelectedText = "";
      this.txtPesquisa.Size = new System.Drawing.Size(260, 38);
      this.txtPesquisa.TabIndex = 0;
      this.txtPesquisa.TextChanged += new System.EventHandler(this.txtPesquisa_TextChanged);
      // 
      // cmbFiltroRole
      // 
      this.cmbFiltroRole.BackColor = System.Drawing.Color.Transparent;
      this.cmbFiltroRole.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.cmbFiltroRole.BorderRadius = 8;
      this.cmbFiltroRole.DrawMode = System.Windows.Forms.DrawMode.OwnerDrawFixed;
      this.cmbFiltroRole.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.cmbFiltroRole.FocusedColor = System.Drawing.Color.FromArgb(((int)(((byte)(99)))), ((int)(((byte)(102)))), ((int)(((byte)(241)))));
      this.cmbFiltroRole.FocusedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(99)))), ((int)(((byte)(102)))), ((int)(((byte)(241)))));
      this.cmbFiltroRole.Font = new System.Drawing.Font("Segoe UI", 9F);
      this.cmbFiltroRole.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.cmbFiltroRole.ItemHeight = 32;
      this.cmbFiltroRole.Items.AddRange(new object[] {
      "Role: TODAS",
      "admin",
      "moderator",
      "premium",
      "tester",
      "betatester",
      "user"});
      this.cmbFiltroRole.Location = new System.Drawing.Point(270, 5);
      this.cmbFiltroRole.Name = "cmbFiltroRole";
      this.cmbFiltroRole.Size = new System.Drawing.Size(130, 38);
      this.cmbFiltroRole.StartIndex = 0;
      this.cmbFiltroRole.TabIndex = 1;
      this.cmbFiltroRole.SelectedIndexChanged += new System.EventHandler(this.Filtros_Changed);
      // 
      // cmbFiltroStatus
      // 
      this.cmbFiltroStatus.BackColor = System.Drawing.Color.Transparent;
      this.cmbFiltroStatus.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.cmbFiltroStatus.BorderRadius = 8;
      this.cmbFiltroStatus.DrawMode = System.Windows.Forms.DrawMode.OwnerDrawFixed;
      this.cmbFiltroStatus.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.cmbFiltroStatus.FocusedColor = System.Drawing.Color.FromArgb(((int)(((byte)(99)))), ((int)(((byte)(102)))), ((int)(((byte)(241)))));
      this.cmbFiltroStatus.FocusedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(99)))), ((int)(((byte)(102)))), ((int)(((byte)(241)))));
      this.cmbFiltroStatus.Font = new System.Drawing.Font("Segoe UI", 9F);
      this.cmbFiltroStatus.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.cmbFiltroStatus.ItemHeight = 32;
      this.cmbFiltroStatus.Items.AddRange(new object[] {
      "Status: TODOS",
      "ativo",
      "suspenso",
      "inativo"});
      this.cmbFiltroStatus.Location = new System.Drawing.Point(410, 5);
      this.cmbFiltroStatus.Name = "cmbFiltroStatus";
      this.cmbFiltroStatus.Size = new System.Drawing.Size(130, 38);
      this.cmbFiltroStatus.StartIndex = 0;
      this.cmbFiltroStatus.TabIndex = 2;
      this.cmbFiltroStatus.SelectedIndexChanged += new System.EventHandler(this.Filtros_Changed);
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
      this.btnNovo.Location = new System.Drawing.Point(555, 5);
      this.btnNovo.Name = "btnNovo";
      this.btnNovo.Size = new System.Drawing.Size(100, 38);
      this.btnNovo.TabIndex = 3;
      this.btnNovo.Text = "+ Novo";
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
      this.btnEditar.Location = new System.Drawing.Point(665, 5);
      this.btnEditar.Name = "btnEditar";
      this.btnEditar.Size = new System.Drawing.Size(95, 38);
      this.btnEditar.TabIndex = 4;
      this.btnEditar.Text = "âœ Editar";
      this.btnEditar.Click += new System.EventHandler(this.btnEditar_Click);
      // 
      // btnStatusToggle
      // 
      this.btnStatusToggle.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnStatusToggle.BorderRadius = 8;
      this.btnStatusToggle.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnStatusToggle.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(254)))), ((int)(((byte)(243)))), ((int)(((byte)(199)))));
      this.btnStatusToggle.Font = new System.Drawing.Font("Segoe UI", 8.5F, System.Drawing.FontStyle.Bold);
      this.btnStatusToggle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(180)))), ((int)(((byte)(83)))), ((int)(((byte)(9)))));
      this.btnStatusToggle.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(253)))), ((int)(((byte)(230)))), ((int)(((byte)(138)))));
      this.btnStatusToggle.Location = new System.Drawing.Point(768, 5);
      this.btnStatusToggle.Name = "btnStatusToggle";
      this.btnStatusToggle.Size = new System.Drawing.Size(105, 38);
      this.btnStatusToggle.TabIndex = 5;
      this.btnStatusToggle.Text = " Suspender";
      this.btnStatusToggle.Click += new System.EventHandler(this.btnStatusToggle_Click);
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
      this.btnExcluir.TabIndex = 6;
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
      this.btnRefresh.TabIndex = 7;
      this.btnRefresh.Text = "";
      this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
      // 
      // dgvUsuarios
      // 
      this.dgvUsuarios.AllowUserToAddRows = false;
      this.dgvUsuarios.AllowUserToDeleteRows = false;
      this.dgvUsuarios.AllowUserToResizeRows = false;
      dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvUsuarios.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
      this.dgvUsuarios.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.dgvUsuarios.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvUsuarios.BackgroundColor = System.Drawing.Color.White;
      this.dgvUsuarios.BorderStyle = System.Windows.Forms.BorderStyle.None;
      this.dgvUsuarios.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvUsuarios.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
      dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
      dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
      this.dgvUsuarios.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
      this.dgvUsuarios.ColumnHeadersHeight = 42;
      dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle3.BackColor = System.Drawing.Color.White;
      dataGridViewCellStyle3.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      dataGridViewCellStyle3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
      this.dgvUsuarios.DefaultCellStyle = dataGridViewCellStyle3;
      this.dgvUsuarios.EnableHeadersVisualStyles = false;
      this.dgvUsuarios.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvUsuarios.Location = new System.Drawing.Point(25, 140);
      this.dgvUsuarios.MultiSelect = false;
      this.dgvUsuarios.Name = "dgvUsuarios";
      this.dgvUsuarios.ReadOnly = true;
      this.dgvUsuarios.RowHeadersVisible = false;
      this.dgvUsuarios.RowTemplate.Height = 36;
      this.dgvUsuarios.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
      this.dgvUsuarios.Size = new System.Drawing.Size(990, 470);
      this.dgvUsuarios.TabIndex = 3;
      this.dgvUsuarios.ThemeStyle.AlternatingRowsStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvUsuarios.ThemeStyle.BackColor = System.Drawing.Color.White;
      this.dgvUsuarios.ThemeStyle.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvUsuarios.ThemeStyle.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.dgvUsuarios.ThemeStyle.HeaderStyle.BorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      this.dgvUsuarios.ThemeStyle.HeaderStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      this.dgvUsuarios.ThemeStyle.HeaderStyle.ForeColor = System.Drawing.Color.White;
      this.dgvUsuarios.ThemeStyle.ReadOnly = true;
      this.dgvUsuarios.ThemeStyle.RowsStyle.BackColor = System.Drawing.Color.White;
      this.dgvUsuarios.ThemeStyle.RowsStyle.BorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvUsuarios.ThemeStyle.RowsStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.dgvUsuarios.ThemeStyle.RowsStyle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.dgvUsuarios.ThemeStyle.RowsStyle.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.dgvUsuarios.ThemeStyle.RowsStyle.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.dgvUsuarios.DoubleClick += new System.EventHandler(this.btnEditar_Click);
      // 
      // FrmUsuarios
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.ClientSize = new System.Drawing.Size(1040, 640);
      this.Controls.Add(this.dgvUsuarios);
      this.Controls.Add(this.pnlFiltros);
      this.Controls.Add(this.lblTotalRegistros);
      this.Controls.Add(this.lblHeaderTitle);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
      this.Name = "FrmUsuarios";
      this.Text = "Gerenciamento de Usuários";
      this.Load += new System.EventHandler(this.FrmUsuarios_Load);
      this.pnlFiltros.ResumeLayout(false);
      ((System.ComponentModel.ISupportInitialize)(this.dgvUsuarios)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();
    }
  }
}
