import 'package:flutter/material.dart';

import '../../models/orcamento.dart';
import '../../models/ordem_servico.dart';
import '../../services/cliente_service.dart';
import '../../services/orcamento_service.dart';
import '../../services/ordem_servico_service.dart';
import 'orcamento_form.dart';

class OrcamentosPage extends StatefulWidget {
  const OrcamentosPage({super.key});

  @override
  State<OrcamentosPage> createState() => _OrcamentosPageState();
}

class _OrcamentosPageState extends State<OrcamentosPage> {
  Future<void> _abrirFormulario() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const OrcamentoForm(),
      ),
    );

    if (salvou == true && mounted) {
      setState(() {});
    }
  }

  void _alterarStatus(Orcamento orcamento, String novoStatus) {
    final indice = OrcamentoService.orcamentos.indexOf(orcamento);

    if (indice < 0) {
      return;
    }

    setState(() {
      OrcamentoService.orcamentos[indice] = orcamento.copyWith(
        status: novoStatus,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Orçamento marcado como $novoStatus.'),
      ),
    );
  }

  void _gerarOrdemServico(Orcamento orcamento) {
    if (orcamento.status.toLowerCase() != 'aprovado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O orçamento precisa estar aprovado para gerar uma OS.',
          ),
        ),
      );
      return;
    }

    if (orcamento.convertidoEmOs ||
        OrdemServicoService.existeOrdemDoOrcamento(orcamento.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este orçamento já foi convertido em Ordem de Serviço.',
          ),
        ),
      );
      return;
    }

    final clientesEncontrados = ClienteService.clientes.where(
      (cliente) => cliente.nome == orcamento.cliente,
    );

    if (clientesEncontrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O cliente deste orçamento não foi encontrado.',
          ),
        ),
      );
      return;
    }

    final cliente = clientesEncontrados.first;

    final novaOrdem = OrdemServico(
      id: OrdemServicoService.gerarId(),
      numero: OrdemServicoService.gerarNumero(),
      clienteId: cliente.id,
      clienteNome: cliente.nome,
      descricao: orcamento.descricao.isEmpty
          ? 'Serviço referente ao ${orcamento.numero}.'
          : orcamento.descricao,
      prioridade: 'Normal',
      status: 'Aberta',
      data: DateTime.now(),
      observacoes:
          'Ordem de Serviço gerada a partir do ${orcamento.numero}.',
      orcamentoId: orcamento.id,
    );

    OrdemServicoService.adicionar(novaOrdem);

    final indice = OrcamentoService.orcamentos.indexOf(orcamento);

    if (indice >= 0) {
      setState(() {
        OrcamentoService.orcamentos[indice] = orcamento.copyWith(
          convertidoEmOs: true,
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${novaOrdem.numero} criada com sucesso.',
        ),
      ),
    );
  }

  Future<void> _excluirOrcamento(Orcamento orcamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir orçamento'),
          content: Text(
            'Deseja realmente excluir o orçamento ${orcamento.numero}?',
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
      OrcamentoService.remover(orcamento);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orçamento excluído com sucesso.'),
      ),
    );
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return Colors.green;
      case 'reprovado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orcamentos = OrcamentoService.orcamentos;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Orçamentos'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Novo Orçamento'),
      ),
      body: orcamentos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.request_quote_outlined,
                      size: 80,
                      color: Color(0xFFE30613),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Nenhum orçamento cadastrado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Clique em “Novo Orçamento” para criar o primeiro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _abrirFormulario,
                      icon: const Icon(Icons.add),
                      label: const Text('Criar orçamento'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];

                return _OrcamentoCard(
                  orcamento: orcamento,
                  valorFormatado: _formatarValor(orcamento.valor),
                  dataFormatada: _formatarData(orcamento.data),
                  corStatus: _corStatus(orcamento.status),
                  onAprovar: () {
                    _alterarStatus(orcamento, 'Aprovado');
                  },
                  onReprovar: () {
                    _alterarStatus(orcamento, 'Reprovado');
                  },
                  onGerarOs: () {
                    _gerarOrdemServico(orcamento);
                  },
                  onExcluir: () {
                    _excluirOrcamento(orcamento);
                  },
                );
              },
            ),
    );
  }
}

class _OrcamentoCard extends StatelessWidget {
  final Orcamento orcamento;
  final String valorFormatado;
  final String dataFormatada;
  final Color corStatus;
  final VoidCallback onAprovar;
  final VoidCallback onReprovar;
  final VoidCallback onGerarOs;
  final VoidCallback onExcluir;

  const _OrcamentoCard({
    required this.orcamento,
    required this.valorFormatado,
    required this.dataFormatada,
    required this.corStatus,
    required this.onAprovar,
    required this.onReprovar,
    required this.onGerarOs,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final aprovado = orcamento.status.toLowerCase() == 'aprovado';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE30613),
              foregroundColor: Colors.white,
              child: Icon(Icons.request_quote),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orcamento.numero,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    orcamento.cliente,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (orcamento.descricao.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      orcamento.descricao,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(
                          Icons.attach_money,
                          size: 18,
                        ),
                        label: Text(valorFormatado),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                        label: Text(dataFormatada),
                      ),
                      Chip(
                        backgroundColor:
                            corStatus.withValues(alpha: 0.12),
                        label: Text(
                          orcamento.status,
                          style: TextStyle(
                            color: corStatus,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (orcamento.convertidoEmOs)
                        const Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          ),
                          label: Text('OS gerada'),
                        ),
                    ],
                  ),
                  if (aprovado && !orcamento.convertidoEmOs) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: onGerarOs,
                      icon: const Icon(Icons.assignment_add),
                      label: const Text('Gerar Ordem de Serviço'),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (opcao) {
                switch (opcao) {
                  case 'aprovar':
                    onAprovar();
                    break;
                  case 'reprovar':
                    onReprovar();
                    break;
                  case 'gerar_os':
                    onGerarOs();
                    break;
                  case 'excluir':
                    onExcluir();
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'aprovar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Text('Aprovar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reprovar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Reprovar'),
                      ],
                    ),
                  ),
                  if (aprovado && !orcamento.convertidoEmOs)
                    const PopupMenuItem(
                      value: 'gerar_os',
                      child: Row(
                        children: [
                          Icon(Icons.assignment_add),
                          SizedBox(width: 10),
                          Text('Gerar OS'),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
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