import '../models/orcamento.dart';

class OrcamentoService {
  static final List<Orcamento> orcamentos = [];

  static void adicionar(Orcamento orcamento) {
    orcamentos.add(orcamento);
  }

  static void remover(Orcamento orcamento) {
    orcamentos.remove(orcamento);
  }

  static String gerarNumero() {
    final numero = (orcamentos.length + 1).toString().padLeft(4, '0');
    return 'ORC-${DateTime.now().year}-$numero';
  }
}