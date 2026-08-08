import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/ordem_servico.dart';
import '../../services/cliente_service.dart';
import '../../services/ordem_servico_service.dart';

class OrdemServicoForm extends StatefulWidget {
  const OrdemServicoForm({super.key});

  @override
  State<OrdemServicoForm> createState() => _OrdemServicoFormState();
}

class _OrdemServicoFormState extends State<OrdemServicoForm> {
  String? _clienteSelecionadoId;

  final _tecnicoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacaoController = TextEditingController();

  String _prioridade = 'Normal';
  bool _salvando = false;

  @override
  void dispose() {
    _tecnicoController.dispose();
    _descricaoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar(List<Cliente> clientes) async {
    if (_clienteSelecionadoId == null ||
        _descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos obrigatórios.'),
        ),
      );
      return;
    }

    final cliente = clientes.firstWhere(
      (cliente) => cliente.id == _clienteSelecionadoId,
    );

    setState(() {
      _salvando = true;
    });

    try {
      final ordem = OrdemServico(
        id: '',
        numero: await OrdemServicoService.gerarNumero(),
        clienteId: cliente.id,
        clienteNome: cliente.nome,
        tecnico: _tecnicoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        prioridade: _prioridade,
        status: 'Aberta',
        data: DateTime.now(),
        observacoes: _observacaoController.text.trim(),
      );

      await OrdemServicoService.adicionar(ordem);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar Ordem de Serviço: $erro',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ordem de Serviço'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: ClienteService.observarClientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar clientes:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE30613),
              ),
            );
          }

          final clientes = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _clienteSelecionadoId,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  items: clientes.map((cliente) {
                    return DropdownMenuItem<String>(
                      value: cliente.id,
                      child: Text(cliente.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _clienteSelecionadoId = value;
                    });
                  },
                ),

                if (clientes.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Cadastre um cliente antes de criar uma Ordem de Serviço.',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                TextField(
                  controller: _tecnicoController,
                  decoration: const InputDecoration(
                    labelText: 'Técnico',
                    prefixIcon: Icon(Icons.engineering),
                    border: OutlineInputBorder(),
                  ),
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

                DropdownButtonFormField<String>(
                  initialValue: _prioridade,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    prefixIcon: Icon(Icons.priority_high),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Baixa',
                      child: Text('Baixa'),
                    ),
                    DropdownMenuItem(
                      value: 'Normal',
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: 'Alta',
                      child: Text('Alta'),
                    ),
                    DropdownMenuItem(
                      value: 'Urgente',
                      child: Text('Urgente'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _prioridade = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _observacaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _salvando || clientes.isEmpty
                        ? null
                        : () => _salvar(clientes),
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
                    label: Text(
                      _salvando
                          ? 'SALVANDO...'
                          : 'SALVAR',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}