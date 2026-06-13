using System;

namespace RedeSocialEventosAdmin.Models
{
    public class Usuario
    {
        public long IdUsuario { get; set; }
        public string Nome { get; set; }
        public string Email { get; set; }
        public string Senha { get; set; }
        public DateTime DataCriacao { get; set; }
    }
}