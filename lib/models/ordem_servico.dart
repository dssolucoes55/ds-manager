class OrdemServico {
  final String id;
  final String numero;
  final String clienteId;
  final String clienteNome;
  final String tecnico;
  final String descricao;
  final String prioridade;
  String status;
  final DateTime data;
  final String observacoes;
  final String? orcamentoId;

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
    );
  }
}