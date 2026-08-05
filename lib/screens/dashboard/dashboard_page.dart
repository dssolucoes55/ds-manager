import 'package:flutter/material.dart';

import '../clientes/clientes_page.dart';
import '../ordens_servico/ordens_servico_page.dart';
import '../orcamentos/orcamentos_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _paginaSelecionada = 0;

  final List<String> _titulos = const [
    'Dashboard',
    'Clientes',
    'Ordens de Serviço',
    'Orçamentos',
    'Laudos',
    'Financeiro',
    'Agenda',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool telaGrande = constraints.maxWidth >= 900;

        if (telaGrande) {
          return _layoutWeb();
        }

        return _layoutCelular();
      },
    );
  }

  Widget _layoutWeb() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Row(
        children: [
          _menuLateral(),
          Expanded(
            child: Column(
              children: [
                _cabecalho(),
                Expanded(
                  child: _conteudoSelecionado(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _layoutCelular() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(_titulos[_paginaSelecionada]),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: _menuLateral(contraido: true),
        ),
      ),
      body: _conteudoSelecionado(),
    );
  }

  Widget _menuLateral({bool contraido = false}) {
    return Container(
      width: contraido ? double.infinity : 260,
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              'assets/images/logo.png',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'DS SOLUÇÕES',
            style: TextStyle(
              color: Color.fromARGB(255, 5, 5, 5),
              fontSize: 21,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
          'Sistema de Gestão',
           style: TextStyle(
           color: Color(0xFF666666),
           fontSize: 21,
         ),
       ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _itemMenu(
                  indice: 0,
                  icon: Icons.dashboard_outlined,
                  titulo: 'Dashboard',
                ),
                _itemMenu(
                  indice: 1,
                  icon: Icons.people_outline,
                  titulo: 'Clientes',
                ),
                _itemMenu(
                  indice: 2,
                  icon: Icons.assignment_outlined,
                  titulo: 'Ordens de Serviço',
                ),
                _itemMenu(
                  indice: 3,
                  icon: Icons.request_quote_outlined,
                  titulo: 'Orçamentos',
                ),
                _itemMenu(
                  indice: 4,
                  icon: Icons.description_outlined,
                  titulo: 'Laudos',
                ),
                _itemMenu(
                  indice: 5,
                  icon: Icons.account_balance_wallet_outlined,
                  titulo: 'Financeiro',
                ),
                _itemMenu(
                  indice: 6,
                  icon: Icons.calendar_month_outlined,
                  titulo: 'Agenda',
                ),
                _itemMenu(
                  indice: 7,
                  icon: Icons.settings_outlined,
                  titulo: 'Configurações',
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Douglas',
                        style: const TextStyle(
                       color: Color(0xFF222222),
                       fontWeight: FontWeight.bold,
                    ),
                      ),
                      Text(
                        'Administrador',
                        style: TextStyle(
                          color:Color(0xFF666666),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemMenu({
    required int indice,
    required IconData icon,
    required String titulo,
  }) {
    final bool selecionado = _paginaSelecionada == indice;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selecionado
            ? const Color(0xFFE30613)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
         leading: Icon(
           icon,
           color: selecionado
               ? Colors.white
               : const Color(0xFF444444),
),
title: Text(
  titulo,
  style: TextStyle(
    color: selecionado
        ? Colors.white
        : const Color(0xFF444444),
    fontWeight: selecionado
        ? FontWeight.bold
        : FontWeight.w500,
  ),
),
          onTap: () {
            setState(() {
              _paginaSelecionada = indice;
            });

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _titulos[_paginaSelecionada],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notificações',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Color(0xFFE30613),
            foregroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget _conteudoSelecionado() {
    switch (_paginaSelecionada) {
      case 0:
        return _dashboard();

      case 1:
        return const ClientesPage();

      case 2:
        return const OrdensServicoPage();

      case 3:
  return const OrcamentosPage();

      case 4:
        return _paginaEmBreve(
          titulo: 'Laudos',
          icon: Icons.description_outlined,
        );

      case 5:
        return _paginaEmBreve(
          titulo: 'Financeiro',
          icon: Icons.account_balance_wallet_outlined,
        );

      case 6:
        return _paginaEmBreve(
          titulo: 'Agenda',
          icon: Icons.calendar_month_outlined,
        );

      case 7:
        return _paginaEmBreve(
          titulo: 'Configurações',
          icon: Icons.settings_outlined,
        );

      default:
        return _dashboard();
    }
  }

  Widget _dashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo, Douglas!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Acompanhe os principais indicadores da DS Soluções.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final int colunas = constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 700
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: colunas,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.3,
                children: [
                  _cardIndicador(
                    titulo: 'OS em aberto',
                    valor: '12',
                    icon: Icons.assignment_outlined,
                    cor: Colors.blue,
                    onTap: () {
                      setState(() {
                        _paginaSelecionada = 2;
                      });
                    },
                  ),
                  _cardIndicador(
                    titulo: 'Clientes',
                    valor: '152',
                    icon: Icons.people_outline,
                    cor: Colors.green,
                    onTap: () {
                      setState(() {
                        _paginaSelecionada = 1;
                      });
                    },
                  ),
                  _cardIndicador(
                    titulo: 'Orçamentos',
                    valor: '18',
                    icon: Icons.request_quote_outlined,
                    cor: Colors.orange,
                    onTap: () {
                      setState(() {
                        _paginaSelecionada = 3;
                      });
                    },
                  ),
                  _cardIndicador(
                    titulo: 'Laudos',
                    valor: '7',
                    icon: Icons.description_outlined,
                    cor: Colors.purple,
                    onTap: () {
                      setState(() {
                        _paginaSelecionada = 4;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Acessos rápidos',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _atalhoRapido(
                titulo: 'Novo cliente',
                icon: Icons.person_add_alt_1,
                onTap: () {
                  setState(() {
                    _paginaSelecionada = 1;
                  });
                },
              ),
              _atalhoRapido(
                titulo: 'Nova OS',
                icon: Icons.add_task,
                onTap: () {
                  setState(() {
                    _paginaSelecionada = 2;
                  });
                },
              ),
              _atalhoRapido(
                titulo: 'Novo orçamento',
                icon: Icons.post_add,
                onTap: () {
                  setState(() {
                    _paginaSelecionada = 3;
                  });
                },
              ),
              _atalhoRapido(
                titulo: 'Novo laudo',
                icon: Icons.note_add_outlined,
                onTap: () {
                  setState(() {
                    _paginaSelecionada = 4;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardIndicador({
    required String titulo,
    required String valor,
    required IconData icon,
    required Color cor,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: cor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _atalhoRapido({
    required String titulo,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 210,
      height: 78,
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  child: Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paginaEmBreve({
    required String titulo,
    required IconData icon,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 82,
            color: const Color(0xFFE30613),
          ),
          const SizedBox(height: 18),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Este módulo será desenvolvido em breve.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}