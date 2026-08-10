import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/configuracao_empresa.dart';

class ConfiguracaoService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final DocumentReference<Map<String, dynamic>>
      _configRef =
      _firestore
          .collection('configuracoes')
          .doc('empresa');

  static Stream<ConfiguracaoEmpresa> observar() {
    return _configRef.snapshots().map((snapshot) {
      if (!snapshot.exists ||
          snapshot.data() == null) {
        return const ConfiguracaoEmpresa(
          id: 'empresa',
          nomeEmpresa: 'DS SOLUÇÕES',
        );
      }

      return ConfiguracaoEmpresa.fromMap(
        snapshot.id,
        snapshot.data()!,
      );
    });
  }

  static Future<ConfiguracaoEmpresa> carregar() async {
    final snapshot = await _configRef.get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return const ConfiguracaoEmpresa(
        id: 'empresa',
        nomeEmpresa: 'DS SOLUÇÕES',
      );
    }

    return ConfiguracaoEmpresa.fromMap(
      snapshot.id,
      snapshot.data()!,
    );
  }

  static Future<void> salvar(
    ConfiguracaoEmpresa configuracao,
  ) async {
    await _configRef.set(
      configuracao.toMap(),
      SetOptions(
        merge: true,
      ),
    );
  }
}