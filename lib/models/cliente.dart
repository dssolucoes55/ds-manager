class Cliente {
  final String id;
  final String nome;
  final String tipo;
  final String documento;
  final String responsavel;
  final String telefone;
  final String whatsapp;
  final String email;
  final String endereco;
  final String observacoes;

  const Cliente({
    required this.id,
    required this.nome,
    this.tipo = '',
    this.documento = '',
    this.responsavel = '',
    this.telefone = '',
    this.whatsapp = '',
    this.email = '',
    this.endereco = '',
    this.observacoes = '',
  });

  Cliente copyWith({
    String? id,
    String? nome,
    String? tipo,
    String? documento,
    String? responsavel,
    String? telefone,
    String? whatsapp,
    String? email,
    String? endereco,
    String? observacoes,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      documento: documento ?? this.documento,
      responsavel: responsavel ?? this.responsavel,
      telefone: telefone ?? this.telefone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'documento': documento,
      'responsavel': responsavel,
      'telefone': telefone,
      'whatsapp': whatsapp,
      'email': email,
      'endereco': endereco,
      'observacoes': observacoes,
    };
  }

  factory Cliente.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Cliente(
      id: id,
      nome: map['nome']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      documento: map['documento']?.toString() ?? '',
      responsavel: map['responsavel']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      endereco: map['endereco']?.toString() ?? '',
      observacoes: map['observacoes']?.toString() ?? '',
    );
  }
}