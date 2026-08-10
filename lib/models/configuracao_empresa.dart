class ConfiguracaoEmpresa {
  final String id;

  final String nomeEmpresa;
  final String cnpj;

  final String telefone;
  final String whatsapp;
  final String email;
  final String endereco;

  final String responsavelTecnico;
  final String crea;
  final String artPadrao;

  final String observacoes;

  const ConfiguracaoEmpresa({
    required this.id,
    required this.nomeEmpresa,
    this.cnpj = '',
    this.telefone = '',
    this.whatsapp = '',
    this.email = '',
    this.endereco = '',
    this.responsavelTecnico = '',
    this.crea = '',
    this.artPadrao = '',
    this.observacoes = '',
  });

  ConfiguracaoEmpresa copyWith({
    String? id,
    String? nomeEmpresa,
    String? cnpj,
    String? telefone,
    String? whatsapp,
    String? email,
    String? endereco,
    String? responsavelTecnico,
    String? crea,
    String? artPadrao,
    String? observacoes,
  }) {
    return ConfiguracaoEmpresa(
      id: id ?? this.id,
      nomeEmpresa: nomeEmpresa ?? this.nomeEmpresa,
      cnpj: cnpj ?? this.cnpj,
      telefone: telefone ?? this.telefone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      responsavelTecnico:
          responsavelTecnico ?? this.responsavelTecnico,
      crea: crea ?? this.crea,
      artPadrao: artPadrao ?? this.artPadrao,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeEmpresa': nomeEmpresa,
      'cnpj': cnpj,
      'telefone': telefone,
      'whatsapp': whatsapp,
      'email': email,
      'endereco': endereco,
      'responsavelTecnico': responsavelTecnico,
      'crea': crea,
      'artPadrao': artPadrao,
      'observacoes': observacoes,
    };
  }

  factory ConfiguracaoEmpresa.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ConfiguracaoEmpresa(
      id: id,
      nomeEmpresa:
          map['nomeEmpresa']?.toString() ?? 'DS SOLUÇÕES',
      cnpj: map['cnpj']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      endereco: map['endereco']?.toString() ?? '',
      responsavelTecnico:
          map['responsavelTecnico']?.toString() ?? '',
      crea: map['crea']?.toString() ?? '',
      artPadrao: map['artPadrao']?.toString() ?? '',
      observacoes:
          map['observacoes']?.toString() ?? '',
    );
  }
}