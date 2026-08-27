import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final usernameController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  final UsuarioService _service = UsuarioService();

  DateTime? _dataNascimentoSelecionada;
  String _dataNascimentoIso = '';
  String erro = '';
  bool isLoading = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void dispose() {
    nomeController.dispose();
    usernameController.dispose();
    dataNascimentoController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  /// Abre o seletor de data moderno para celular
  Future<void> _selecionarDataNascimento() async {
    // Esconde teclado se aberto
    FocusScope.of(context).unfocus();

    final DateTime hoje = DateTime.now();
    final DateTime dataInicial = _dataNascimentoSelecionada ?? DateTime(2000, 1, 1);

    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: dataInicial.isAfter(hoje) ? hoje : dataInicial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: hoje,
      helpText: 'SELECIONE SUA DATA DE NASCIMENTO',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEA3F74), // Cor de destaque principal
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEA3F74),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataNascimentoSelecionada = dataEscolhida;

        // Formato amigável para exibição ao usuário (DD/MM/AAAA)
        final dia = dataEscolhida.day.toString().padLeft(2, '0');
        final mes = dataEscolhida.month.toString().padLeft(2, '0');
        final ano = dataEscolhida.year.toString();
        dataNascimentoController.text = '$dia/$mes/$ano';

        // Formato padrão ISO YYYY-MM-DD para envio à API
        _dataNascimentoIso = '$ano-$mes-$dia';
      });
    }
  }

  Future<void> _cadastrar() async {
    // Validação síncrona dos campos
    if (!_formKey.currentState!.validate()) return;

    if (_dataNascimentoIso.isEmpty) {
      setState(() {
        erro = 'Por favor, selecione sua data de nascimento.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      erro = '';
    });

    final nome = nomeController.text.trim();
    final username = usernameController.text.trim().replaceAll('@', '');
    final email = emailController.text.trim();
    final senha = senhaController.text;

    final result = await _service.criarUsuario(
      nome: nome,
      nomeCompleto: nome,
      username: username,
      email: email,
      senha: senha,
      dataNascimento: _dataNascimentoIso,
    );

    if (!mounted) return;

    if (result['sucesso'] == true) {
      final novoUsuario = result['usuario'] as Usuario?;
      final id = novoUsuario?.idUsuario ?? 1;
      final nomeFinal = novoUsuario?.nome.isNotEmpty == true ? novoUsuario!.nome : nome;
      final usernameFinal = (novoUsuario?.username != null && novoUsuario!.username!.isNotEmpty)
          ? novoUsuario.username!
          : username;
      final emailFinal = (novoUsuario?.email != null && novoUsuario!.email.isNotEmpty)
          ? novoUsuario.email
          : email;

      // Autentica o usuário na sessão mobile
      AuthService.fazerLogin(
        idUsuario: id,
        nome: nomeFinal,
        email: emailFinal,
        username: usernameFinal,
        bio: novoUsuario?.bio,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Bem-vindo(a) ao SocialJoin!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      // Redireciona para a HomeScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        erro = result['erro'] ?? 'Não foi possível concluir o cadastro. Verifique os dados.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
        ),
        title: const Text(
          'Criar Conta',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Minimalista e Moderno
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9ACC6), Color(0xFFEA3F74)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA3F74).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Junte-se ao SocialJoin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crie sua conta para participar de eventos e comunidades.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Campo: Nome Completo
                _buildField(
                  controller: nomeController,
                  label: 'Nome Completo',
                  hint: 'Ex: Ana Clara Silva',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe seu nome completo';
                    }
                    if (v.trim().length < 2) {
                      return 'O nome deve ter pelo menos 2 letras';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Nome de Usuário (@)
                _buildField(
                  controller: usernameController,
                  label: 'Nome de usuário (@)',
                  hint: 'Ex: anaclara',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe um nome de usuário';
                    }
                    final clean = v.trim().replaceAll('@', '');
                    if (clean.length < 3) {
                      return 'O usuário deve ter pelo menos 3 caracteres';
                    }
                    if (clean.contains(' ')) {
                      return 'O usuário não pode conter espaços';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Data de Nascimento (com DatePicker Nativo Mobile)
                _buildDateField(
                  controller: dataNascimentoController,
                  label: 'Data de nascimento',
                  hint: 'Toque para selecionar sua data',
                  icon: Icons.calendar_today_rounded,
                  onTap: _selecionarDataNascimento,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty || _dataNascimentoIso.isEmpty) {
                      return 'Selecione sua data de nascimento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: E-mail
                _buildField(
                  controller: emailController,
                  label: 'E-mail',
                  hint: 'seuemail@exemplo.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    final email = v.trim();
                    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegExp.hasMatch(email)) {
                      return 'Informe um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Senha
                _buildField(
                  controller: senhaController,
                  label: 'Senha',
                  hint: 'Mínimo de 6 caracteres',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  senhaVisivel: _senhaVisivel,
                  onToggleSenha: () => setState(() => _senhaVisivel = !_senhaVisivel),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Informe uma senha';
                    }
                    if (v.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Confirmar Senha
                _buildField(
                  controller: confirmarSenhaController,
                  label: 'Confirmar Senha',
                  hint: 'Repita sua senha',
                  icon: Icons.lock_clock_outlined,
                  isPassword: true,
                  senhaVisivel: _confirmarSenhaVisivel,
                  onToggleSenha: () => setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirme sua senha';
                    }
                    if (v != senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Banner de Feedback de Erro Amigável
                if (erro.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            erro,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Botão de Criação de Conta
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA3F74),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isLoading ? null : _cadastrar,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Criar Conta',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Link para Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta? ',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Color(0xFFEA3F74),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Campo de Texto Padronizado Minimalista
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool isPassword = false,
    bool? senhaVisivel,
    VoidCallback? onToggleSenha,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !(senhaVisivel ?? false),
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (senhaVisivel ?? false)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: onToggleSenha,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  /// Campo Especial para Data de Nascimento com Seletor
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEA3F74)),
            suffixIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFFEA3F74),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
