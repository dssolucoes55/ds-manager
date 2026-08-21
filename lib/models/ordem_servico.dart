import 'dart:convert';
import 'dart:typed_data';

import 'orcamento.dart';

class HistoricoStatusOrdem {
  final String statusAnterior;
  final String novoStatus;
  final DateTime data;

  const HistoricoStatusOrdem({
    required this.statusAnterior,
    required this.novoStatus,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'statusAnterior': statusAnterior,
      'novoStatus': novoStatus,
      'data': data.millisecondsSinceEpoch,
    };
  }

  factory HistoricoStatusOrdem.fromMap(Map<String, dynamic> map) {
    return HistoricoStatusOrdem(
      statusAnterior: map['statusAnterior']?.toString() ?? '',
      novoStatus: map['novoStatus']?.toString() ?? '',
      data: OrdemServico.converterData(map['data']) ?? DateTime.now(),
    );
  }
}

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
  final DateTime? dataAgendamento;
  final List<HistoricoStatusOrdem> historicoStatus;

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
    this.dataAgendamento,
    this.historicoStatus = const [],
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
    DateTime? dataAgendamento,
    bool removerAgendamento = false,
    List<HistoricoStatusOrdem>? historicoStatus,
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
      dataAgendamento:
          removerAgendamento ? null : dataAgendamento ?? this.dataAgendamento,
      historicoStatus:
          historicoStatus ??
          List<HistoricoStatusOrdem>.from(this.historicoStatus),
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

  OrdemServico alterarStatus(String novoStatus) {
    if (status.toLowerCase() == novoStatus.toLowerCase()) {
      return this;
    }

    final novoHistorico =
        List<HistoricoStatusOrdem>.from(historicoStatus)
          ..add(
            HistoricoStatusOrdem(
              statusAnterior: status,
              novoStatus: novoStatus,
              data: DateTime.now(),
            ),
          );

    return copyWith(
      status: novoStatus,
      historicoStatus: novoHistorico,
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
      'dataAgendamento': dataAgendamento?.millisecondsSinceEpoch,
      'historicoStatus':
          historicoStatus.map((registro) => registro.toMap()).toList(),
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
    final materiais =
        materiaisMap is List
            ? materiaisMap
                .whereType<Map>()
                .map(
                  (item) => ItemMaterialOrcamento.fromMap(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
            : <ItemMaterialOrcamento>[];

    final historicoMap = map['historicoStatus'];
    final historico =
        historicoMap is List
            ? historicoMap
                .whereType<Map>()
                .map(
                  (item) => HistoricoStatusOrdem.fromMap(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
            : <HistoricoStatusOrdem>[];

    return OrdemServico(
      id: id,
      numero: map['numero']?.toString() ?? '',
      clienteId: map['clienteId']?.toString() ?? '',
      clienteNome: map['clienteNome']?.toString() ?? '',
      tecnico: map['tecnico']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      prioridade: map['prioridade']?.toString() ?? 'Normal',
      status: map['status']?.toString() ?? 'Aberta',
      data:
          converterData(map['data']) ??
          DateTime.now(),
      observacoes: map['observacoes']?.toString() ?? '',
      orcamentoId: map['orcamentoId']?.toString(),
      materiais: materiais,
      dataAgendamento: converterData(map['dataAgendamento']),
      historicoStatus: historico,
      fotosAntes: const [],
      fotosDepois: const [],
      nomeAssinanteTecnico:
          map['nomeAssinanteTecnico']?.toString() ?? '',
      nomeAssinanteCliente:
          map['nomeAssinanteCliente']?.toString() ?? '',
      assinaturaTecnico: _decodificarAssinatura(map['assinaturaTecnico']),
      assinaturaCliente: _decodificarAssinatura(map['assinaturaCliente']),
      dataConclusao: converterData(map['dataConclusao']),
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

  static DateTime? converterData(dynamic valor) {
    if (valor == null) return null;

    final milissegundos =
        valor is int ? valor : int.tryParse(valor.toString());

    if (milissegundos == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(milissegundos);
  }
}