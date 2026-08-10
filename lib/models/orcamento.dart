class Orcamento {
  final String id;
  final String numero;
  final String cliente;
  final DateTime data;
  final double valor;
  final String status;
  final String descricao;
  final bool convertidoEmOs;

  const Orcamento({
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

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'cliente': cliente,
      'data': data.millisecondsSinceEpoch,
      'valor': valor,
      'status': status,
      'descricao': descricao,
      'convertidoEmOs': convertidoEmOs,
    };
  }

  factory Orcamento.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Orcamento(
      id: id,
      numero: map['numero']?.toString() ?? '',
      cliente: map['cliente']?.toString() ?? '',
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] is int
            ? map['data'] as int
            : int.tryParse(
                  map['data']?.toString() ?? '',
                ) ??
                DateTime.now().millisecondsSinceEpoch,
      ),
      valor: map['valor'] is num
          ? (map['valor'] as num).toDouble()
          : double.tryParse(
                map['valor']?.toString() ?? '',
              ) ??
              0,
      status: map['status']?.toString() ?? 'Aguardando',
      descricao: map['descricao']?.toString() ?? '',
      convertidoEmOs:
          map['convertidoEmOs'] == true,
    );
  }
}