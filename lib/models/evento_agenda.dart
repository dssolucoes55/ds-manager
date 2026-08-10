class EventoAgenda {
  final String id;
  final String titulo;
  final String descricao;
  final String clienteId;
  final String clienteNome;
  final DateTime data;
  final String tipo;
  final String status;
  final String observacoes;

  const EventoAgenda({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.clienteId,
    required this.clienteNome,
    required this.data,
    required this.tipo,
    required this.status,
    this.observacoes = '',
  });

  EventoAgenda copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? clienteId,
    String? clienteNome,
    DateTime? data,
    String? tipo,
    String? status,
    String? observacoes,
  }) {
    return EventoAgenda(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'data': data.millisecondsSinceEpoch,
      'tipo': tipo,
      'status': status,
      'observacoes': observacoes,
    };
  }

  factory EventoAgenda.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return EventoAgenda(
      id: id,
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      clienteId: map['clienteId']?.toString() ?? '',
      clienteNome: map['clienteNome']?.toString() ?? '',
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] is int
            ? map['data'] as int
            : int.tryParse(
                  map['data']?.toString() ?? '',
                ) ??
                DateTime.now().millisecondsSinceEpoch,
      ),
      tipo: map['tipo']?.toString() ?? 'Visita',
      status: map['status']?.toString() ?? 'Agendado',
      observacoes: map['observacoes']?.toString() ?? '',
    );
  }
}