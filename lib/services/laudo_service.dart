import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/laudo.dart';

class LaudoService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>>
      _laudosRef =
      _firestore.collection('laudos');

  static final List<Laudo> laudos = [];

  static Stream<List<Laudo>> observarLaudos() {
    return _laudosRef
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return Laudo.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      laudos
        ..clear()
        ..addAll(lista);

      return lista;
    });
  }

  static Future<List<Laudo>> carregarLaudos() async {
    final snapshot = await _laudosRef
        .orderBy('data', descending: true)
        .get();

    final lista = snapshot.docs.map((doc) {
      return Laudo.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    laudos
      ..clear()
      ..addAll(lista);

    return lista;
  }

  static Future<void> adicionar(
    Laudo laudo,
  ) async {
    final doc = _laudosRef.doc();

    final novoLaudo = laudo.copyWith(
      id: doc.id,
    );

    await doc.set(
      novoLaudo.toMap(),
    );
  }

  static Future<void> atualizar(
    Laudo laudo,
  ) async {
    await _laudosRef
        .doc(laudo.id)
        .update(laudo.toMap());
  }

  static Future<void> remover(
    Laudo laudo,
  ) async {
    await _laudosRef
        .doc(laudo.id)
        .delete();
  }

  static Future<String> gerarNumero() async {
    final ano = DateTime.now().year;

    final snapshot = await _laudosRef
        .where(
          'numero',
          isGreaterThanOrEqualTo: 'LAU-$ano-',
        )
        .where(
          'numero',
          isLessThan: 'LAU-${ano + 1}-',
        )
        .get();

    int maiorNumero = 0;

    for (final doc in snapshot.docs) {
      final numero =
          doc.data()['numero']?.toString() ?? '';

      final partes = numero.split('-');

      if (partes.length == 3) {
        final valor =
            int.tryParse(partes[2]) ?? 0;

        if (valor > maiorNumero) {
          maiorNumero = valor;
        }
      }
    }

    final proximo =
        (maiorNumero + 1)
            .toString()
            .padLeft(4, '0');

    return 'LAU-$ano-$proximo';
  }
}