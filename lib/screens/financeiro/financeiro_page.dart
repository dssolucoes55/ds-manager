import 'package:flutter/material.dart';

import '../../models/lancamento_financeiro.dart';
import '../../services/financeiro_service.dart';
import 'financeiro_form.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() =>
      _FinanceiroPageState();
}

class _FinanceiroPageState
    extends State<FinanceiroPage> {
  Future<void> _novoLancamento() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const FinanceiroForm(),
      ),
    );
  }

  Future<void> _alterarStatus(
    LancamentoFinanceiro lancamento,
    String status,
  ) async {
    try {
      await FinanceiroService.atualizar(
        lancamento.copyWith(
          status: status,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao atualizar lançamento: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _excluir(
    LancamentoFinanceiro lancamento,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Excluir lançamento'),
          content: Text(
            'Deseja realmente excluir "${lancamento.descricao}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancelar'),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        confirmar != true) {
      return;
    }

    try {
      await FinanceiroService.remover(
        lancamento,
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao excluir lançamento: $erro',
          ),
        ),
      );
    }
  }

  String _formatarValor(
    double valor,
  ) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(
    DateTime data,
  ) {
    final dia =
        data.day.toString().padLeft(2, '0');

    final mes =
        data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Color _corTipo(
    String tipo,
  ) {
    if (tipo.toLowerCase() ==
        'receita') {
      return Colors.green;
    }

    return Colors.red;
  }

  Color _corStatus(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'pago':
      case 'recebido':
        return Colors.green;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title:
            const Text('Financeiro'),
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor: Colors.white,
        onPressed: _novoLancamento,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Lançamento',
        ),
      ),

      body: StreamBuilder<
          List<LancamentoFinanceiro>>(
        stream:
            FinanceiroService.observarLancamentos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar financeiro:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE30613),
              ),
            );
          }

          final lancamentos =
              snapshot.data ?? [];

          final receitas =
              FinanceiroService
                  .calcularTotalReceitas(
            lancamentos,
          );

          final despesas =
              FinanceiroService
                  .calcularTotalDespesas(
            lancamentos,
          );

          final saldo =
              FinanceiroService
                  .calcularSaldo(
            lancamentos,
          );

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder:
                      (context, constraints) {
                    final colunas =
                        constraints.maxWidth >= 900
                            ? 3
                            : constraints.maxWidth >= 600
                                ? 3
                                : 1;

                    return GridView.count(
                      crossAxisCount:
                          colunas,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          2.5,
                      children: [
                        _resumoCard(
                          titulo:
                              'Receitas',
                          valor:
                              _formatarValor(
                            receitas,
                          ),
                          icon:
                              Icons
                                  .arrow_upward,
                          cor:
                              Colors.green,
                        ),
                        _resumoCard(
                          titulo:
                              'Despesas',
                          valor:
                              _formatarValor(
                            despesas,
                          ),
                          icon:
                              Icons
                                  .arrow_downward,
                          cor:
                              Colors.red,
                        ),
                        _resumoCard(
                          titulo: 'Saldo',
                          valor:
                              _formatarValor(
                            saldo,
                          ),
                          icon:
                              Icons
                                  .account_balance_wallet_outlined,
                          cor: saldo >= 0
                              ? Colors.blue
                              : Colors.red,
                        ),
                      ],
                    );
                  },
                ),
              ),

              Expanded(
                child:
                    lancamentos.isEmpty
                        ? _estadoVazio()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              100,
                            ),
                            itemCount:
                                lancamentos.length,
                            itemBuilder:
                                (context, index) {
                              final item =
                                  lancamentos[
                                      index];

                              return _cardLancamento(
                                item,
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _resumoCard({
    required String titulo,
    required String valor,
    required IconData icon,
    required Color cor,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  cor.withValues(
                alpha: 0.12,
              ),
              foregroundColor: cor,
              child: Icon(icon),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    valor,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(
                    titulo,
                    style:
                        const TextStyle(
                      color:
                          Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardLancamento(
    LancamentoFinanceiro item,
  ) {
    final corTipo =
        _corTipo(item.tipo);

    final corStatus =
        _corStatus(item.status);

    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  corTipo.withValues(
                alpha: 0.12,
              ),
              foregroundColor:
                  corTipo,
              child: Icon(
                item.tipo
                            .toLowerCase() ==
                        'receita'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.descricao,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    item.categoria,
                    style:
                        const TextStyle(
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    _formatarValor(
                      item.valor,
                    ),
                    style:
                        TextStyle(
                      color: corTipo,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label:
                            Text(item.tipo),
                      ),
                      Chip(
                        avatar:
                            const Icon(
                          Icons
                              .calendar_today,
                          size: 17,
                        ),
                        label: Text(
                          _formatarData(
                            item.data,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor:
                            corStatus
                                .withValues(
                          alpha: 0.12,
                        ),
                        label: Text(
                          item.status,
                          style:
                              TextStyle(
                            color:
                                corStatus,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (item
                      .observacoes
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      item.observacoes,
                      style:
                          const TextStyle(
                        color:
                            Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (opcao) {
                switch (opcao) {
                  case 'pendente':
                    _alterarStatus(
                      item,
                      'Pendente',
                    );
                    break;

                  case 'pago':
                    _alterarStatus(
                      item,
                      'Pago',
                    );
                    break;

                  case 'recebido':
                    _alterarStatus(
                      item,
                      'Recebido',
                    );
                    break;

                  case 'excluir':
                    _excluir(item);
                    break;
                }
              },
              itemBuilder:
                  (context) {
                return const [
                  PopupMenuItem(
                    value: 'pendente',
                    child:
                        Text('Pendente'),
                  ),
                  PopupMenuItem(
                    value: 'pago',
                    child: Text('Pago'),
                  ),
                  PopupMenuItem(
                    value: 'recebido',
                    child:
                        Text('Recebido'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline,
                          color:
                              Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
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

  Widget _estadoVazio() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .account_balance_wallet_outlined,
              size: 80,
              color:
                  Color(0xFFE30613),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Nenhum lançamento financeiro.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Cadastre uma receita ou despesa.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.black54,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            FilledButton.icon(
              onPressed:
                  _novoLancamento,
              icon:
                  const Icon(Icons.add),
              label:
                  const Text(
                'Novo lançamento',
              ),
            ),
          ],
        ),
      ),
    );
  }
}