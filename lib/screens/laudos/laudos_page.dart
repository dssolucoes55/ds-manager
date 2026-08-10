import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../models/laudo.dart';
import '../../services/laudo_service.dart';
import '../../services/laudo_pdf_service.dart';
import 'laudo_form.dart';

class LaudosPage extends StatefulWidget {
  const LaudosPage({super.key});

  @override
  State<LaudosPage> createState() => _LaudosPageState();
}

class _LaudosPageState extends State<LaudosPage> {
  Future<void> _novoLaudo() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const LaudoForm(),
      ),
    );
  }

  Future<void> _alterarStatus(
    Laudo laudo,
    String status,
  ) async {
    try {
      await LaudoService.atualizar(
        laudo.copyWith(
          status: status,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao alterar laudo: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _gerarPdf(
    Laudo laudo,
  ) async {
    try {
      final bytes =
          await LaudoPdfService.gerarLaudo(
        laudo,
      );

      await Printing.layoutPdf(
        name: '${laudo.numero}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao gerar PDF do laudo: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _excluir(
    Laudo laudo,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir laudo'),
          content: Text(
            'Deseja realmente excluir o ${laudo.numero}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Excluir'),
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
      await LaudoService.remover(laudo);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao excluir laudo: $erro',
          ),
        ),
      );
    }
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

  Color _corStatus(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'concluído':
      case 'concluido':
        return Colors.green;

      case 'entregue':
        return Colors.blue;

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
        title: const Text('Laudos'),
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor: Colors.white,
        onPressed: _novoLaudo,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Laudo',
        ),
      ),

      body: StreamBuilder<List<Laudo>>(
        stream:
            LaudoService.observarLaudos(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar laudos:\n${snapshot.error}',
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

          final laudos =
              snapshot.data ?? [];

          if (laudos.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: Color(0xFFE30613),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Nenhum laudo cadastrado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crie o primeiro laudo técnico.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _novoLaudo,
                      icon: const Icon(Icons.add),
                      label:
                          const Text('Novo laudo'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(20),
            itemCount: laudos.length,
            itemBuilder:
                (context, index) {
              final laudo =
                  laudos[index];

              final cor =
                  _corStatus(
                laudo.status,
              );

              return Card(
                elevation: 2,
                margin:
                    const EdgeInsets.only(
                  bottom: 14,
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
                      const CircleAvatar(
                        backgroundColor:
                            Color(0xFFE30613),
                        foregroundColor:
                            Colors.white,
                        child: Icon(
                          Icons.description,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              laudo.numero,
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
                              laudo.titulo,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              laudo.clienteNome,
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
                              laudo.descricao,
                              maxLines: 3,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  avatar:
                                      const Icon(
                                    Icons
                                        .calendar_today,
                                    size: 17,
                                  ),
                                  label: Text(
                                    _formatarData(
                                      laudo.data,
                                    ),
                                  ),
                                ),

                                Chip(
                                  backgroundColor:
                                      cor.withValues(
                                    alpha: 0.12,
                                  ),
                                  label: Text(
                                    laudo.status,
                                    style:
                                        TextStyle(
                                      color: cor,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),

                                if (laudo
                                    .art
                                    .isNotEmpty)
                                  Chip(
                                    avatar:
                                        const Icon(
                                      Icons
                                          .assignment_outlined,
                                      size: 17,
                                    ),
                                    label: Text(
                                      'ART ${laudo.art}',
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
                            case 'elaboracao':
                              _alterarStatus(
                                laudo,
                                'Em elaboração',
                              );
                              break;

                            case 'concluido':
                              _alterarStatus(
                                laudo,
                                'Concluído',
                              );
                              break;

                            case 'entregue':
                              _alterarStatus(
                                laudo,
                                'Entregue',
                              );
                              break;

                            case 'pdf':
                              _gerarPdf(
                                laudo,
                              );
                              break;

                            case 'excluir':
                              _excluir(laudo);
                              break;
                          }
                        },
                        itemBuilder:
                            (context) {
                          return const [
                            PopupMenuItem(
                              value:
                                  'elaboracao',
                              child: Text(
                                'Em elaboração',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'concluido',
                              child: Text(
                                'Concluído',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'entregue',
                              child: Text(
                                'Entregue',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'pdf',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: Color(0xFFE30613),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Gerar PDF',
                                  ),
                                ],
                              ),
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
                                  Text(
                                    'Excluir',
                                  ),
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
            },
          );
        },
      ),
    );
  }
}