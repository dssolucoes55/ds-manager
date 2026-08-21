import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/ordem_servico.dart';
import '../services/configuracao_service.dart';

class PdfService {
  static Future<Uint8List> gerarOrdemServico(
    OrdemServico ordem,
  ) async {
    final configuracao = await ConfiguracaoService.carregar();
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
                  configuracao.nomeEmpresa,
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
                    configuracao.nomeEmpresa,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  if (configuracao.cnpj.isNotEmpty)
                    pw.Text(
                      'CNPJ: ${configuracao.cnpj}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  if (configuracao.telefone.isNotEmpty)
                    pw.Text(
                      'Telefone: ${configuracao.telefone}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  if (configuracao.email.isNotEmpty)
                    pw.Text(
                      configuracao.email,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  if (configuracao.endereco.isNotEmpty)
                    pw.Text(
                      configuracao.endereco,
                      style: const pw.TextStyle(
                        fontSize: 9,
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

          if (ordem.materiais.isNotEmpty) ...[
            _titulo('Materiais do serviço'),
            pw.SizedBox(height: 8),
            _tabelaMateriais(ordem),
            pw.SizedBox(height: 22),
          ],

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

          pw.SizedBox(height: 28),

          if (configuracao.responsavelTecnico.isNotEmpty ||
              configuracao.crea.isNotEmpty ||
              configuracao.artPadrao.isNotEmpty) ...[
            _titulo('Responsável Técnico'),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                children: [
                  if (configuracao.responsavelTecnico.isNotEmpty)
                    _linha(
                      'Responsável',
                      configuracao.responsavelTecnico,
                    ),
                  if (configuracao.crea.isNotEmpty)
                    _linha(
                      'CREA / Registro',
                      configuracao.crea,
                    ),
                  if (configuracao.artPadrao.isNotEmpty)
                    _linha(
                      'ART',
                      configuracao.artPadrao,
                    ),
                ],
              ),
            ),
          ],

          if (ordem.dataConclusao != null) ...[
            pw.SizedBox(height: 28),
            _titulo('Finalização do serviço'),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: _linha(
                'Concluído em',
                _dataHora(ordem.dataConclusao!),
              ),
            ),
          ],

          pw.SizedBox(height: 12),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _assinatura(
                titulo: 'Cliente / Responsável',
                nome: ordem.nomeAssinanteCliente,
                assinatura: ordem.assinaturaCliente,
              ),
              _assinatura(
                titulo: 'Técnico responsável',
                nome: ordem.nomeAssinanteTecnico.isEmpty
                    ? ordem.tecnico
                    : ordem.nomeAssinanteTecnico,
                assinatura: ordem.assinaturaTecnico,
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tabelaMateriais(OrdemServico ordem) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: const {
        0: pw.FlexColumnWidth(3.5),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _celulaMaterial('Material', cabecalho: true),
            _celulaMaterial('Qtd.', cabecalho: true),
            _celulaMaterial('Unitário', cabecalho: true),
            _celulaMaterial('Total', cabecalho: true),
          ],
        ),
        ...ordem.materiais.map(
          (material) => pw.TableRow(
            children: [
              _celulaMaterial(material.descricao),
              _celulaMaterial(_quantidade(material.quantidade)),
              _celulaMaterial(_moeda(material.valorUnitario)),
              _celulaMaterial(_moeda(material.valorTotal)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _celulaMaterial(
    String texto, {
    bool cabecalho = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: cabecalho ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _quantidade(double valor) {
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }
    return valor.toString().replaceAll('.', ',');
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
    required String nome,
    required Uint8List? assinatura,
  }) {
    return pw.SizedBox(
      width: 210,
      child: pw.Column(
        children: [
          pw.Container(
            height: 55,
            alignment: pw.Alignment.center,
            child: assinatura == null
                ? pw.SizedBox()
                : pw.Image(
                    pw.MemoryImage(assinatura),
                    height: 50,
                    width: 200,
                    fit: pw.BoxFit.contain,
                  ),
          ),
          pw.Container(
            height: 1,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            nome.isEmpty ? 'Nome não informado' : nome,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
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

  static String _dataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }
}
