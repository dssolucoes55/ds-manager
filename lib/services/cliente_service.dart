import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cliente.dart';

class ClienteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _clientesRef =
      _firestore.collection('clientes');

  // Mantém compatibilidade com o Dashboard atual.
  static final List<Cliente> clientes = [];

  static Stream<List<Cliente>> observarClientes() {
    return _clientesRef
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return Cliente.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      clientes
        ..clear()
        ..addAll(lista);

      return lista;
    });
  }

  static Future<List<Cliente>> carregarClientes() async {
    final snapshot = await _clientesRef.orderBy('nome').get();

    final lista = snapshot.docs.map((doc) {
      return Cliente.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    clientes
      ..clear()
      ..addAll(lista);

    return lista;
  }

  static Future<void> adicionar(Cliente cliente) async {
    final doc = _clientesRef.doc();

    final novoCliente = cliente.copyWith(
      id: doc.id,
    );

    await doc.set(
      novoCliente.toMap(),
    );
  }

  static Future<void> atualizar(Cliente cliente) async {
    await _clientesRef
        .doc(cliente.id)
        .update(cliente.toMap());
  }

  static Future<void> remover(Cliente cliente) async {
    await _clientesRef
        .doc(cliente.id)
        .delete();
  }

  static String gerarId() {
    return _clientesRef.doc().id;
  }
}