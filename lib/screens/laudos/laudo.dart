class Laudo {
  final String id;
  final String numero;

  final String clienteId;
  final String clienteNome;

  final String titulo;
  final String descricao;
  final String parecerTecnico;
  final String observacoes;

  final String responsavelTecnico;
  final String registroProfissional;
  final String art;

  final String status;
  final DateTime data;

  const Laudo({
    required this.id,
    required this.numero,
    required this.clienteId,
    required this.clienteNome,
    required this.titulo,
    required this.descricao,
    this.parecerTecnico = '',
    this.observacoes = '',
    this.responsavelTecnico = '',
    this.registroProfissional = '',
    this.art = '',
    this.status = 'Em elaboração',
    required this.data,
  });

  Laudo copyWith({
    String? id,
    String? numero,
    String? clienteId,
    String? clienteNome,
    String? titulo,
    String? descricao,
    String? parecerTecnico,
    String? observacoes,
    String? responsavelTecnico,
    String? registroProfissional,
    String? art,
    String? status,
    DateTime? data,
  }) {
    return Laudo(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      parecerTecnico:
          parecerTecnico ?? this.parecerTecnico,
      observacoes:
          observacoes ?? this.observacoes,
      responsavelTecnico:
          responsavelTecnico ?? this.responsavelTecnico,
      registroProfissional:
          registroProfissional ?? this.registroProfissional,
      art: art ?? this.art,
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'titulo': titulo,
      'descricao': descricao,
      'parecerTecnico': parecerTecnico,
      'observacoes': observacoes,
      'responsavelTecnico': responsavelTecnico,
      'registroProfissional': registroProfissional,
      'art': art,
      'status': status,
      'data': data.millisecondsSinceEpoch,
    };
  }

  factory Laudo.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Laudo(
      id: id,
      numero: map['numero']?.toString() ?? '',
      clienteId: map['clienteId']?.toString() ?? '',
      clienteNome: map['clienteNome']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      parecerTecnico:
          map['parecerTecnico']?.toString() ?? '',
      observacoes:
          map['observacoes']?.toString() ?? '',
      responsavelTecnico:
          map['responsavelTecnico']?.toString() ?? '',
      registroProfissional:
          map['registroProfissional']?.toString() ?? '',
      art: map['art']?.toString() ?? '',
      status:
          map['status']?.toString() ?? 'Em elaboração',
      data: DateTime.fromMillisecondsSinceEpoch(
        map['data'] is int
            ? map['data'] as int
            : int.tryParse(
                  map['data']?.toString() ?? '',
                ) ??
                DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}