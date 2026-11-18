import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';

class PlanoPremiumPage extends StatefulWidget {
  const PlanoPremiumPage({super.key});

  @override
  State<PlanoPremiumPage> createState() => _PlanoPremiumPageState();
}

class _PlanoPremiumPageState extends State<PlanoPremiumPage> {
  final UsuarioService _usuarioService = UsuarioService();
  bool _carregando = false;
  String _metodoPagamento = 'cartao';

  Future<void> _assinar() async {
    setState(() => _carregando = true);
    final atualizado = await _usuarioService.assinarPremium();
    if (!mounted) return;
    setState(() => _carregando = false);

    if (atualizado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Parabéns! Você agora é um membro Premium do PI Social!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível ativar o Premium. Tente novamente.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _cancelar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text('Tem certeza que deseja cancelar sua assinatura Premium? Você voltará para o limite de 3 eventos e 3 comunidades.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _carregando = true);
    final atualizado = await _usuarioService.cancelarPremium();
    if (!mounted) return;
    setState(() => _carregando = false);

    if (atualizado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura Premium cancelada.'),
          backgroundColor: Color(0xFF6B7280),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível cancelar. Tente novamente.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = AuthService.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          isPremium ? 'Sua Assinatura' : 'Plano Premium',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF202124),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com gradiente dourado
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'VOCÊ É PREMIUM ⭐' : 'PLANO EXCLUSIVO',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFD97706),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPremium ? 'Membro Especial' : 'PI Social Premium',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPremium
                              ? 'Aproveite todos os benefícios ilimitados.'
                              : 'Destaque seus eventos e viva a experiência completa.',
                          style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF92400E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cartão de Preço
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ASSINATURA MENSAL',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'R\$',
                        style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFFB45309)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '19,90',
                        style: GoogleFonts.manrope(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF202124),
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        ' /mês',
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cancele a qualquer momento • Ativação imediata',
                    style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título de Benefícios
            Text(
              'O QUE ESTÁ INCLUSO',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Lista de Benefícios
            _beneficioItem(
              Icons.trending_up_rounded,
              'Prioridade Máxima',
              'Seus eventos e comunidades aparecem no topo das pesquisas e das recomendações de toda a plataforma.',
              const Color(0xFF10B981),
            ),
            _beneficioItem(
              Icons.all_inclusive_rounded,
              'Eventos e Comunidades Ilimitados',
              'Usuários gratuitos têm limite de 3. Com o Premium, crie quantos eventos e comunidades desejar!',
              const Color(0xFFEA3F74),
            ),
            _beneficioItem(
              Icons.verified_rounded,
              'Selo de Verificado Premium',
              'Selo dourado exclusivo no seu perfil e nas páginas dos seus eventos e comunidades.',
              const Color(0xFFF59E0B),
            ),
            _beneficioItem(
              Icons.block_rounded,
              'Zero Anúncios nos Cards',
              'Nenhum anúncio ou propaganda é exibido nos seus cards de eventos, mantendo tudo limpo.',
              const Color(0xFF6366F1),
            ),
            const SizedBox(height: 20),

            if (!isPremium) ...[
              // Método de Pagamento Simulado
              Text(
                'FORMA DE PAGAMENTO SIMULADA',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _opcaoPagamento(
                      'cartao',
                      'Cartão de Crédito',
                      Icons.credit_card_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _opcaoPagamento(
                      'pix',
                      'PIX Instantâneo',
                      Icons.qr_code_2_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Aviso de Demonstração Acadêmica
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ambiente acadêmico do Projeto Integrador. A assinatura é ativada instantaneamente sem cobrança real.',
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF1E40AF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão Principal
            if (!isPremium)
              FilledButton(
                onPressed: _carregando ? null : _assinar,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _carregando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Assinar Premium Agora',
                            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              )
            else
              OutlinedButton.icon(
                onPressed: _carregando ? null : _cancelar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(
                  _carregando ? 'Processando...' : 'Cancelar Assinatura Premium',
                  style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _beneficioItem(IconData icon, String titulo, String desc, Color cor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcaoPagamento(String id, String label, IconData icon) {
    final selecionado = _metodoPagamento == id;
    return GestureDetector(
      onTap: () => setState(() => _metodoPagamento = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFFFFFBEB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selecionado ? const Color(0xFFF59E0B) : const Color(0xFFE5E7EB),
            width: selecionado ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selecionado ? const Color(0xFFD97706) : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: selecionado ? FontWeight.w800 : FontWeight.w600,
                  color: selecionado ? const Color(0xFFB45309) : const Color(0xFF4B5563),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
