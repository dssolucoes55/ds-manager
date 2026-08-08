import 'dart:typed_data';

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

  final List<Uint8List> fotosAntes;
  final List<Uint8List> fotosDepois;

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
    this.fotosAntes = const [],
    this.fotosDepois = const [],
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
    List<Uint8List>? fotosAntes,
    List<Uint8List>? fotosDepois,
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
      fotosAntes: fotosAntes ?? List<Uint8List>.from(this.fotosAntes),
      fotosDepois: fotosDepois ?? List<Uint8List>.from(this.fotosDepois),
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
    };
  }

  factory OrdemServico.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
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
      fotosAntes: const [],
      fotosDepois: const [],
    );
  }
}