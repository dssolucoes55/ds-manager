class Orcamento {
  final String id;
  final String numero;
  final String cliente;
  final DateTime data;
  final double valor;
  final String status;

  Orcamento({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.data,
    required this.valor,
    required this.status,
  });
}