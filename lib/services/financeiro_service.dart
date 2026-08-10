import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lancamento_financeiro.dart';

class FinanceiroService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>>
      _financeiroRef =
      _firestore.collection('financeiro');

  static final List<LancamentoFinanceiro> lancamentos = [];

  static Stream<List<LancamentoFinanceiro>>
      observarLancamentos() {
    return _financeiroRef
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return LancamentoFinanceiro.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      lancamentos
        ..clear()
        ..addAll(lista);

      return lista;
    });
  }

  static Future<List<LancamentoFinanceiro>>
      carregarLancamentos() async {
    final snapshot = await _financeiroRef
        .orderBy('data', descending: true)
        .get();

    final lista = snapshot.docs.map((doc) {
      return LancamentoFinanceiro.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    lancamentos
      ..clear()
      ..addAll(lista);

    return lista;
  }

  static Future<void> adicionar(
    LancamentoFinanceiro lancamento,
  ) async {
    final doc = _financeiroRef.doc();

    final novoLancamento = lancamento.copyWith(
      id: doc.id,
    );

    await doc.set(
      novoLancamento.toMap(),
    );
  }

  static Future<void> atualizar(
    LancamentoFinanceiro lancamento,
  ) async {
    await _financeiroRef
        .doc(lancamento.id)
        .update(lancamento.toMap());
  }

  static Future<void> remover(
    LancamentoFinanceiro lancamento,
  ) async {
    await _financeiroRef
        .doc(lancamento.id)
        .delete();
  }

  static double calcularTotalReceitas(
    List<LancamentoFinanceiro> lista,
  ) {
    return lista
        .where(
          (item) =>
              item.tipo.toLowerCase() == 'receita',
        )
        .fold(
          0,
          (total, item) => total + item.valor,
        );
  }

  static double calcularTotalDespesas(
    List<LancamentoFinanceiro> lista,
  ) {
    return lista
        .where(
          (item) =>
              item.tipo.toLowerCase() == 'despesa',
        )
        .fold(
          0,
          (total, item) => total + item.valor,
        );
  }

  static double calcularSaldo(
    List<LancamentoFinanceiro> lista,
  ) {
    return calcularTotalReceitas(lista) -
        calcularTotalDespesas(lista);
  }
}