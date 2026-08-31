namespace RedeSocialEventosAdmin.Forms
{
  partial class FrmEventos
  {
    private System.ComponentModel.IContainer components = null;
    private Guna.UI2.WinForms.Guna2TextBox txtPesquisa;
    private Guna.UI2.WinForms.Guna2Button btnNovo;
    private Guna.UI2.WinForms.Guna2Button btnEditar;
    private Guna.UI2.WinForms.Guna2Button btnStatusToggle;
    private Guna.UI2.WinForms.Guna2Button btnParticipantes;
    private Guna.UI2.WinForms.Guna2Button btnExcluir;
    private Guna.UI2.WinForms.Guna2Button btnRefresh;
    private Guna.UI2.WinForms.Guna2ComboBox cmbFiltroStatus;
    private Guna.UI2.WinForms.Guna2DataGridView dgvEventos;
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
      this.btnParticipantes = new Guna.UI2.WinForms.Guna2Button();
      this.btnExcluir = new Guna.UI2.WinForms.Guna2Button();
      this.btnRefresh = new Guna.UI2.WinForms.Guna2Button();
      this.cmbFiltroStatus = new Guna.UI2.WinForms.Guna2ComboBox();
      this.dgvEventos = new Guna.UI2.WinForms.Guna2DataGridView();
      this.lblHeaderTitle = new System.Windows.Forms.Label();
      this.lblTotalRegistros = new System.Windows.Forms.Label();
      this.pnlFiltros = new Guna.UI2.WinForms.Guna2Panel();
      this.pnlFiltros.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dgvEventos)).BeginInit();
      this.SuspendLayout();
      // 
      // lblHeaderTitle
      // 
      this.lblHeaderTitle.AutoSize = true;
      this.lblHeaderTitle.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold);
      this.lblHeaderTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.lblHeaderTitle.Location = new System.Drawing.Point(25, 20);
      this.lblHeaderTitle.Name = "lblHeaderTitle";
      this.lblHeaderTitle.Size = new System.Drawing.Size(271, 30);
      this.lblHeaderTitle.TabIndex = 0;
      this.lblHeaderTitle.Text = "Gerenciamento de Eventos";
      // 
      // lblTotalRegistros
      // 
      this.lblTotalRegistros.AutoSize = true;
      this.lblTotalRegistros.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.lblTotalRegistros.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(116)))), ((int)(((byte)(139)))));
      this.lblTotalRegistros.Location = new System.Drawing.Point(27, 52);
      this.lblTotalRegistros.Name = "lblTotalRegistros";
      this.lblTotalRegistros.Size = new System.Drawing.Size(201, 17);
      this.lblTotalRegistros.TabIndex = 1;
      this.lblTotalRegistros.Text = "Carregando total de eventos...";
      // 
      // pnlFiltros
      // 
      this.pnlFiltros.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.pnlFiltros.BackColor = System.Drawing.Color.Transparent;
      this.pnlFiltros.Controls.Add(this.btnRefresh);
      this.pnlFiltros.Controls.Add(this.btnExcluir);
      this.pnlFiltros.Controls.Add(this.btnParticipantes);
      this.pnlFiltros.Controls.Add(this.btnStatusToggle);
      this.pnlFiltros.Controls.Add(this.btnEditar);
      this.pnlFiltros.Controls.Add(this.btnNovo);
      this.pnlFiltros.Controls.Add(this.cmbFiltroStatus);
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
      this.txtPesquisa.PlaceholderText = " Buscar por título, local ou categoria...";
      this.txtPesquisa.SelectedText = "";
      this.txtPesquisa.Size = new System.Drawing.Size(260, 38);
      this.txtPesquisa.TabIndex = 0;
      this.txtPesquisa.TextChanged += new System.EventHandler(this.txtPesquisa_TextChanged);
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
      "AGENDADO",
      "ACONTECENDO_AGORA",
      "ENCERRADO",
      "CANCELADO"});
      this.cmbFiltroStatus.Location = new System.Drawing.Point(270, 5);
      this.cmbFiltroStatus.Name = "cmbFiltroStatus";
      this.cmbFiltroStatus.Size = new System.Drawing.Size(160, 38);
      this.cmbFiltroStatus.StartIndex = 0;
      this.cmbFiltroStatus.TabIndex = 1;
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
      this.btnNovo.Location = new System.Drawing.Point(440, 5);
      this.btnNovo.Name = "btnNovo";
      this.btnNovo.Size = new System.Drawing.Size(105, 38);
      this.btnNovo.TabIndex = 2;
      this.btnNovo.Text = "+ Criar Evento";
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
      this.btnEditar.Location = new System.Drawing.Point(550, 5);
      this.btnEditar.Name = "btnEditar";
      this.btnEditar.Size = new System.Drawing.Size(85, 38);
      this.btnEditar.TabIndex = 3;
      this.btnEditar.Text = "âœ Editar";
      this.btnEditar.Click += new System.EventHandler(this.btnEditar_Click);
      // 
      // btnStatusToggle
      // 
      this.btnStatusToggle.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnStatusToggle.BorderRadius = 8;
      this.btnStatusToggle.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnStatusToggle.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.btnStatusToggle.Font = new System.Drawing.Font("Segoe UI", 8.5F, System.Drawing.FontStyle.Bold);
      this.btnStatusToggle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.btnStatusToggle.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(231)))), ((int)(((byte)(255)))));
      this.btnStatusToggle.Location = new System.Drawing.Point(640, 5);
      this.btnStatusToggle.Name = "btnStatusToggle";
      this.btnStatusToggle.Size = new System.Drawing.Size(115, 38);
      this.btnStatusToggle.TabIndex = 4;
      this.btnStatusToggle.Text = "âš¡ Mudar Status";
      this.btnStatusToggle.Click += new System.EventHandler(this.btnStatusToggle_Click);
      // 
      // btnParticipantes
      // 
      this.btnParticipantes.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
      this.btnParticipantes.BorderRadius = 8;
      this.btnParticipantes.Cursor = System.Windows.Forms.Cursors.Hand;
      this.btnParticipantes.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.btnParticipantes.Font = new System.Drawing.Font("Segoe UI", 8.5F, System.Drawing.FontStyle.Bold);
      this.btnParticipantes.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(51)))), ((int)(((byte)(65)))), ((int)(((byte)(85)))));
      this.btnParticipantes.HoverState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(232)))), ((int)(((byte)(240)))));
      this.btnParticipantes.Location = new System.Drawing.Point(760, 5);
      this.btnParticipantes.Name = "btnParticipantes";
      this.btnParticipantes.Size = new System.Drawing.Size(115, 38);
      this.btnParticipantes.TabIndex = 5;
      this.btnParticipantes.Text = " Ver Inscritos";
      this.btnParticipantes.Click += new System.EventHandler(this.btnParticipantes_Click);
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
      // dgvEventos
      // 
      this.dgvEventos.AllowUserToAddRows = false;
      this.dgvEventos.AllowUserToDeleteRows = false;
      this.dgvEventos.AllowUserToResizeRows = false;
      dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvEventos.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
      this.dgvEventos.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.dgvEventos.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvEventos.BackgroundColor = System.Drawing.Color.White;
      this.dgvEventos.BorderStyle = System.Windows.Forms.BorderStyle.None;
      this.dgvEventos.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvEventos.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
      dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
      dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
      this.dgvEventos.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
      this.dgvEventos.ColumnHeadersHeight = 42;
      dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
      dataGridViewCellStyle3.BackColor = System.Drawing.Color.White;
      dataGridViewCellStyle3.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      dataGridViewCellStyle3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
      this.dgvEventos.DefaultCellStyle = dataGridViewCellStyle3;
      this.dgvEventos.EnableHeadersVisualStyles = false;
      this.dgvEventos.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvEventos.Location = new System.Drawing.Point(25, 140);
      this.dgvEventos.MultiSelect = false;
      this.dgvEventos.Name = "dgvEventos";
      this.dgvEventos.ReadOnly = true;
      this.dgvEventos.RowHeadersVisible = false;
      this.dgvEventos.RowTemplate.Height = 36;
      this.dgvEventos.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
      this.dgvEventos.Size = new System.Drawing.Size(990, 470);
      this.dgvEventos.TabIndex = 3;
      this.dgvEventos.ThemeStyle.AlternatingRowsStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.dgvEventos.ThemeStyle.BackColor = System.Drawing.Color.White;
      this.dgvEventos.ThemeStyle.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(241)))), ((int)(((byte)(245)))), ((int)(((byte)(249)))));
      this.dgvEventos.ThemeStyle.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(15)))), ((int)(((byte)(23)))), ((int)(((byte)(42)))));
      this.dgvEventos.ThemeStyle.HeaderStyle.BorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
      this.dgvEventos.ThemeStyle.HeaderStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
      this.dgvEventos.ThemeStyle.HeaderStyle.ForeColor = System.Drawing.Color.White;
      this.dgvEventos.ThemeStyle.ReadOnly = true;
      this.dgvEventos.ThemeStyle.RowsStyle.BackColor = System.Drawing.Color.White;
      this.dgvEventos.ThemeStyle.RowsStyle.BorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
      this.dgvEventos.ThemeStyle.RowsStyle.Font = new System.Drawing.Font("Segoe UI", 9.5F);
      this.dgvEventos.ThemeStyle.RowsStyle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(41)))), ((int)(((byte)(59)))));
      this.dgvEventos.ThemeStyle.RowsStyle.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(238)))), ((int)(((byte)(242)))), ((int)(((byte)(255)))));
      this.dgvEventos.ThemeStyle.RowsStyle.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(70)))), ((int)(((byte)(229)))));
      this.dgvEventos.DoubleClick += new System.EventHandler(this.btnEditar_Click);
      // 
      // FrmEventos
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(250)))), ((int)(((byte)(252)))));
      this.ClientSize = new System.Drawing.Size(1040, 640);
      this.Controls.Add(this.dgvEventos);
      this.Controls.Add(this.pnlFiltros);
      this.Controls.Add(this.lblTotalRegistros);
      this.Controls.Add(this.lblHeaderTitle);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
      this.Name = "FrmEventos";
      this.Text = "Gerenciamento de Eventos";
      this.Load += new System.EventHandler(this.FrmEventos_Load);
      this.pnlFiltros.ResumeLayout(false);
      ((System.ComponentModel.ISupportInitialize)(this.dgvEventos)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();
    }
  }
}
