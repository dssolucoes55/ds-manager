import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/evento_agenda.dart';
import '../models/ordem_servico.dart';

class AgendaService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _agendaRef =
      _firestore.collection('agenda');

  static final List<EventoAgenda> eventos = [];

  static Stream<List<EventoAgenda>> observarEventos() {
    return _agendaRef.orderBy('data').snapshots().map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => EventoAgenda.fromMap(doc.id, doc.data()))
          .toList();
      eventos
        ..clear()
        ..addAll(lista);
      return lista;
    });
  }

  static Future<List<EventoAgenda>> carregarEventos() async {
    final snapshot = await _agendaRef.orderBy('data').get();
    final lista = snapshot.docs
        .map((doc) => EventoAgenda.fromMap(doc.id, doc.data()))
        .toList();
    eventos
      ..clear()
      ..addAll(lista);
    return lista;
  }

  static Future<void> adicionar(EventoAgenda evento) async {
    final doc = _agendaRef.doc();
    await doc.set(evento.copyWith(id: doc.id).toMap());
  }

  static Future<void> atualizar(EventoAgenda evento) async {
    await _agendaRef.doc(evento.id).update(evento.toMap());
  }

  static Future<void> remover(EventoAgenda evento) async {
    await _agendaRef.doc(evento.id).delete();
  }

  static Future<void> sincronizarOrdemServico(OrdemServico ordem) async {
    final existentes = await _agendaRef
        .where('ordemServicoId', isEqualTo: ordem.id)
        .get();

    if (ordem.dataAgendamento == null) {
      for (final evento in existentes.docs) {
        await evento.reference.delete();
      }
      return;
    }

    final dados = EventoAgenda(
      id: existentes.docs.isEmpty ? '' : existentes.docs.first.id,
      titulo: '${ordem.numero} - Serviço',
      descricao: ordem.descricao,
      clienteId: ordem.clienteId,
      clienteNome: ordem.clienteNome,
      data: ordem.dataAgendamento!,
      tipo: 'Serviço',
      status: ordem.status.toLowerCase() == 'concluída' ||
              ordem.status.toLowerCase() == 'concluida'
          ? 'Concluído'
          : ordem.status.toLowerCase() == 'cancelada'
              ? 'Cancelado'
              : ordem.status.toLowerCase() == 'em andamento'
                  ? 'Confirmado'
                  : 'Agendado',
      observacoes: ordem.tecnico.isEmpty
          ? ordem.observacoes
          : 'Técnico: ${ordem.tecnico}\n${ordem.observacoes}',
      ordemServicoId: ordem.id,
    );

    if (existentes.docs.isEmpty) {
      await adicionar(dados);
    } else {
      await existentes.docs.first.reference.update(dados.toMap());
      for (final duplicado in existentes.docs.skip(1)) {
        await duplicado.reference.delete();
      }
    }
  }

  static Future<void> removerPorOrdemServico(String ordemServicoId) async {
    final eventos = await _agendaRef
        .where('ordemServicoId', isEqualTo: ordemServicoId)
        .get();
    for (final evento in eventos.docs) {
      await evento.reference.delete();
    }
  }
}
