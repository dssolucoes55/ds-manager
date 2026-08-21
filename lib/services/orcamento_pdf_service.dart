import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/orcamento.dart';
import '../services/configuracao_service.dart';

class OrcamentoPdfService {
  static Future<Uint8List> gerarOrcamento(
    Orcamento orcamento,
  ) async {
    final configuracao =
        await ConfiguracaoService.carregar();

    final pdf = pw.Document();

    final logoBytes = await rootBundle.load(
      'assets/images/logo.png',
    );

    final logo = pw.MemoryImage(
      logoBytes.buffer.asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }

          return pw.Container(
            margin: const pw.EdgeInsets.only(
              bottom: 20,
            ),
            padding: const pw.EdgeInsets.only(
              bottom: 8,
            ),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey400,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  configuracao.nomeEmpresa,
                  style: pw.TextStyle(
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  orcamento.numero,
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              top: 20,
            ),
            padding: const pw.EdgeInsets.only(
              top: 8,
            ),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.grey400,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  configuracao.nomeEmpresa,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  'Página ${context.pageNumber} de ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },
        build: (context) => [
          pw.Row(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Image(
                logo,
                width: 90,
                height: 65,
                fit: pw.BoxFit.contain,
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      configuracao.nomeEmpresa,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    if (configuracao.cnpj.isNotEmpty)
                      _textoCabecalho(
                        'CNPJ: ${configuracao.cnpj}',
                      ),
                    if (configuracao.telefone.isNotEmpty)
                      _textoCabecalho(
                        'Telefone: ${configuracao.telefone}',
                      ),
                    if (configuracao.whatsapp.isNotEmpty)
                      _textoCabecalho(
                        'WhatsApp: ${configuracao.whatsapp}',
                      ),
                    if (configuracao.email.isNotEmpty)
                      _textoCabecalho(
                        configuracao.email,
                      ),
                    if (configuracao.endereco.isNotEmpty)
                      _textoCabecalho(
                        configuracao.endereco,
                      ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 28),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            decoration: const pw.BoxDecoration(
              color: PdfColors.red,
            ),
            child: pw.Text(
              'ORÇAMENTO',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.grey400,
              ),
              borderRadius:
                  pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                _linha(
                  'Número',
                  orcamento.numero,
                ),
                _linha(
                  'Cliente',
                  orcamento.cliente,
                ),
                _linha(
                  'Data',
                  _data(orcamento.data),
                ),
                _linha(
                  'Status',
                  orcamento.status,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          _titulo('Descrição dos serviços'),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius:
                  pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              orcamento.descricao.isEmpty
                  ? 'Descrição não informada.'
                  : orcamento.descricao,
              style: const pw.TextStyle(
                lineSpacing: 3,
              ),
            ),
          ),

          pw.SizedBox(height: 24),

          if (orcamento.materiais.isNotEmpty) ...[
            _titulo('Materiais'),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: const {
                0: pw.FlexColumnWidth(4),
                1: pw.FlexColumnWidth(1.2),
                2: pw.FlexColumnWidth(1.8),
                3: pw.FlexColumnWidth(1.8),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _celulaTabela('Descrição', negrito: true),
                    _celulaTabela('Qtd.', negrito: true, centralizado: true),
                    _celulaTabela('Unitário', negrito: true, centralizado: true),
                    _celulaTabela('Total', negrito: true, centralizado: true),
                  ],
                ),
                ...orcamento.materiais.map(
                  (item) => pw.TableRow(
                    children: [
                      _celulaTabela(item.descricao),
                      _celulaTabela(_quantidade(item.quantidade), centralizado: true),
                      _celulaTabela(_valor(item.valorUnitario), centralizado: true),
                      _celulaTabela(_valor(item.valorTotal), centralizado: true),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          _titulo('Valor do orçamento'),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.grey400,
              ),
              borderRadius:
                  pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              children: [
                _linhaValor(
                  'Subtotal dos materiais',
                  orcamento.subtotalMateriais,
                ),
                pw.SizedBox(height: 8),
                _linhaValor(
                  'Mão de obra',
                  orcamento.valorMaoDeObra,
                ),
                pw.Divider(height: 18, color: PdfColors.grey400),
                _linhaValor('VALOR TOTAL', orcamento.valor, destaque: true),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          _titulo('Condições gerais'),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius:
                  pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '- Os serviços serão executados conforme a descrição apresentada neste orçamento.',
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '- Alterações de escopo ou serviços adicionais deverão ser previamente aprovados.',
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '- Materiais e condições não descritos neste orçamento deverão ser acordados separadamente.',
                ),
              ],
            ),
          ),

          if (configuracao.responsavelTecnico.isNotEmpty ||
              configuracao.crea.isNotEmpty ||
              configuracao.artPadrao.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _titulo('Responsável Técnico'),
            pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                    pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                children: [
                  if (configuracao
                      .responsavelTecnico
                      .isNotEmpty)
                    _linha(
                      'Responsável',
                      configuracao
                          .responsavelTecnico,
                    ),
                  if (configuracao.crea.isNotEmpty)
                    _linha(
                      'CREA / Registro',
                      configuracao.crea,
                    ),
                  if (configuracao
                      .artPadrao
                      .isNotEmpty)
                    _linha(
                      'ART',
                      configuracao.artPadrao,
                    ),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 55),

          pw.Row(
            mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                pw.CrossAxisAlignment.end,
            children: [
              _assinatura(
                titulo:
                    'Cliente / Responsável',
              ),
              _assinatura(
                titulo: configuracao
                        .responsavelTecnico
                        .isEmpty
                    ? 'Responsável Técnico'
                    : configuracao
                        .responsavelTecnico,
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _textoCabecalho(
    String texto,
  ) {
    return pw.Text(
      texto,
      style: const pw.TextStyle(
        fontSize: 9,
        color: PdfColors.grey700,
      ),
    );
  }

  static pw.Widget _titulo(
    String texto,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(
        bottom: 6,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.red,
            width: 1.5,
          ),
        ),
      ),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _linha(
    String titulo,
    String valor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(
        bottom: 8,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              '$titulo:',
              style: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(valor),
          ),
        ],
      ),
    );
  }

  static pw.Widget _assinatura({
    required String titulo,
  }) {
    return pw.SizedBox(
      width: 210,
      child: pw.Column(
        children: [
          pw.Container(
            height: 1,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            titulo,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _celulaTabela(
    String texto, {
    bool negrito = false,
    bool centralizado = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        texto,
        textAlign: centralizado ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _linhaValor(
    String titulo,
    double valor, {
    bool destaque = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: destaque ? 14 : 11,
            fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          _valor(valor),
          style: pw.TextStyle(
            fontSize: destaque ? 18 : 11,
            fontWeight: pw.FontWeight.bold,
            color: destaque ? PdfColors.red : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static String _data(
    DateTime data,
  ) {
    final dia =
        data.day.toString().padLeft(2, '0');

    final mes =
        data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  static String _valor(
    double valor,
  ) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0];
    final centavos = partes[1];
    final formatado = inteiro.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return 'R\$ $formatado,$centavos';
  }

  static String _quantidade(double quantidade) {
    if (quantidade == quantidade.roundToDouble()) {
      return quantidade.toInt().toString();
    }
    return quantidade.toStringAsFixed(2).replaceAll('.', ',');
  }
}
