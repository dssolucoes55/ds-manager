class LancamentoFinanceiro {
  final String id;
  final String tipo;
  final String descricao;
  final String categoria;
  final double valor;
  final String status;
  final DateTime data;
  final String observacoes;

  const LancamentoFinanceiro({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.status,
    required this.data,
    this.observacoes = '',
  });

  LancamentoFinanceiro copyWith({
    String? id,
    String? tipo,
    String? descricao,
    String? categoria,
    double? valor,
    String? status,
    DateTime? data,
    String? observacoes,
  }) {
    return LancamentoFinanceiro(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      status: status ?? this.status,
      data: data ?? this.data,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'descricao': descricao,
      'categoria': categoria,
      'valor': valor,
      'status': status,
      'data': data.millisecondsSinceEpoch,
      'observacoes': observacoes,
    };
  }

  factory LancamentoFinanceiro.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return LancamentoFinanceiro(
      id: id,
      tipo: map['tipo']?.toString() ?? 'Receita',
      descricao: map['descricao']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      valor: map['valor'] is num
          ? (map['valor'] as num).toDouble()
          : double.tryParse(
                map['valor']?.toString() ?? '',
              ) ??
              0,
      status: map['status']?.toString() ?? 'Pendente',
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] is int
            ? map['data'] as int
            : int.tryParse(
                  map['data']?.toString() ?? '',
                ) ??
                DateTime.now().millisecondsSinceEpoch,
      ),
      observacoes:
          map['observacoes']?.toString() ?? '',
    );
  }
}