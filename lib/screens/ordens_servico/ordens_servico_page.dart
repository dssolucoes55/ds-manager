import 'package:flutter/material.dart';

import '../../models/ordem_servico.dart';
import '../../services/ordem_servico_service.dart';
import 'ordem_servico_form.dart';

class OrdensServicoPage extends StatefulWidget {
  const OrdensServicoPage({super.key});

  @override
  State<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends State<OrdensServicoPage> {
  final TextEditingController _pesquisaController = TextEditingController();

  String _pesquisa = '';

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  List<OrdemServico> get _ordensFiltradas {
    final ordens = OrdemServicoService.ordens;

    if (_pesquisa.trim().isEmpty) {
      return ordens;
    }

    final texto = _pesquisa.toLowerCase();

    return ordens.where((ordem) {
      return ordem.numero.toLowerCase().contains(texto) ||
          ordem.clienteNome.toLowerCase().contains(texto) ||
          ordem.tecnico.toLowerCase().contains(texto) ||
          ordem.descricao.toLowerCase().contains(texto) ||
          ordem.status.toLowerCase().contains(texto);
    }).toList();
  }

  Future<void> _abrirFormulario() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const OrdemServicoForm(),
      ),
    );

    if (salvou == true && mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ordem de Serviço cadastrada com sucesso.'),
        ),
      );
    }
  }

  void _alterarStatus(OrdemServico ordem, String novoStatus) {
    final indice = OrdemServicoService.ordens.indexOf(ordem);

    if (indice < 0) {
      return;
    }

    final ordemAtualizada = ordem.copyWith(
      status: novoStatus,
    );

    setState(() {
      OrdemServicoService.atualizar(
        indice,
        ordemAtualizada,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status alterado para $novoStatus.',
        ),
      ),
    );
  }

  Future<void> _excluirOrdem(OrdemServico ordem) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Ordem de Serviço'),
          content: Text(
            'Deseja realmente excluir a ${ordem.numero}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    setState(() {
      OrdemServicoService.remover(ordem);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ordem de Serviço excluída com sucesso.'),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'em andamento':
        return Colors.orange;
      case 'concluída':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _corPrioridade(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'urgente':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordens = _ordensFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pesquisaController,
              onChanged: (valor) {
                setState(() {
                  _pesquisa = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar Ordem de Serviço',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _pesquisa.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: () {
                          _pesquisaController.clear();

                          setState(() {
                            _pesquisa = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ordens.isEmpty
                  ? _estadoVazio()
                  : ListView.builder(
                      itemCount: ordens.length,
                      itemBuilder: (context, index) {
                        final ordem = ordens[index];

                        return _OrdemServicoCard(
                          ordem: ordem,
                          dataFormatada: _formatarData(ordem.data),
                          corStatus: _corStatus(ordem.status),
                          corPrioridade: _corPrioridade(
                            ordem.prioridade,
                          ),
                          onAlterarStatus: (status) {
                            _alterarStatus(ordem, status);
                          },
                          onExcluir: () {
                            _excluirOrdem(ordem);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 82,
              color: Color(0xFFE30613),
            ),
            const SizedBox(height: 18),
            Text(
              _pesquisa.isEmpty
                  ? 'Nenhuma Ordem de Serviço cadastrada.'
                  : 'Nenhuma Ordem de Serviço encontrada.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_pesquisa.isEmpty)
              const Text(
                'Clique em “Nova OS” para cadastrar a primeira.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            if (_pesquisa.isEmpty) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.add),
                label: const Text('Criar Ordem de Serviço'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrdemServicoCard extends StatelessWidget {
  final OrdemServico ordem;
  final String dataFormatada;
  final Color corStatus;
  final Color corPrioridade;
  final ValueChanged<String> onAlterarStatus;
  final VoidCallback onExcluir;

  const _OrdemServicoCard({
    required this.ordem,
    required this.dataFormatada,
    required this.corStatus,
    required this.corPrioridade,
    required this.onAlterarStatus,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE30613),
              foregroundColor: Colors.white,
              child: Icon(Icons.assignment),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ordem.numero,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ordem.clienteNome,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ordem.descricao,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        backgroundColor: corStatus.withValues(
                          alpha: 0.12,
                        ),
                        label: Text(
                          ordem.status,
                          style: TextStyle(
                            color: corStatus,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor: corPrioridade.withValues(
                          alpha: 0.12,
                        ),
                        avatar: Icon(
                          Icons.priority_high,
                          size: 18,
                          color: corPrioridade,
                        ),
                        label: Text(
                          ordem.prioridade,
                          style: TextStyle(
                            color: corPrioridade,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                        label: Text(dataFormatada),
                      ),
                      if (ordem.tecnico.isNotEmpty)
                        Chip(
                          avatar: const Icon(
                            Icons.engineering,
                            size: 18,
                          ),
                          label: Text(ordem.tecnico),
                        ),
                    ],
                  ),
                  if (ordem.observacoes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Observações: ${ordem.observacoes}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (opcao) {
                switch (opcao) {
                  case 'aberta':
                    onAlterarStatus('Aberta');
                    break;
                  case 'andamento':
                    onAlterarStatus('Em andamento');
                    break;
                  case 'concluida':
                    onAlterarStatus('Concluída');
                    break;
                  case 'cancelada':
                    onAlterarStatus('Cancelada');
                    break;
                  case 'excluir':
                    onExcluir();
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'aberta',
                    child: Text('Marcar como aberta'),
                  ),
                  PopupMenuItem(
                    value: 'andamento',
                    child: Text('Marcar em andamento'),
                  ),
                  PopupMenuItem(
                    value: 'concluida',
                    child: Text('Marcar como concluída'),
                  ),
                  PopupMenuItem(
                    value: 'cancelada',
                    child: Text('Marcar como cancelada'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Excluir'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}