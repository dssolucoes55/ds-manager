import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/evento_agenda.dart';

class AgendaService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>>
      _agendaRef =
      _firestore.collection('agenda');

  static final List<EventoAgenda> eventos = [];

  static Stream<List<EventoAgenda>> observarEventos() {
    return _agendaRef
        .orderBy('data')
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return EventoAgenda.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      eventos
        ..clear()
        ..addAll(lista);

      return lista;
    });
  }

  static Future<List<EventoAgenda>> carregarEventos() async {
    final snapshot =
        await _agendaRef.orderBy('data').get();

    final lista = snapshot.docs.map((doc) {
      return EventoAgenda.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    eventos
      ..clear()
      ..addAll(lista);

    return lista;
  }

  static Future<void> adicionar(
    EventoAgenda evento,
  ) async {
    final doc = _agendaRef.doc();

    final novoEvento = evento.copyWith(
      id: doc.id,
    );

    await doc.set(
      novoEvento.toMap(),
    );
  }

  static Future<void> atualizar(
    EventoAgenda evento,
  ) async {
    await _agendaRef
        .doc(evento.id)
        .update(evento.toMap());
  }

  static Future<void> remover(
    EventoAgenda evento,
  ) async {
    await _agendaRef
        .doc(evento.id)
        .delete();
  }
}