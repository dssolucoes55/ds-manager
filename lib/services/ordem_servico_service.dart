import '../models/ordem_servico.dart';

class OrdemServicoService {
  static final List<OrdemServico> ordens = [];

  static void adicionar(OrdemServico ordem) {
    ordens.add(ordem);
  }

  static void atualizar(int index, OrdemServico ordem) {
    ordens[index] = ordem;
  }

  static void remover(OrdemServico ordem) {
    ordens.remove(ordem);
  }

  static String gerarId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String gerarNumero() {
    final numero = (ordens.length + 1).toString().padLeft(4, '0');
    return 'OS-${DateTime.now().year}-$numero';
  }

  static bool existeOrdemDoOrcamento(String orcamentoId) {
    return ordens.any(
      (ordem) => ordem.orcamentoId == orcamentoId,
    );
  }

  static List<OrdemServico> buscarPorCliente(String clienteId) {
    return ordens.where(
      (ordem) => ordem.clienteId == clienteId,
    ).toList();
  }
}