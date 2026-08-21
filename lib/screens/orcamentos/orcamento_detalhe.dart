import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../models/orcamento.dart';
import '../../services/orcamento_pdf_service.dart';

class OrcamentoDetalhe extends StatefulWidget {
  final Orcamento orcamento;

  const OrcamentoDetalhe({
    super.key,
    required this.orcamento,
  });

  @override
  State<OrcamentoDetalhe> createState() => _OrcamentoDetalheState();
}

class _OrcamentoDetalheState extends State<OrcamentoDetalhe> {
  bool _gerandoPdf = false;

  Orcamento get orcamento => widget.orcamento;

  String _moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _data(DateTime data) {
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

  Future<void> _baixarPdf() async {
    if (_gerandoPdf) return;

    setState(() => _gerandoPdf = true);

    try {
      final bytes = await OrcamentoPdfService.gerarOrcamento(orcamento);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${orcamento.numero}.pdf',
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao gerar PDF do orçamento: $erro'),
        ),
      );
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final corStatus = _corStatus(orcamento.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(orcamento.numero),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Baixar PDF',
            onPressed: _gerandoPdf ? null : _baixarPdf,
            icon: _gerandoPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Color(0xFFE30613),
                            foregroundColor: Colors.white,
                            child: Icon(Icons.request_quote, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orcamento.numero,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  orcamento.cliente,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            backgroundColor: corStatus.withValues(alpha: 0.12),
                            label: Text(
                              orcamento.status,
                              style: TextStyle(
                                color: corStatus,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _Informacao(
                            icon: Icons.calendar_today,
                            titulo: 'Data',
                            valor: _data(orcamento.data),
                          ),
                          _Informacao(
                            icon: Icons.business,
                            titulo: 'Cliente',
                            valor: orcamento.cliente,
                          ),
                          _Informacao(
                            icon: orcamento.convertidoEmOs
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            titulo: 'Ordem de Serviço',
                            valor: orcamento.convertidoEmOs
                                ? 'OS gerada'
                                : 'Ainda não gerada',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Secao(
                titulo: 'Descrição dos serviços',
                icon: Icons.description_outlined,
                child: Text(
                  orcamento.descricao.isEmpty
                      ? 'Nenhuma descrição informada.'
                      : orcamento.descricao,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              _Secao(
                titulo: 'Materiais',
                icon: Icons.inventory_2_outlined,
                child: orcamento.materiais.isEmpty
                    ? const Text('Nenhum material informado.')
                    : Column(
                        children: List.generate(
                          orcamento.materiais.length,
                          (index) {
                            final item = orcamento.materiais[index];
                            return _MaterialItem(
                              numero: index + 1,
                              item: item,
                              moeda: _moeda,
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _LinhaValor(
                        titulo: 'Subtotal dos materiais',
                        valor: _moeda(orcamento.subtotalMateriais),
                      ),
                      const SizedBox(height: 12),
                      _LinhaValor(
                        titulo: 'Mão de obra',
                        valor: _moeda(orcamento.valorMaoDeObra),
                      ),
                      const Divider(height: 30),
                      _LinhaValor(
                        titulo: 'VALOR TOTAL',
                        valor: _moeda(orcamento.valor),
                        destaque: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE30613),
                  ),
                  onPressed: _gerandoPdf ? null : _baixarPdf,
                  icon: _gerandoPdf
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    _gerandoPdf ? 'GERANDO PDF...' : 'BAIXAR PDF',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Widget child;

  const _Secao({
    required this.titulo,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFE30613)),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

class _Informacao extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const _Informacao({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(color: Colors.black54)),
            Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final int numero;
  final ItemMaterialOrcamento item;
  final String Function(double) moeda;

  const _MaterialItem({
    required this.numero,
    required this.item,
    required this.moeda,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFE30613),
            foregroundColor: Colors.white,
            child: Text('$numero'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.descricao,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantidade} × ${moeda(item.valorUnitario)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            moeda(item.valorTotal),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LinhaValor extends StatelessWidget {
  final String titulo;
  final String valor;
  final bool destaque;

  const _LinhaValor({
    required this.titulo,
    required this.valor,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: destaque ? 17 : 15,
            fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: destaque ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: destaque ? const Color(0xFFE30613) : null,
          ),
        ),
      ],
    );
  }
}
