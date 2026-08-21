class ItemMaterialOrcamento {
  final String descricao;
  final double quantidade;
  final double valorUnitario;

  const ItemMaterialOrcamento({
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  double get valorTotal => quantidade * valorUnitario;

  Map<String, dynamic> toMap() => {
        'descricao': descricao,
        'quantidade': quantidade,
        'valorUnitario': valorUnitario,
        'valorTotal': valorTotal,
      };

  factory ItemMaterialOrcamento.fromMap(Map<String, dynamic> map) {
    return ItemMaterialOrcamento(
      descricao: map['descricao']?.toString() ?? '',
      quantidade: _numero(map['quantidade']),
      valorUnitario: _numero(map['valorUnitario']),
    );
  }

  static double _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }
}

class Orcamento {
  final String id;
  final String numero;
  final String cliente;
  final DateTime data;
  final double valor;
  final double valorMaoDeObra;
  final List<ItemMaterialOrcamento> materiais;
  final String status;
  final String descricao;
  final bool convertidoEmOs;

  const Orcamento({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.data,
    required this.valor,
    this.valorMaoDeObra = 0,
    this.materiais = const [],
    required this.status,
    this.descricao = '',
    this.convertidoEmOs = false,
  });

  double get subtotalMateriais => materiais.fold(
        0,
        (total, item) => total + item.valorTotal,
      );

  double get valorTotalCalculado => valorMaoDeObra + subtotalMateriais;

  Orcamento copyWith({
    String? id,
    String? numero,
    String? cliente,
    DateTime? data,
    double? valor,
    double? valorMaoDeObra,
    List<ItemMaterialOrcamento>? materiais,
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
      valorMaoDeObra: valorMaoDeObra ?? this.valorMaoDeObra,
      materiais: materiais ?? List<ItemMaterialOrcamento>.from(this.materiais),
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
      'valorMaoDeObra': valorMaoDeObra,
      'materiais': materiais.map((item) => item.toMap()).toList(),
      'status': status,
      'descricao': descricao,
      'convertidoEmOs': convertidoEmOs,
    };
  }

  factory Orcamento.fromMap(String id, Map<String, dynamic> map) {
    final materiaisMap = map['materiais'];
    final materiais = materiaisMap is List
        ? materiaisMap
            .whereType<Map>()
            .map((item) => ItemMaterialOrcamento.fromMap(
                  Map<String, dynamic>.from(item),
                ))
            .toList()
        : <ItemMaterialOrcamento>[];

    return Orcamento(
      id: id,
      numero: map['numero']?.toString() ?? '',
      cliente: map['cliente']?.toString() ?? '',
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] is int
            ? map['data'] as int
            : int.tryParse(map['data']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch,
      ),
      valor: _numero(map['valor']),
      valorMaoDeObra: _numero(map['valorMaoDeObra']),
      materiais: materiais,
      status: map['status']?.toString() ?? 'Aguardando',
      descricao: map['descricao']?.toString() ?? '',
      convertidoEmOs: map['convertidoEmOs'] == true,
    );
  }

  static double _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }
}
