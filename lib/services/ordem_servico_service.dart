import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ordem_servico.dart';

class OrdemServicoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _ordensRef =
      _firestore.collection('ordens_servico');
  static final List<OrdemServico> ordens = [];

  static Stream<List<OrdemServico>> observarOrdens() {
    return _ordensRef.orderBy('data', descending: true).snapshots().map((s) {
      final lista =
          s.docs.map((doc) => OrdemServico.fromMap(doc.id, doc.data())).toList();
      ordens
        ..clear()
        ..addAll(lista);
      return lista;
    });
  }

  static Future<List<OrdemServico>> carregarOrdens() async {
    final s = await _ordensRef.orderBy('data', descending: true).get();
    final lista =
        s.docs.map((doc) => OrdemServico.fromMap(doc.id, doc.data())).toList();
    ordens
      ..clear()
      ..addAll(lista);
    return lista;
  }

  static Future<OrdemServico> adicionar(OrdemServico ordem) async {
    final doc = _ordensRef.doc();
    final novaOrdem = ordem.copyWith(id: doc.id);
    await doc.set(novaOrdem.toMap());
    return novaOrdem;
  }

  static Future<void> atualizar(OrdemServico ordem) async {
    await _ordensRef.doc(ordem.id).update(ordem.toMap());
  }

  static Future<void> remover(OrdemServico ordem) async {
    await _ordensRef.doc(ordem.id).delete();
  }

  static String gerarId() => _ordensRef.doc().id;

  static Future<String> gerarNumero() async {
    final ano = DateTime.now().year;
    final snapshot = await _ordensRef
        .where('numero', isGreaterThanOrEqualTo: 'OS-$ano-')
        .where('numero', isLessThan: 'OS-${ano + 1}-')
        .get();
    int maiorNumero = 0;
    for (final doc in snapshot.docs) {
      final partes = (doc.data()['numero']?.toString() ?? '').split('-');
      if (partes.length == 3) {
        final valor = int.tryParse(partes[2]) ?? 0;
        if (valor > maiorNumero) maiorNumero = valor;
      }
    }
    return 'OS-$ano-${(maiorNumero + 1).toString().padLeft(4, '0')}';
  }

  static bool existeOrdemDoOrcamento(String orcamentoId) {
    return ordens.any((ordem) => ordem.orcamentoId == orcamentoId);
  }

  static List<OrdemServico> buscarPorCliente(String clienteId) {
    return ordens.where((ordem) => ordem.clienteId == clienteId).toList();
  }
}
