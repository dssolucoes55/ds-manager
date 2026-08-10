import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/orcamento.dart';

class OrcamentoService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>>
      _orcamentosRef =
      _firestore.collection('orcamentos');

  static final List<Orcamento> orcamentos = [];

  static Stream<List<Orcamento>> observarOrcamentos() {
    return _orcamentosRef
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return Orcamento.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      orcamentos
        ..clear()
        ..addAll(lista);

      return lista;
    });
  }

  static Future<List<Orcamento>> carregarOrcamentos() async {
    final snapshot = await _orcamentosRef
        .orderBy('data', descending: true)
        .get();

    final lista = snapshot.docs.map((doc) {
      return Orcamento.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    orcamentos
      ..clear()
      ..addAll(lista);

    return lista;
  }

  static Future<void> adicionar(
    Orcamento orcamento,
  ) async {
    final doc = _orcamentosRef.doc();

    final novoOrcamento = orcamento.copyWith(
      id: doc.id,
    );

    await doc.set(
      novoOrcamento.toMap(),
    );
  }

  static Future<void> atualizar(
    Orcamento orcamento,
  ) async {
    await _orcamentosRef
        .doc(orcamento.id)
        .update(orcamento.toMap());
  }

  static Future<void> remover(
    Orcamento orcamento,
  ) async {
    await _orcamentosRef
        .doc(orcamento.id)
        .delete();
  }

  static String gerarId() {
    return _orcamentosRef.doc().id;
  }

  static Future<String> gerarNumero() async {
    final ano = DateTime.now().year;

    final snapshot = await _orcamentosRef
        .where(
          'numero',
          isGreaterThanOrEqualTo: 'ORC-$ano-',
        )
        .where(
          'numero',
          isLessThan: 'ORC-${ano + 1}-',
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

    return 'ORC-$ano-$proximo';
  }
}