import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../../models/ordem_servico.dart';
import '../../services/agenda_service.dart';
import '../../services/ordem_servico_service.dart';
import '../../services/pdf_service.dart';
import 'finalizar_ordem_servico_dialog.dart';

class OrdemServicoDetalhe extends StatefulWidget {
  final OrdemServico ordem;

  const OrdemServicoDetalhe({
    super.key,
    required this.ordem,
  });

  @override
  State<OrdemServicoDetalhe> createState() =>
      _OrdemServicoDetalheState();
}

class _OrdemServicoDetalheState
    extends State<OrdemServicoDetalhe> {
  late OrdemServico _ordem;

  bool _gerandoPdf = false;
  bool _salvandoFotos = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ordem = widget.ordem;
  }

  String _formatarData(DateTime data) {
    final dia =
        data.day.toString().padLeft(2, '0');

    final mes =
        data.month.toString().padLeft(2, '0');

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

  Future<void> _alterarStatus(
    String novoStatus,
  ) async {
    if (_ordem.status.toLowerCase() == novoStatus.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A OS já está com o status $novoStatus.',
          ),
        ),
      );
      return;
    }

    final ordemAtualizada =
        _ordem.alterarStatus(novoStatus);

    try {
      await OrdemServicoService.atualizar(
        ordemAtualizada,
      );
      await AgendaService.sincronizarOrdemServico(
        ordemAtualizada,
      );

      if (!mounted) return;

      setState(() {
        _ordem = ordemAtualizada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status alterado para $novoStatus.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao alterar status: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _concluirServico() async {
    final ordemFinalizada =
        await showDialog<OrdemServico>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FinalizarOrdemServicoDialog(
          ordem: _ordem,
        );
      },
    );

    if (ordemFinalizada == null) {
      return;
    }

    final ordemComHistorico =
        _ordem.status.toLowerCase() ==
                ordemFinalizada.status.toLowerCase()
            ? ordemFinalizada
            : ordemFinalizada.copyWith(
                historicoStatus: _ordem
                    .alterarStatus(ordemFinalizada.status)
                    .historicoStatus,
              );

    try {
      await OrdemServicoService.atualizar(
        ordemComHistorico,
      );
      await AgendaService.sincronizarOrdemServico(
        ordemComHistorico,
      );

      if (!mounted) return;

      setState(() {
        _ordem = ordemComHistorico;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Serviço concluído e assinaturas salvas com sucesso.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao finalizar o serviço: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _gerarPdf() async {
    if (_gerandoPdf) return;

    setState(() {
      _gerandoPdf = true;
    });

    try {
      final arquivo =
          await PdfService.gerarOrdemServico(
        _ordem,
      );

      await Printing.sharePdf(
        bytes: arquivo,
        filename: '${_ordem.numero}.pdf',
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Não foi possível gerar o PDF: $erro',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _gerandoPdf = false;
        });
      }
    }
  }

  Future<void> _adicionarFoto({
    required bool antes,
  }) async {
    try {
      final XFile? imagem =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (imagem == null) {
        return;
      }

      final Uint8List bytes =
          await imagem.readAsBytes();

      final fotosAntes =
          List<Uint8List>.from(
        _ordem.fotosAntes,
      );

      final fotosDepois =
          List<Uint8List>.from(
        _ordem.fotosDepois,
      );

      if (antes) {
        fotosAntes.add(bytes);
      } else {
        fotosDepois.add(bytes);
      }

      await _atualizarFotos(
        fotosAntes: fotosAntes,
        fotosDepois: fotosDepois,
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Não foi possível adicionar a foto: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _removerFoto({
    required bool antes,
    required int indiceFoto,
  }) async {
    final fotosAntes =
        List<Uint8List>.from(
      _ordem.fotosAntes,
    );

    final fotosDepois =
        List<Uint8List>.from(
      _ordem.fotosDepois,
    );

    if (antes) {
      if (indiceFoto >= fotosAntes.length) {
        return;
      }

      fotosAntes.removeAt(
        indiceFoto,
      );
    } else {
      if (indiceFoto >= fotosDepois.length) {
        return;
      }

      fotosDepois.removeAt(
        indiceFoto,
      );
    }

    await _atualizarFotos(
      fotosAntes: fotosAntes,
      fotosDepois: fotosDepois,
    );
  }

  Future<void> _atualizarFotos({
    required List<Uint8List> fotosAntes,
    required List<Uint8List> fotosDepois,
  }) async {
    if (_salvandoFotos) {
      return;
    }

    setState(() {
      _salvandoFotos = true;
    });

    final ordemAtualizada =
        _ordem.copyWith(
      fotosAntes: fotosAntes,
      fotosDepois: fotosDepois,
    );

    try {
      /*
       * IMPORTANTE:
       *
       * O Firestore salva os dados da OS,
       * mas o método toMap() da OrdemServico
       * não envia as fotos para o Firestore.
       *
       * Por enquanto as fotos continuam
       * disponíveis nesta execução do sistema
       * e para gerar o PDF.
       *
       * Depois vamos salvá-las no
       * Firebase Storage.
       */

      await OrdemServicoService.atualizar(
        ordemAtualizada,
      );

      if (!mounted) return;

      setState(() {
        _ordem = ordemAtualizada;
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao atualizar fotos: $erro',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvandoFotos = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final corStatus =
        _corStatus(_ordem.status);

    final corPrioridade =
        _corPrioridade(
      _ordem.prioridade,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: Text(
          _ordem.numero,
        ),
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor:
            Colors.white,

        actions: [
          IconButton(
            tooltip: 'Baixar PDF',
            onPressed:
                _gerandoPdf
                    ? null
                    : _gerarPdf,
            icon: const Icon(
              Icons.picture_as_pdf,
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (status) {
              if (status == 'Concluída') {
                _concluirServico();
              } else {
                _alterarStatus(status);
              }
            },
            itemBuilder: (context) =>
                const [
              PopupMenuItem(
                value: 'Aberta',
                child: Text(
                  'Marcar como aberta',
                ),
              ),

              PopupMenuItem(
                value: 'Em andamento',
                child: Text(
                  'Marcar em andamento',
                ),
              ),

              PopupMenuItem(
                value: 'Aguardando material',
                child: Text(
                  'Aguardando material',
                ),
              ),

              PopupMenuItem(
                value: 'Concluída',
                child: Text(
                  'Marcar como concluída',
                ),
              ),

              PopupMenuItem(
                value: 'Cancelada',
                child: Text(
                  'Marcar como cancelada',
                ),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 900,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Card(
                  elevation: 2,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Color(
                                0xFFE30613,
                              ),
                              foregroundColor:
                                  Colors.white,
                              child: Icon(
                                Icons.assignment,
                                size: 30,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    _ordem.numero,
                                    style:
                                        const TextStyle(
                                      fontSize: 24,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    _ordem
                                        .clienteNome,
                                    style:
                                        const TextStyle(
                                      fontSize: 18,
                                      color: Colors
                                          .black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,

                          children: [
                            Chip(
                              backgroundColor:
                                  corStatus
                                      .withValues(
                                alpha: 0.12,
                              ),

                              label: Text(
                                _ordem.status,
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

                            Chip(
                              avatar: Icon(
                                Icons
                                    .priority_high,
                                size: 18,
                                color:
                                    corPrioridade,
                              ),

                              backgroundColor:
                                  corPrioridade
                                      .withValues(
                                alpha: 0.12,
                              ),

                              label: Text(
                                _ordem
                                    .prioridade,
                                style:
                                    TextStyle(
                                  color:
                                      corPrioridade,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            Chip(
                              avatar:
                                  const Icon(
                                Icons
                                    .calendar_today,
                                size: 18,
                              ),

                              label: Text(
                                _formatarData(
                                  _ordem.data,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                _secao(
                  titulo:
                      'Descrição do serviço',
                  icon: Icons
                      .description_outlined,
                  conteudo:
                      _ordem.descricao,
                ),

                const SizedBox(
                  height: 18,
                ),

                _secao(
                  titulo:
                      'Técnico responsável',
                  icon: Icons
                      .engineering_outlined,
                  conteudo:
                      _ordem.tecnico.isEmpty
                          ? 'Não informado'
                          : _ordem
                              .tecnico,
                ),

                const SizedBox(
                  height: 18,
                ),

                _secao(
                  titulo: 'Observações',
                  icon:
                      Icons.notes_outlined,
                  conteudo:
                      _ordem.observacoes
                              .isEmpty
                          ? 'Nenhuma observação registrada.'
                          : _ordem
                              .observacoes,
                ),

                const SizedBox(
                  height: 18,
                ),

                _secao(
                  titulo: 'Agendamento',
                  icon: Icons.calendar_month_outlined,
                  conteudo: _ordem.dataAgendamento == null
                      ? 'Não agendado'
                      : _formatarDataHora(_ordem.dataAgendamento!),
                ),

                const SizedBox(height: 18),

                _cardHistoricoStatus(),

                const SizedBox(height: 18),

                _cardMateriais(),

                const SizedBox(
                  height: 18,
                ),

                _cardFotos(),

                if (_ordem.orcamentoId !=
                    null) ...[
                  const SizedBox(
                    height: 18,
                  ),

                  _secao(
                    titulo: 'Origem',
                    icon: Icons
                        .request_quote_outlined,
                    conteudo:
                        'Ordem de Serviço gerada a partir de um orçamento.',
                  ),
                ],

                const SizedBox(
                  height: 24,
                ),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,

                  children: [
                    FilledButton.icon(
                      style:
                          FilledButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFE30613,
                        ),
                      ),

                      onPressed:
                          _gerandoPdf
                              ? null
                              : _gerarPdf,

                      icon: _gerandoPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color: Colors
                                    .white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .picture_as_pdf,
                            ),

                      label: Text(
                        _gerandoPdf
                            ? 'Gerando PDF...'
                            : 'Baixar PDF',
                      ),
                    ),

                    FilledButton.icon(
                      onPressed: () {
                        _alterarStatus(
                          'Em andamento',
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      label: const Text(
                        'Iniciar serviço',
                      ),
                    ),

                    FilledButton.icon(
                      style:
                          FilledButton
                              .styleFrom(
                        backgroundColor:
                            Colors.green,
                      ),
                      onPressed:
                          _concluirServico,
                      icon: const Icon(
                        Icons.check,
                      ),
                      label: const Text(
                        'Concluir serviço',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  Widget _cardHistoricoStatus() {
    final historico = _ordem.historicoStatus.reversed.toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history,
                  color: Color(0xFFE30613),
                ),
                SizedBox(width: 10),
                Text(
                  'Histórico de status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (historico.isEmpty)
              const Text(
                'Nenhuma alteração de status registrada.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...List.generate(historico.length, (indice) {
                final registro = historico[indice];
                final cor = _corStatus(registro.novoStatus);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: indice == historico.length - 1 ? 0 : 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${registro.statusAnterior} → '
                              '${registro.novoStatus}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatarDataHora(registro.data),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _cardMateriais() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFE30613),
                ),
                SizedBox(width: 10),
                Text(
                  'Materiais do serviço',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            if (_ordem.materiais.isEmpty)
              const Text(
                'Nenhum material informado para esta Ordem de Serviço.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...List.generate(_ordem.materiais.length, (index) {
                final material = _ordem.materiais[index];
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
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.descricao,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${material.quantidade} × '
                              '${_formatarMoeda(material.valorUnitario)}',
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatarMoeda(material.valorTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _cardFotos() {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color:
                      Color(0xFFE30613),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Fotos do Serviço',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              onPressed:
                  _salvandoFotos
                      ? null
                      : () {
                          _adicionarFoto(
                            antes: true,
                          );
                        },
              icon: const Icon(
                Icons.add_a_photo,
              ),
              label: const Text(
                'Adicionar foto ANTES',
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              '${_ordem.fotosAntes.length} foto(s)',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            _listaFotos(
              fotos:
                  _ordem.fotosAntes,
              antes: true,
            ),

            const Divider(
              height: 35,
            ),

            FilledButton.icon(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.green,
              ),

              onPressed:
                  _salvandoFotos
                      ? null
                      : () {
                          _adicionarFoto(
                            antes: false,
                          );
                        },

              icon: const Icon(
                Icons.add_a_photo,
              ),

              label: const Text(
                'Adicionar foto DEPOIS',
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              '${_ordem.fotosDepois.length} foto(s)',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            _listaFotos(
              fotos:
                  _ordem.fotosDepois,
              antes: false,
            ),

            if (_salvandoFotos) ...[
              const SizedBox(
                height: 18,
              ),
              const LinearProgressIndicator(
                color:
                    Color(0xFFE30613),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _listaFotos({
    required List<Uint8List> fotos,
    required bool antes,
  }) {
    if (fotos.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.only(
          top: 10,
        ),
        child: Text(
          'Nenhuma foto adicionada.',
          style: TextStyle(
            color: Colors.black45,
          ),
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        top: 12,
      ),

      child: Wrap(
        spacing: 10,
        runSpacing: 10,

        children: List.generate(
          fotos.length,
          (index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius
                          .circular(10),

                  child: Image.memory(
                    fotos[index],
                    width: 130,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 4,
                  right: 4,

                  child: Material(
                    color:
                        Colors.black54,
                    shape:
                        const CircleBorder(),

                    child: InkWell(
                      customBorder:
                          const CircleBorder(),

                      onTap:
                          _salvandoFotos
                              ? null
                              : () {
                                  _removerFoto(
                                    antes:
                                        antes,
                                    indiceFoto:
                                        index,
                                  );
                                },

                      child:
                          const Padding(
                        padding:
                            EdgeInsets.all(
                          5,
                        ),

                        child: Icon(
                          Icons.close,
                          size: 17,
                          color:
                              Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _secao({
    required String titulo,
    required IconData icon,
    required String conteudo,
  }) {
    return Card(
      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              color:
                  const Color(
                0xFFE30613,
              ),
              size: 28,
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
                    titulo,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    conteudo,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      height: 1.4,
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
}
