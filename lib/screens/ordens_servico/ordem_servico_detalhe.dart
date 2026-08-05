import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../../models/ordem_servico.dart';
import '../../services/ordem_servico_service.dart';
import '../../services/pdf_service.dart';

class OrdemServicoDetalhe extends StatefulWidget {
  final OrdemServico ordem;

  const OrdemServicoDetalhe({
    super.key,
    required this.ordem,
  });

  @override
  State<OrdemServicoDetalhe> createState() => _OrdemServicoDetalheState();
}

class _OrdemServicoDetalheState extends State<OrdemServicoDetalhe> {
  late OrdemServico _ordem;
  bool _gerandoPdf = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ordem = widget.ordem;
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

  void _alterarStatus(String novoStatus) {
    final indice = OrdemServicoService.ordens.indexWhere(
      (ordem) => ordem.id == _ordem.id,
    );
    if (indice < 0) return;

    final ordemAtualizada = _ordem.copyWith(status: novoStatus);
    OrdemServicoService.atualizar(indice, ordemAtualizada);

    setState(() {
      _ordem = ordemAtualizada;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status alterado para $novoStatus.')),
    );
  }

  Future<void> _gerarPdf() async {
    if (_gerandoPdf) return;

    setState(() {
      _gerandoPdf = true;
    });

    try {
      final arquivo = await PdfService.gerarOrdemServico(_ordem);
      await Printing.layoutPdf(
        name: '${_ordem.numero}.pdf',
        onLayout: (_) async => arquivo,
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível gerar o PDF: $erro'),
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

  Future<void> _adicionarFoto({required bool antes}) async {
    try {
      final XFile? imagem = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (imagem == null) return;

      final Uint8List bytes = await imagem.readAsBytes();
      final fotosAntes = List<Uint8List>.from(_ordem.fotosAntes);
      final fotosDepois = List<Uint8List>.from(_ordem.fotosDepois);

      if (antes) {
        fotosAntes.add(bytes);
      } else {
        fotosDepois.add(bytes);
      }

      _atualizarFotos(
        fotosAntes: fotosAntes,
        fotosDepois: fotosDepois,
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível adicionar a foto: $erro'),
        ),
      );
    }
  }

  void _removerFoto({
    required bool antes,
    required int indiceFoto,
  }) {
    final fotosAntes = List<Uint8List>.from(_ordem.fotosAntes);
    final fotosDepois = List<Uint8List>.from(_ordem.fotosDepois);

    if (antes) {
      fotosAntes.removeAt(indiceFoto);
    } else {
      fotosDepois.removeAt(indiceFoto);
    }

    _atualizarFotos(
      fotosAntes: fotosAntes,
      fotosDepois: fotosDepois,
    );
  }

  void _atualizarFotos({
    required List<Uint8List> fotosAntes,
    required List<Uint8List> fotosDepois,
  }) {
    final indiceOrdem = OrdemServicoService.ordens.indexWhere(
      (ordem) => ordem.id == _ordem.id,
    );
    if (indiceOrdem < 0) return;

    final ordemAtualizada = _ordem.copyWith(
      fotosAntes: fotosAntes,
      fotosDepois: fotosDepois,
    );

    OrdemServicoService.atualizar(indiceOrdem, ordemAtualizada);

    setState(() {
      _ordem = ordemAtualizada;
    });
  }

  @override
  Widget build(BuildContext context) {
    final corStatus = _corStatus(_ordem.status);
    final corPrioridade = _corPrioridade(_ordem.prioridade);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_ordem.numero),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Gerar PDF',
            onPressed: _gerandoPdf ? null : _gerarPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          PopupMenuButton<String>(
            onSelected: _alterarStatus,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Aberta', child: Text('Marcar como aberta')),
              PopupMenuItem(
                value: 'Em andamento',
                child: Text('Marcar em andamento'),
              ),
              PopupMenuItem(
                value: 'Concluída',
                child: Text('Marcar como concluída'),
              ),
              PopupMenuItem(
                value: 'Cancelada',
                child: Text('Marcar como cancelada'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFFE30613),
                              foregroundColor: Colors.white,
                              child: Icon(Icons.assignment, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _ordem.numero,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _ordem.clienteNome,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Chip(
                              backgroundColor:
                                  corStatus.withValues(alpha: 0.12),
                              label: Text(
                                _ordem.status,
                                style: TextStyle(
                                  color: corStatus,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.priority_high,
                                size: 18,
                                color: corPrioridade,
                              ),
                              backgroundColor:
                                  corPrioridade.withValues(alpha: 0.12),
                              label: Text(
                                _ordem.prioridade,
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
                              label: Text(_formatarData(_ordem.data)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _secao(
                  titulo: 'Descrição do serviço',
                  icon: Icons.description_outlined,
                  conteudo: _ordem.descricao,
                ),
                const SizedBox(height: 18),
                _secao(
                  titulo: 'Técnico responsável',
                  icon: Icons.engineering_outlined,
                  conteudo:
                      _ordem.tecnico.isEmpty ? 'Não informado' : _ordem.tecnico,
                ),
                const SizedBox(height: 18),
                _secao(
                  titulo: 'Observações',
                  icon: Icons.notes_outlined,
                  conteudo: _ordem.observacoes.isEmpty
                      ? 'Nenhuma observação registrada.'
                      : _ordem.observacoes,
                ),
                const SizedBox(height: 18),
                _cardFotos(),
                if (_ordem.orcamentoId != null) ...[
                  const SizedBox(height: 18),
                  _secao(
                    titulo: 'Origem',
                    icon: Icons.request_quote_outlined,
                    conteudo:
                        'Ordem de Serviço gerada a partir de um orçamento.',
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE30613),
                      ),
                      onPressed: _gerandoPdf ? null : _gerarPdf,
                      icon: _gerandoPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(
                        _gerandoPdf ? 'Gerando PDF...' : 'Gerar PDF',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _alterarStatus('Em andamento'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar serviço'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => _alterarStatus('Concluída'),
                      icon: const Icon(Icons.check),
                      label: const Text('Concluir serviço'),
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

  Widget _cardFotos() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color: Color(0xFFE30613),
                ),
                SizedBox(width: 10),
                Text(
                  'Fotos do Serviço',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _adicionarFoto(antes: true),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Adicionar foto ANTES'),
            ),
            const SizedBox(height: 10),
            Text(
              '${_ordem.fotosAntes.length} foto(s)',
              style: const TextStyle(color: Colors.grey),
            ),
            _listaFotos(
              fotos: _ordem.fotosAntes,
              antes: true,
            ),
            const Divider(height: 35),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () => _adicionarFoto(antes: false),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Adicionar foto DEPOIS'),
            ),
            const SizedBox(height: 10),
            Text(
              '${_ordem.fotosDepois.length} foto(s)',
              style: const TextStyle(color: Colors.grey),
            ),
            _listaFotos(
              fotos: _ordem.fotosDepois,
              antes: false,
            ),
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
        padding: EdgeInsets.only(top: 10),
        child: Text(
          'Nenhuma foto adicionada.',
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          fotos.length,
          (index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        _removerFoto(
                          antes: antes,
                          indiceFoto: index,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.close,
                          size: 17,
                          color: Colors.white,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFFE30613),
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conteudo,
                    style: const TextStyle(
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
