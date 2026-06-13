using System;
using System.Windows.Forms;
using RedeSocialEventosAdmin.Forms;

namespace RedeSocialEventosAdmin
{
    static class Program
    {
        /// <summary>
        /// Guarda de forma global na memória RAM da aplicação a identidade do usuário autenticado no banco.
        /// </summary>
        public static string EmailUsuarioLogado { get; set; }

        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Inicializa a esteira de execução chamando a janela moderna de login
            Application.Run(new FrmLogin());
        }
    }
}