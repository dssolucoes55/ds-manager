import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/laudo.dart';
import '../../services/cliente_service.dart';
import '../../services/laudo_service.dart';

class LaudoForm extends StatefulWidget {
  const LaudoForm({super.key});

  @override
  State<LaudoForm> createState() => _LaudoFormState();
}

class _LaudoFormState extends State<LaudoForm> {
  String? _clienteSelecionadoId;

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _parecerController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _registroController = TextEditingController();
  final _artController = TextEditingController();

  String _status = 'Em elaboração';
  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _parecerController.dispose();
    _observacoesController.dispose();
    _responsavelController.dispose();
    _registroController.dispose();
    _artController.dispose();
    super.dispose();
  }

  Future<void> _salvar(
    List<Cliente> clientes,
  ) async {
    final clienteId = _clienteSelecionadoId;
    final titulo = _tituloController.text.trim();
    final descricao = _descricaoController.text.trim();

    if (clienteId == null ||
        titulo.isEmpty ||
        descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha cliente, título e descrição.',
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
          await LaudoService.gerarNumero();

      final laudo = Laudo(
        id: '',
        numero: numero,
        clienteId: cliente.id,
        clienteNome: cliente.nome,
        titulo: titulo,
        descricao: descricao,
        parecerTecnico:
            _parecerController.text.trim(),
        observacoes:
            _observacoesController.text.trim(),
        responsavelTecnico:
            _responsavelController.text.trim(),
        registroProfissional:
            _registroController.text.trim(),
        art: _artController.text.trim(),
        status: _status,
        data: DateTime.now(),
      );

      await LaudoService.adicionar(laudo);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar laudo: $erro',
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Novo Laudo'),
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

              const SizedBox(height: 18),

              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título do laudo',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _descricaoController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição técnica',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _parecerController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Parecer técnico',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.engineering),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _observacoesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _responsavelController,
                decoration: const InputDecoration(
                  labelText: 'Responsável técnico',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _registroController,
                decoration: const InputDecoration(
                  labelText: 'CREA / Registro profissional',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _artController,
                decoration: const InputDecoration(
                  labelText: 'ART',
                  prefixIcon: Icon(Icons.assignment_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Em elaboração',
                    child: Text('Em elaboração'),
                  ),
                  DropdownMenuItem(
                    value: 'Concluído',
                    child: Text('Concluído'),
                  ),
                  DropdownMenuItem(
                    value: 'Entregue',
                    child: Text('Entregue'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _status = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      clientes.isEmpty || _salvando
                          ? null
                          : () => _salvar(clientes),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFE30613),
                    foregroundColor: Colors.white,
                  ),
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _salvando
                        ? 'SALVANDO...'
                        : 'SALVAR LAUDO',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}