import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/ordem_servico.dart';

class PdfService {
  static Future<Uint8List> gerarOrdemServico(
    OrdemServico ordem,
  ) async {
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
            margin: const pw.EdgeInsets.only(bottom: 20),
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey400,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DS SOLUÇÕES',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(ordem.numero),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 20),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.grey400,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DS Soluções — Sistema de Gestão',
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
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(
                logo,
                width: 90,
                height: 65,
                fit: pw.BoxFit.contain,
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DS SOLUÇÕES',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Sistema de Gestão',
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
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
              'ORDEM DE SERVIÇO',
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
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                _linha('Número', ordem.numero),
                _linha('Cliente', ordem.clienteNome),
                _linha('Data', _data(ordem.data)),
                _linha('Status', ordem.status),
                _linha('Prioridade', ordem.prioridade),
                _linha(
                  'Técnico',
                  ordem.tecnico.isEmpty
                      ? 'Não informado'
                      : ordem.tecnico,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          _titulo('Descrição do serviço'),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              ordem.descricao,
              style: const pw.TextStyle(
                lineSpacing: 3,
              ),
            ),
          ),

          pw.SizedBox(height: 22),

          _titulo('Observações'),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              ordem.observacoes.isEmpty
                  ? 'Nenhuma observação registrada.'
                  : ordem.observacoes,
              style: const pw.TextStyle(
                lineSpacing: 3,
              ),
            ),
          ),

          ..._secaoFotos(
            titulo: 'FOTOS ANTES DO SERVIÇO',
            fotos: ordem.fotosAntes,
          ),

          ..._secaoFotos(
            titulo: 'FOTOS DEPOIS DO SERVIÇO',
            fotos: ordem.fotosDepois,
          ),

          pw.SizedBox(height: 55),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _assinatura(
                titulo: 'Cliente / Responsável',
              ),
              _assinatura(
                titulo: 'Responsável Técnico',
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _secaoFotos({
    required String titulo,
    required List<Uint8List> fotos,
  }) {
    if (fotos.isEmpty) {
      return [];
    }

    return [
      pw.SizedBox(height: 28),
      _titulo(titulo),
      pw.SizedBox(height: 6),
      pw.Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          fotos.length,
          (index) {
            final imagem = pw.MemoryImage(fotos[index]);

            return pw.Container(
              width: 245,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey400,
                ),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 233,
                    height: 155,
                    color: PdfColors.grey200,
                    child: pw.Image(
                      imagem,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Foto ${index + 1}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  static pw.Widget _titulo(String texto) {
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
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 95,
            child: pw.Text(
              '$titulo:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
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

  static String _data(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }
}