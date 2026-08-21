import 'package:flutter/material.dart';

import '../../models/ordem_servico.dart';
import '../../services/agenda_service.dart';
import '../../services/ordem_servico_service.dart';
import 'ordem_servico_detalhe.dart';
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

  List<OrdemServico> _filtrarOrdens(List<OrdemServico> ordens) {
    if (_pesquisa.trim().isEmpty) {
      return ordens;
    }

    final texto = _pesquisa.toLowerCase();

    return ordens.where((ordem) {
      return ordem.numero.toLowerCase().contains(texto) ||
          ordem.clienteNome.toLowerCase().contains(texto) ||
          ordem.tecnico.toLowerCase().contains(texto) ||
          ordem.descricao.toLowerCase().contains(texto) ||
          ordem.status.toLowerCase().contains(texto) ||
          ordem.prioridade.toLowerCase().contains(texto);
    }).toList();
  }

  Future<void> _abrirFormulario([OrdemServico? ordem]) async {
    final editando = ordem != null;

    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OrdemServicoForm(ordem: ordem),
      ),
    );

    if (!mounted) return;

    if (salvou == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Ordem de Serviço atualizada com sucesso.'
                : 'Ordem de Serviço cadastrada com sucesso.',
          ),
        ),
      );
    }
  }

  Future<void> _abrirDetalhes(OrdemServico ordem) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdemServicoDetalhe(ordem: ordem),
      ),
    );
  }

  Future<void> _alterarStatus(
    OrdemServico ordem,
    String novoStatus,
  ) async {
    if (ordem.status.toLowerCase() == novoStatus.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A OS já está com o status $novoStatus.'),
        ),
      );
      return;
    }

    final ordemAtualizada = ordem.alterarStatus(novoStatus);

    try {
      await OrdemServicoService.atualizar(ordemAtualizada);
      await AgendaService.sincronizarOrdemServico(ordemAtualizada);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status alterado para $novoStatus.'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao alterar status: $erro'),
        ),
      );
    }
  }

  Future<void> _excluirOrdem(OrdemServico ordem) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Ordem de Serviço'),
          content: Text('Deseja realmente excluir a ${ordem.numero}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    try {
      await OrdemServicoService.remover(ordem);
      await AgendaService.removerPorOrdemServico(ordem.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ordem de Serviço excluída com sucesso.'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao excluir Ordem de Serviço: $erro'),
        ),
      );
    }
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
      case 'aguardando material':
        return Colors.deepPurple;
      case 'concluída':
      case 'concluida':
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
                setState(() => _pesquisa = valor);
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar Ordem de Serviço',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _pesquisa.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: () {
                          _pesquisaController.clear();
                          setState(() => _pesquisa = '');
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
              child: StreamBuilder<List<OrdemServico>>(
                stream: OrdemServicoService.observarOrdens(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar Ordens de Serviço:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE30613),
                      ),
                    );
                  }

                  final ordens = _filtrarOrdens(snapshot.data ?? []);

                  if (ordens.isEmpty) {
                    return _estadoVazio();
                  }

                  return ListView.builder(
                    itemCount: ordens.length,
                    itemBuilder: (context, index) {
                      final ordem = ordens[index];

                      return _OrdemServicoCard(
                        ordem: ordem,
                        dataFormatada: _formatarData(ordem.data),
                        corStatus: _corStatus(ordem.status),
                        corPrioridade: _corPrioridade(ordem.prioridade),
                        onTap: () => _abrirDetalhes(ordem),
                        onEditar: () => _abrirFormulario(ordem),
                        onAlterarStatus: (status) {
                          _alterarStatus(ordem, status);
                        },
                        onExcluir: () => _excluirOrdem(ordem),
                      );
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
                style: TextStyle(color: Colors.black54),
              ),
            if (_pesquisa.isEmpty) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                ),
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
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final ValueChanged<String> onAlterarStatus;
  final VoidCallback onExcluir;

  const _OrdemServicoCard({
    required this.ordem,
    required this.dataFormatada,
    required this.corStatus,
    required this.corPrioridade,
    required this.onTap,
    required this.onEditar,
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ordem.descricao,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          backgroundColor: corStatus.withValues(alpha: 0.12),
                          label: Text(
                            ordem.status,
                            style: TextStyle(
                              color: corStatus,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          backgroundColor:
                              corPrioridade.withValues(alpha: 0.12),
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
                          avatar: const Icon(Icons.calendar_today, size: 18),
                          label: Text(dataFormatada),
                        ),
                        if (ordem.tecnico.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.engineering, size: 18),
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
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 17,
                          color: Colors.black45,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Clique para visualizar os detalhes',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (opcao) {
                  switch (opcao) {
                    case 'editar':
                      onEditar();
                      break;
                    case 'aberta':
                      onAlterarStatus('Aberta');
                      break;
                    case 'andamento':
                      onAlterarStatus('Em andamento');
                      break;
                    case 'aguardando_material':
                      onAlterarStatus('Aguardando material');
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
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFE30613),
                          ),
                          SizedBox(width: 10),
                          Text('Editar OS'),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'aberta',
                      child: Text('Marcar como aberta'),
                    ),
                    PopupMenuItem(
                      value: 'andamento',
                      child: Text('Marcar em andamento'),
                    ),
                    PopupMenuItem(
                      value: 'aguardando_material',
                      child: Text('Aguardando material'),
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
                          Icon(Icons.delete_outline, color: Colors.red),
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
      ),
    );
  }
}
