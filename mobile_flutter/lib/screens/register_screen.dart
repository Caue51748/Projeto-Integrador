import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final UsuarioService service = UsuarioService();
  String mensagem = '';
  bool isLoading = false;

  Future<void> cadastrar() async {
    setState(() => isLoading = true);
    
    Usuario usuario = Usuario(
      nome: nomeController.text,
      email: emailController.text,
      senha: senhaController.text,
    );

    await service.criarUsuario(usuario);

    setState(() {
      mensagem = 'Usuário cadastrado com sucesso!';
      isLoading = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Junte-se à comunidade',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Preencha seus dados abaixo para começar.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            _buildCustomTextField(controller: nomeController, label: 'Nome Completo', icon: Icons.person_outline),
            const SizedBox(height: 16),
            
            _buildCustomTextField(controller: emailController, label: 'Email', icon: Icons.email_outlined),
            const SizedBox(height: 16),
            
            _buildCustomTextField(controller: senhaController, label: 'Senha', icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 24),

            if (mensagem.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  mensagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA3F74),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ? null : cadastrar,
                child: isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Cadastrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
      ),
    );
  }
}