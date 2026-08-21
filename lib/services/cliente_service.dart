import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cliente.dart';

class ClienteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _clientesRef =
      _firestore.collection('clientes');

  // Mantém compatibilidade com o Dashboard atual.
  static final List<Cliente> clientes = [];

  static Stream<List<Cliente>> observarClientes() {
    return _clientesRef.orderBy('nome').snapshots().map((snapshot) {
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
    final clienteRef = _clientesRef.doc(cliente.id);
    final clienteAtual = await clienteRef.get();
    final nomeAnterior = clienteAtual.data()?['nome']?.toString() ?? '';

    if (nomeAnterior.isEmpty || nomeAnterior == cliente.nome) {
      await clienteRef.update(cliente.toMap());
      return;
    }

    final resultados = await Future.wait([
      _firestore.collection('ordens_servico').get(),
      _firestore.collection('orcamentos').get(),
    ]);

    final nomeNormalizado = _normalizarNome(nomeAnterior);
    final ordens = resultados[0].docs.where((ordem) {
      final dados = ordem.data();
      final mesmoId = dados['clienteId']?.toString() == cliente.id;
      final mesmoNome =
          _normalizarNome(dados['clienteNome']?.toString() ?? '') ==
              nomeNormalizado;
      return mesmoId || mesmoNome;
    }).toList();

    final orcamentos = resultados[1].docs.where((orcamento) {
      final dados = orcamento.data();
      final mesmoId = dados['clienteId']?.toString() == cliente.id;
      final nome = dados['cliente']?.toString() ?? '';
      final mesmoNome = _normalizarNome(nome) == nomeNormalizado;
      return mesmoId || mesmoNome;
    }).toList();

    final totalOperacoes = 1 + ordens.length + orcamentos.length;

    if (totalOperacoes <= 500) {
      final lote = _firestore.batch();

      lote.update(clienteRef, cliente.toMap());

      for (final ordem in ordens) {
        lote.update(ordem.reference, {
          'clienteNome': cliente.nome,
        });
      }

      for (final orcamento in orcamentos) {
        lote.update(orcamento.reference, {
          'clienteId': cliente.id,
          'cliente': cliente.nome,
        });
      }

      await lote.commit();
      return;
    }

    await clienteRef.update(cliente.toMap());

    for (final ordem in ordens) {
      await ordem.reference.update({
        'clienteNome': cliente.nome,
      });
    }

    for (final orcamento in orcamentos) {
      await orcamento.reference.update({
        'clienteId': cliente.id,
        'cliente': cliente.nome,
      });
    }
  }

  static Future<void> remover(Cliente cliente) async {
    await _clientesRef.doc(cliente.id).delete();
  }

  static String gerarId() {
    return _clientesRef.doc().id;
  }

  static String _normalizarNome(String nome) {
    return nome.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
