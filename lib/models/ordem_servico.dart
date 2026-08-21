import 'dart:convert';
import 'dart:typed_data';

import 'orcamento.dart';

class OrdemServico {
  final String id;
  final String numero;
  final String clienteId;
  final String clienteNome;
  final String tecnico;
  final String descricao;
  final String prioridade;
  final String status;
  final DateTime data;
  final String observacoes;
  final String? orcamentoId;
  final List<ItemMaterialOrcamento> materiais;

  final List<Uint8List> fotosAntes;
  final List<Uint8List> fotosDepois;

  final String nomeAssinanteTecnico;
  final String nomeAssinanteCliente;
  final Uint8List? assinaturaTecnico;
  final Uint8List? assinaturaCliente;
  final DateTime? dataConclusao;

  OrdemServico({
    required this.id,
    required this.numero,
    required this.clienteId,
    required this.clienteNome,
    this.tecnico = '',
    required this.descricao,
    this.prioridade = 'Normal',
    this.status = 'Aberta',
    required this.data,
    this.observacoes = '',
    this.orcamentoId,
    this.materiais = const [],
    this.fotosAntes = const [],
    this.fotosDepois = const [],
    this.nomeAssinanteTecnico = '',
    this.nomeAssinanteCliente = '',
    this.assinaturaTecnico,
    this.assinaturaCliente,
    this.dataConclusao,
  });

  OrdemServico copyWith({
    String? id,
    String? numero,
    String? clienteId,
    String? clienteNome,
    String? tecnico,
    String? descricao,
    String? prioridade,
    String? status,
    DateTime? data,
    String? observacoes,
    String? orcamentoId,
    List<ItemMaterialOrcamento>? materiais,
    List<Uint8List>? fotosAntes,
    List<Uint8List>? fotosDepois,
    String? nomeAssinanteTecnico,
    String? nomeAssinanteCliente,
    Uint8List? assinaturaTecnico,
    Uint8List? assinaturaCliente,
    DateTime? dataConclusao,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      tecnico: tecnico ?? this.tecnico,
      descricao: descricao ?? this.descricao,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      data: data ?? this.data,
      observacoes: observacoes ?? this.observacoes,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      materiais:
          materiais ?? List<ItemMaterialOrcamento>.from(this.materiais),
      fotosAntes: fotosAntes ?? List<Uint8List>.from(this.fotosAntes),
      fotosDepois: fotosDepois ?? List<Uint8List>.from(this.fotosDepois),
      nomeAssinanteTecnico:
          nomeAssinanteTecnico ?? this.nomeAssinanteTecnico,
      nomeAssinanteCliente:
          nomeAssinanteCliente ?? this.nomeAssinanteCliente,
      assinaturaTecnico: assinaturaTecnico ?? this.assinaturaTecnico,
      assinaturaCliente: assinaturaCliente ?? this.assinaturaCliente,
      dataConclusao: dataConclusao ?? this.dataConclusao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'tecnico': tecnico,
      'descricao': descricao,
      'prioridade': prioridade,
      'status': status,
      'data': data.millisecondsSinceEpoch,
      'observacoes': observacoes,
      'orcamentoId': orcamentoId,
      'materiais': materiais.map((item) => item.toMap()).toList(),
      'nomeAssinanteTecnico': nomeAssinanteTecnico,
      'nomeAssinanteCliente': nomeAssinanteCliente,
      'assinaturaTecnico':
          assinaturaTecnico == null ? null : base64Encode(assinaturaTecnico!),
      'assinaturaCliente':
          assinaturaCliente == null ? null : base64Encode(assinaturaCliente!),
      'dataConclusao': dataConclusao?.millisecondsSinceEpoch,
    };
  }

  factory OrdemServico.fromMap(String id, Map<String, dynamic> map) {
    final materiaisMap = map['materiais'];
    final materiais = materiaisMap is List
        ? materiaisMap
            .whereType<Map>()
            .map(
              (item) => ItemMaterialOrcamento.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <ItemMaterialOrcamento>[];

    return OrdemServico(
      id: id,
      numero: map['numero']?.toString() ?? '',
      clienteId: map['clienteId']?.toString() ?? '',
      clienteNome: map['clienteNome']?.toString() ?? '',
      tecnico: map['tecnico']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      prioridade: map['prioridade']?.toString() ?? 'Normal',
      status: map['status']?.toString() ?? 'Aberta',
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] is int
            ? map['data'] as int
            : int.tryParse(map['data']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch,
      ),
      observacoes: map['observacoes']?.toString() ?? '',
      orcamentoId: map['orcamentoId']?.toString(),
      materiais: materiais,
      fotosAntes: const [],
      fotosDepois: const [],
      nomeAssinanteTecnico:
          map['nomeAssinanteTecnico']?.toString() ?? '',
      nomeAssinanteCliente:
          map['nomeAssinanteCliente']?.toString() ?? '',
      assinaturaTecnico: _decodificarAssinatura(map['assinaturaTecnico']),
      assinaturaCliente: _decodificarAssinatura(map['assinaturaCliente']),
      dataConclusao: _converterData(map['dataConclusao']),
    );
  }

  static Uint8List? _decodificarAssinatura(dynamic valor) {
    if (valor == null || valor.toString().isEmpty) return null;
    try {
      return base64Decode(valor.toString());
    } catch (_) {
      return null;
    }
  }

  static DateTime? _converterData(dynamic valor) {
    if (valor == null) return null;
    final milissegundos =
        valor is int ? valor : int.tryParse(valor.toString());
    if (milissegundos == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(milissegundos);
  }
}
