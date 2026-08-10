import 'package:flutter/material.dart';

import '../../models/evento_agenda.dart';
import '../../services/agenda_service.dart';
import 'agenda_form.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() =>
      _AgendaPageState();
}

class _AgendaPageState
    extends State<AgendaPage> {
  Future<void> _novoEvento() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AgendaForm(),
      ),
    );
  }

  Future<void> _alterarStatus(
    EventoAgenda evento,
    String status,
  ) async {
    try {
      await AgendaService.atualizar(
        evento.copyWith(
          status: status,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao atualizar compromisso: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _excluir(
    EventoAgenda evento,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            'Excluir compromisso',
          ),
          content: Text(
            'Deseja realmente excluir "${evento.titulo}"?',
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
                backgroundColor:
                    Colors.red,
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
      await AgendaService.remover(
        evento,
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao excluir compromisso: $erro',
          ),
        ),
      );
    }
  }

  String _formatarDataHora(
    DateTime data,
  ) {
    final dia =
        data.day.toString().padLeft(2, '0');

    final mes =
        data.month.toString().padLeft(2, '0');

    final hora =
        data.hour.toString().padLeft(2, '0');

    final minuto =
        data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} - $hora:$minuto';
  }

  Color _corStatus(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'confirmado':
        return Colors.blue;

      case 'concluído':
      case 'concluido':
        return Colors.green;

      case 'cancelado':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  Color _corTipo(
    String tipo,
  ) {
    switch (tipo.toLowerCase()) {
      case 'serviço':
      case 'servico':
        return Colors.blue;

      case 'vistoria':
        return Colors.purple;

      case 'reunião':
      case 'reuniao':
        return Colors.teal;

      case 'retorno':
        return Colors.orange;

      default:
        return const Color(
          0xFFE30613,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title:
            const Text('Agenda'),
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor:
            Colors.white,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor:
            Colors.white,
        onPressed: _novoEvento,
        icon: const Icon(Icons.add),
        label:
            const Text(
          'Novo Compromisso',
        ),
      ),

      body: StreamBuilder<
          List<EventoAgenda>>(
        stream:
            AgendaService.observarEventos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar agenda:\n${snapshot.error}',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFFE30613),
              ),
            );
          }

          final eventos =
              snapshot.data ?? [];

          if (eventos.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    const Icon(
                      Icons
                          .calendar_month_outlined,
                      size: 80,
                      color:
                          Color(0xFFE30613),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    const Text(
                      'Nenhum compromisso agendado.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Cadastre uma visita, serviço ou reunião.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color:
                            Colors.black54,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    FilledButton.icon(
                      onPressed:
                          _novoEvento,
                      icon:
                          const Icon(
                        Icons.add,
                      ),
                      label:
                          const Text(
                        'Novo compromisso',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ),
            itemCount:
                eventos.length,
            itemBuilder:
                (context, index) {
              final evento =
                  eventos[index];

              final corStatus =
                  _corStatus(
                evento.status,
              );

              final corTipo =
                  _corTipo(
                evento.tipo,
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
                      BorderRadius
                          .circular(14),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            corTipo
                                .withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor:
                            corTipo,
                        child:
                            const Icon(
                          Icons.event,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              evento.titulo,
                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              evento
                                  .clienteNome,
                              style:
                                  const TextStyle(
                                color:
                                    Colors
                                        .black54,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              evento
                                  .descricao,
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
                                    _formatarDataHora(
                                      evento.data,
                                    ),
                                  ),
                                ),

                                Chip(
                                  label:
                                      Text(
                                    evento.tipo,
                                  ),
                                ),

                                Chip(
                                  backgroundColor:
                                      corStatus
                                          .withValues(
                                    alpha: 0.12,
                                  ),
                                  label:
                                      Text(
                                    evento.status,
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

                            if (evento
                                .observacoes
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                evento
                                    .observacoes,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors
                                          .black54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      PopupMenuButton<
                          String>(
                        onSelected:
                            (opcao) {
                          switch (opcao) {
                            case 'agendado':
                              _alterarStatus(
                                evento,
                                'Agendado',
                              );
                              break;

                            case 'confirmado':
                              _alterarStatus(
                                evento,
                                'Confirmado',
                              );
                              break;

                            case 'concluido':
                              _alterarStatus(
                                evento,
                                'Concluído',
                              );
                              break;

                            case 'cancelado':
                              _alterarStatus(
                                evento,
                                'Cancelado',
                              );
                              break;

                            case 'excluir':
                              _excluir(
                                evento,
                              );
                              break;
                          }
                        },
                        itemBuilder:
                            (context) {
                          return const [
                            PopupMenuItem(
                              value:
                                  'agendado',
                              child:
                                  Text(
                                'Agendado',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'confirmado',
                              child:
                                  Text(
                                'Confirmado',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'concluido',
                              child:
                                  Text(
                                'Concluído',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'cancelado',
                              child:
                                  Text(
                                'Cancelado',
                              ),
                            ),
                            PopupMenuDivider(),
                            PopupMenuItem(
                              value:
                                  'excluir',
                              child:
                                  Row(
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