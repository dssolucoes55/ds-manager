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

class _OrcamentoFormState extends State<OrcamentoForm> {
  String? _clienteSelecionadoId;

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvarOrcamento(
    List<Cliente> clientes,
  ) async {
    final clienteId = _clienteSelecionadoId;
    final descricao = _descricaoController.text.trim();
    final valorTexto =
        _valorController.text.trim().replaceAll(',', '.');

    if (clienteId == null ||
        descricao.isEmpty ||
        valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos.',
          ),
        ),
      );
      return;
    }

    final valor = double.tryParse(valorTexto);

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe um valor válido.',
          ),
        ),
      );
      return;
    }

    final cliente = clientes.firstWhere(
      (cliente) => cliente.id == clienteId,
    );

    setState(() {
      _salvando = true;
    });

    try {
      final numero =
          await OrcamentoService.gerarNumero();

      final novoOrcamento = Orcamento(
        id: '',
        numero: numero,
        cliente: cliente.nome,
        data: DateTime.now(),
        valor: valor,
        status: 'Aguardando',
        descricao: descricao,
        convertidoEmOs: false,
      );

      await OrcamentoService.adicionar(
        novoOrcamento,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar orçamento: $erro',
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
        title: const Text('Novo Orçamento'),
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
                    initialValue: _clienteSelecionadoId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    items: clientes.map((cliente) {
                      return DropdownMenuItem<String>(
                        value: cliente.id,
                        child: Text(
                          cliente.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _clienteSelecionadoId = value;
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
                  keyboardType:
                      const TextInputType.numberWithOptions(
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
                    onPressed:
                        clientes.isEmpty || _salvando
                            ? null
                            : () => _salvarOrcamento(
                                  clientes,
                                ),
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