import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/orcamento.dart';
import '../../services/cliente_service.dart';
import '../../services/orcamento_service.dart';

class OrcamentoForm extends StatefulWidget {
  const OrcamentoForm({super.key});

  @override
  State<OrcamentoForm> createState() => _OrcamentoFormState();
}

class _MaterialLinha {
  final descricao = TextEditingController();
  final quantidade = TextEditingController(text: '1');
  final valorUnitario = TextEditingController();

  void dispose() {
    descricao.dispose();
    quantidade.dispose();
    valorUnitario.dispose();
  }
}

class _OrcamentoFormState extends State<OrcamentoForm> {
  String? _clienteSelecionadoId;
  final _descricaoController = TextEditingController();
  final _maoDeObraController = TextEditingController();
  final List<_MaterialLinha> _materiais = [_MaterialLinha()];
  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _maoDeObraController.dispose();
    for (final item in _materiais) {
      item.dispose();
    }
    super.dispose();
  }

  double _numero(String texto) {
    var valor = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (valor.contains(',')) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(valor) ?? 0;
  }

  double _totalLinha(_MaterialLinha item) {
    return _numero(item.quantidade.text) * _numero(item.valorUnitario.text);
  }

  double get _subtotalMateriais =>
      _materiais.fold(0, (total, item) => total + _totalLinha(item));

  double get _valorMaoDeObra => _numero(_maoDeObraController.text);
  double get _valorTotal => _subtotalMateriais + _valorMaoDeObra;

  String _moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _adicionarMaterial() {
    setState(() => _materiais.add(_MaterialLinha()));
  }

  void _removerMaterial(int indice) {
    setState(() {
      final removido = _materiais.removeAt(indice);
      removido.dispose();
    });
  }

  Future<void> _salvarOrcamento(List<Cliente> clientes) async {
    final clienteId = _clienteSelecionadoId;
    final descricao = _descricaoController.text.trim();

    if (clienteId == null || descricao.isEmpty) {
      _mensagem('Selecione o cliente e descreva o serviço.');
      return;
    }

    final materiaisValidos = <ItemMaterialOrcamento>[];
    for (final linha in _materiais) {
      final nome = linha.descricao.text.trim();
      final quantidade = _numero(linha.quantidade.text);
      final unitario = _numero(linha.valorUnitario.text);
      final linhaVazia = nome.isEmpty &&
          linha.valorUnitario.text.trim().isEmpty;

      if (linhaVazia) continue;
      if (nome.isEmpty || quantidade <= 0 || unitario < 0) {
        _mensagem('Preencha corretamente todas as linhas de materiais.');
        return;
      }

      materiaisValidos.add(
        ItemMaterialOrcamento(
          descricao: nome,
          quantidade: quantidade,
          valorUnitario: unitario,
        ),
      );
    }

    if (_valorTotal <= 0) {
      _mensagem('Informe o valor da mão de obra ou dos materiais.');
      return;
    }

    final cliente = clientes.firstWhere((item) => item.id == clienteId);
    setState(() => _salvando = true);

    try {
      final numero = await OrcamentoService.gerarNumero();
      final novoOrcamento = Orcamento(
        id: '',
        numero: numero,
        cliente: cliente.nome,
        data: DateTime.now(),
        valor: _valorTotal,
        valorMaoDeObra: _valorMaoDeObra,
        materiais: materiaisValidos,
        status: 'Aguardando',
        descricao: descricao,
        convertidoEmOs: false,
      );

      await OrcamentoService.adicionar(novoOrcamento);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      _mensagem('Erro ao salvar orçamento: $erro', erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: erro ? Colors.red : null,
        content: Text(texto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Orçamento'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: ClienteService.observarClientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar clientes:\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clientes = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _clienteSelecionadoId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                items: clientes
                    .map((cliente) => DropdownMenuItem(
                          value: cliente.id,
                          child: Text(cliente.nome),
                        ))
                    .toList(),
                onChanged: (valor) =>
                    setState(() => _clienteSelecionadoId = valor),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descricaoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrição dos serviços',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Materiais',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Adicione os materiais necessários, um por linha.'),
              const SizedBox(height: 12),
              ...List.generate(_materiais.length, _cardMaterial),
              OutlinedButton.icon(
                onPressed: _adicionarMaterial,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar material'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _maoDeObraController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Valor da mão de obra',
                  prefixText: 'R\$ ',
                  prefixIcon: Icon(Icons.engineering),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _linhaTotal('Subtotal dos materiais', _subtotalMateriais),
                      const SizedBox(height: 10),
                      _linhaTotal('Mão de obra', _valorMaoDeObra),
                      const Divider(height: 24),
                      _linhaTotal('VALOR TOTAL', _valorTotal, destaque: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: clientes.isEmpty || _salvando
                      ? null
                      : () => _salvarOrcamento(clientes),
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_salvando ? 'SALVANDO...' : 'SALVAR ORÇAMENTO'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cardMaterial(int indice) {
    final item = _materiais[indice];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Material ${indice + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  tooltip: 'Remover material',
                  onPressed: () => _removerMaterial(indice),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: item.descricao,
              decoration: const InputDecoration(
                labelText: 'Descrição do material',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.quantidade,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: item.valorUnitario,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Valor unitário',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${_moeda(_totalLinha(item))}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaTotal(String titulo, double valor, {bool destaque = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo,
            style: TextStyle(
              fontSize: destaque ? 17 : 15,
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
            )),
        Text(_moeda(valor),
            style: TextStyle(
              fontSize: destaque ? 20 : 15,
              fontWeight: FontWeight.bold,
              color: destaque ? const Color(0xFFE30613) : null,
            )),
      ],
    );
  }
}
