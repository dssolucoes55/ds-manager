import 'package:flutter/material.dart';

import '../../models/orcamento.dart';
import '../../services/cliente_service.dart';
import '../../services/orcamento_service.dart';

class OrcamentoForm extends StatefulWidget {
  const OrcamentoForm({super.key});

  @override
  State<OrcamentoForm> createState() => _OrcamentoFormState();
}

class _OrcamentoFormState extends State<OrcamentoForm> {
  String? _clienteSelecionado;

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvarOrcamento() {
    final cliente = _clienteSelecionado ?? '';
    final descricao = _descricaoController.text.trim();
    final valorTexto = _valorController.text.trim().replaceAll(',', '.');

    if (cliente.isEmpty || descricao.isEmpty || valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );
      return;
    }

    final valor = double.tryParse(valorTexto);

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor válido.'),
        ),
      );
      return;
    }

    final novoOrcamento = Orcamento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numero: OrcamentoService.gerarNumero(),
      cliente: cliente,
      data: DateTime.now(),
      valor: valor,
      status: 'Aguardando',
    );

    OrcamentoService.adicionar(novoOrcamento);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ClienteService.clientes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Orçamento'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (clientes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cadastre pelo menos um cliente antes de criar um orçamento.',
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _clienteSelecionado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                items: clientes.map((cliente) {
                  return DropdownMenuItem<String>(
                    value: cliente.nome,
                    child: Text(
                      cliente.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _clienteSelecionado = value;
                  });
                },
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: clientes.isEmpty ? null : _salvarOrcamento,
                icon: const Icon(Icons.save),
                label: const Text('SALVAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}