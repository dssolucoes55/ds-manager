import 'package:flutter/material.dart';

class OrdensServicoPage extends StatefulWidget {
  const OrdensServicoPage({super.key});

  @override
  State<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends State<OrdensServicoPage> {
  final List<OrdemServico> _ordens = [
    OrdemServico(
      numero: 'OS-2026-0001',
      cliente: 'Condomínio Leonardo da Vinci',
      descricao: 'Manutenção no quadro elétrico principal.',
      status: 'Aberta',
      data: DateTime.now(),
    ),
  ];

  Future<void> _abrirFormulario() async {
    final clienteController = TextEditingController();
    final descricaoController = TextEditingController();
    final tecnicoController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<OrdemServico>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Ordem de Serviço'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: clienteController,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o cliente.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: tecnicoController,
                      decoration: const InputDecoration(
                        labelText: 'Técnico responsável',
                        prefixIcon: Icon(Icons.engineering),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descricaoController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do serviço',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe a descrição do serviço.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final proximoNumero =
                    (_ordens.length + 1).toString().padLeft(4, '0');

                Navigator.pop(
                  context,
                  OrdemServico(
                    numero: 'OS-2026-$proximoNumero',
                    cliente: clienteController.text.trim(),
                    tecnico: tecnicoController.text.trim(),
                    descricao: descricaoController.text.trim(),
                    status: 'Aberta',
                    data: DateTime.now(),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    clienteController.dispose();
    tecnicoController.dispose();
    descricaoController.dispose();

    if (resultado == null) {
      return;
    }

    setState(() {
      _ordens.add(resultado);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ordem de Serviço criada com sucesso.'),
      ),
    );
  }

  void _alterarStatus(OrdemServico ordem, String novoStatus) {
    setState(() {
      ordem.status = novoStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: _ordens.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma Ordem de Serviço cadastrada.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _ordens.length,
              itemBuilder: (context, index) {
                final ordem = _ordens[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE30613),
                              foregroundColor: Colors.white,
                              child: Icon(Icons.assignment),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ordem.numero,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ordem.cliente,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (status) {
                                _alterarStatus(ordem, status);
                              },
                              itemBuilder: (context) {
                                return const [
                                  PopupMenuItem(
                                    value: 'Aberta',
                                    child: Text('Marcar como aberta'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Em andamento',
                                    child: Text('Marcar em andamento'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Concluída',
                                    child: Text('Marcar como concluída'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          ordem.descricao,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.info_outline,
                                size: 18,
                              ),
                              label: Text(ordem.status),
                            ),
                            Chip(
                              avatar: const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),
                              label: Text(
                                '${ordem.data.day.toString().padLeft(2, '0')}/'
                                '${ordem.data.month.toString().padLeft(2, '0')}/'
                                '${ordem.data.year}',
                              ),
                            ),
                            if (ordem.tecnico.isNotEmpty)
                              Chip(
                                avatar: const Icon(
                                  Icons.engineering,
                                  size: 18,
                                ),
                                label: Text(ordem.tecnico),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OrdemServico {
  final String numero;
  final String cliente;
  final String tecnico;
  final String descricao;
  String status;
  final DateTime data;

  OrdemServico({
    required this.numero,
    required this.cliente,
    this.tecnico = '',
    required this.descricao,
    required this.status,
    required this.data,
  });
}