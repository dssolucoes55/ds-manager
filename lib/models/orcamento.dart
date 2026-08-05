class Orcamento {
  final String id;
  final String numero;
  final String cliente;
  final DateTime data;
  final double valor;
  final String status;
  final String descricao;
  final bool convertidoEmOs;

  Orcamento({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.data,
    required this.valor,
    required this.status,
    this.descricao = '',
    this.convertidoEmOs = false,
  });

  Orcamento copyWith({
    String? id,
    String? numero,
    String? cliente,
    DateTime? data,
    double? valor,
    String? status,
    String? descricao,
    bool? convertidoEmOs,
  }) {
    return Orcamento(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      cliente: cliente ?? this.cliente,
      data: data ?? this.data,
      valor: valor ?? this.valor,
      status: status ?? this.status,
      descricao: descricao ?? this.descricao,
      convertidoEmOs: convertidoEmOs ?? this.convertidoEmOs,
    );
  }
}