import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ordem_servico.dart';

class OrdemServicoService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _ordensRef =
      _firestore.collection('ordens_servico');

  // Mantém compatibilidade temporária com outras telas do sistema.
  static final List<OrdemServico> ordens = [];

  static Stream<List<OrdemServico>> observarOrdens() {
    return _ordensRef
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return OrdemServico.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      ordens
        ..clear()
        ..addAll(lista);

      return lista;
    });
  }

  static Future<List<OrdemServico>> carregarOrdens() async {
    final snapshot =
        await _ordensRef.orderBy('data', descending: true).get();

    final lista = snapshot.docs.map((doc) {
      return OrdemServico.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    ordens
      ..clear()
      ..addAll(lista);

    return lista;
  }

  static Future<void> adicionar(OrdemServico ordem) async {
    final doc = _ordensRef.doc();

    final novaOrdem = ordem.copyWith(
      id: doc.id,
    );

    await doc.set(
      novaOrdem.toMap(),
    );
  }

  static Future<void> atualizar(OrdemServico ordem) async {
    await _ordensRef
        .doc(ordem.id)
        .update(ordem.toMap());
  }

  static Future<void> remover(OrdemServico ordem) async {
    await _ordensRef
        .doc(ordem.id)
        .delete();
  }

  static String gerarId() {
    return _ordensRef.doc().id;
  }

  static Future<String> gerarNumero() async {
    final ano = DateTime.now().year;

    final snapshot = await _ordensRef
        .where('numero', isGreaterThanOrEqualTo: 'OS-$ano-')
        .where('numero', isLessThan: 'OS-${ano + 1}-')
        .get();

    int maiorNumero = 0;

    for (final doc in snapshot.docs) {
      final numero =
          doc.data()['numero']?.toString() ?? '';

      final partes = numero.split('-');

      if (partes.length == 3) {
        final valor = int.tryParse(partes[2]) ?? 0;

        if (valor > maiorNumero) {
          maiorNumero = valor;
        }
      }
    }

    final proximo =
        (maiorNumero + 1).toString().padLeft(4, '0');

    return 'OS-$ano-$proximo';
  }

  static bool existeOrdemDoOrcamento(String orcamentoId) {
    return ordens.any(
      (ordem) => ordem.orcamentoId == orcamentoId,
    );
  }

  static List<OrdemServico> buscarPorCliente(String clienteId) {
    return ordens
        .where(
          (ordem) => ordem.clienteId == clienteId,
        )
        .toList();
  }
}