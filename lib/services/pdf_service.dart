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

    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png'))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Row(
            children: [
              pw.Image(
                logo,
                width: 70,
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
                  pw.Text('Sistema de Gestão'),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          pw.Text(
            'ORDEM DE SERVIÇO',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.Divider(),

          pw.SizedBox(height: 15),

          _linha('Número', ordem.numero),
          _linha('Cliente', ordem.clienteNome),
          _linha('Data', _data(ordem.data)),
          _linha('Status', ordem.status),
          _linha('Prioridade', ordem.prioridade),
          _linha('Técnico', ordem.tecnico),

          pw.SizedBox(height: 25),

          _titulo('Descrição'),

          pw.Text(ordem.descricao),

          pw.SizedBox(height: 25),

          _titulo('Observações'),

          pw.Text(
            ordem.observacoes.isEmpty
                ? 'Nenhuma observação.'
                : ordem.observacoes,
          ),

          pw.SizedBox(height: 60),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Container(
                    width: 180,
                    child: pw.Divider(),
                  ),
                  pw.Text('Cliente'),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(
                    width: 180,
                    child: pw.Divider(),
                  ),
                  pw.Text('Responsável Técnico'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _titulo(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 16,
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
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
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

  static String _data(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}