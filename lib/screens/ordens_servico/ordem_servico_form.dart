import 'package:flutter/material.dart';

import '../../models/ordem_servico.dart';
import '../../services/cliente_service.dart';
import '../../services/ordem_servico_service.dart';

class OrdemServicoForm extends StatefulWidget {
  const OrdemServicoForm({super.key});

  @override
  State<OrdemServicoForm> createState() => _OrdemServicoFormState();
}

class _OrdemServicoFormState extends State<OrdemServicoForm> {
  String? _clienteSelecionado;

  final _tecnicoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacaoController = TextEditingController();

  String _prioridade = "Normal";

  @override
  void dispose() {
    _tecnicoController.dispose();
    _descricaoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_clienteSelecionado == null ||
        _descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha os campos obrigatórios."),
        ),
      );
      return;
    }

    final cliente = ClienteService.clientes.firstWhere(
      (c) => c.nome == _clienteSelecionado,
    );

    final ordem = OrdemServico(
      id: OrdemServicoService.gerarId(),
      numero: OrdemServicoService.gerarNumero(),
      clienteId: cliente.id,
      clienteNome: cliente.nome,
      tecnico: _tecnicoController.text.trim(),
      descricao: _descricaoController.text.trim(),
      prioridade: _prioridade,
      data: DateTime.now(),
      observacoes: _observacaoController.text.trim(),
    );

    OrdemServicoService.adicionar(ordem);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Ordem de Serviço"),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            DropdownButtonFormField<String>(
              value: _clienteSelecionado,
              decoration: const InputDecoration(
                labelText: "Cliente",
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              items: ClienteService.clientes.map((cliente) {
                return DropdownMenuItem(
                  value: cliente.nome,
                  child: Text(cliente.nome),
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
              controller: _tecnicoController,
              decoration: const InputDecoration(
                labelText: "Técnico",
                prefixIcon: Icon(Icons.engineering),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Descrição",
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _prioridade,
              decoration: const InputDecoration(
                labelText: "Prioridade",
                prefixIcon: Icon(Icons.priority_high),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Baixa",
                  child: Text("Baixa"),
                ),
                DropdownMenuItem(
                  value: "Normal",
                  child: Text("Normal"),
                ),
                DropdownMenuItem(
                  value: "Alta",
                  child: Text("Alta"),
                ),
                DropdownMenuItem(
                  value: "Urgente",
                  child: Text("Urgente"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _prioridade = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _observacaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Observações",
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text("SALVAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}