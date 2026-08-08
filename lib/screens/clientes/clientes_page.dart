import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../services/cliente_service.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final TextEditingController _pesquisaController = TextEditingController();

  String _pesquisa = '';

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  List<Cliente> _filtrarClientes(List<Cliente> clientes) {
    final texto = _pesquisa.trim().toLowerCase();

    if (texto.isEmpty) {
      return clientes;
    }

    return clientes.where((cliente) {
      return cliente.nome.toLowerCase().contains(texto) ||
          cliente.responsavel.toLowerCase().contains(texto) ||
          cliente.telefone.toLowerCase().contains(texto) ||
          cliente.whatsapp.toLowerCase().contains(texto) ||
          cliente.email.toLowerCase().contains(texto) ||
          cliente.documento.toLowerCase().contains(texto);
    }).toList();
  }

  Future<void> _abrirFormulario({
    Cliente? cliente,
  }) async {
    final resultado = await showDialog<Cliente>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ClienteFormDialog(
        cliente: cliente,
      ),
    );

    if (!mounted || resultado == null) {
      return;
    }

    try {
      if (cliente == null) {
        await ClienteService.adicionar(resultado);
      } else {
        await ClienteService.atualizar(resultado);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cliente == null
                ? 'Cliente cadastrado com sucesso.'
                : 'Cliente atualizado com sucesso.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar cliente: $erro',
          ),
        ),
      );
    }
  }

  Future<void> _excluirCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir cliente'),
          content: Text(
            'Deseja realmente excluir o cliente "${cliente.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) {
      return;
    }

    try {
      await ClienteService.remover(cliente);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cliente excluído com sucesso.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao excluir cliente: $erro',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pesquisaController,
              onChanged: (valor) {
                setState(() {
                  _pesquisa = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar cliente',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _pesquisa.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: () {
                          _pesquisaController.clear();

                          setState(() {
                            _pesquisa = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<Cliente>>(
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

                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE30613),
                      ),
                    );
                  }

                  final clientes =
                      _filtrarClientes(snapshot.data ?? []);

                  if (clientes.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum cliente encontrado.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];

                      return _ClienteCard(
                        cliente: cliente,
                        onEditar: () {
                          _abrirFormulario(
                            cliente: cliente,
                          );
                        },
                        onExcluir: () {
                          _excluirCliente(cliente);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClienteFormDialog extends StatefulWidget {
  final Cliente? cliente;

  const _ClienteFormDialog({
    this.cliente,
  });

  @override
  State<_ClienteFormDialog> createState() =>
      _ClienteFormDialogState();
}

class _ClienteFormDialogState
    extends State<_ClienteFormDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _documentoController;
  late final TextEditingController _responsavelController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _emailController;
  late final TextEditingController _enderecoController;
  late final TextEditingController _observacoesController;

  String _tipo = 'Condomínio';

  @override
  void initState() {
    super.initState();

    final cliente = widget.cliente;

    _nomeController = TextEditingController(
      text: cliente?.nome ?? '',
    );

    _documentoController = TextEditingController(
      text: cliente?.documento ?? '',
    );

    _responsavelController = TextEditingController(
      text: cliente?.responsavel ?? '',
    );

    _telefoneController = TextEditingController(
      text: cliente?.telefone ?? '',
    );

    _whatsappController = TextEditingController(
      text: cliente?.whatsapp ?? '',
    );

    _emailController = TextEditingController(
      text: cliente?.email ?? '',
    );

    _enderecoController = TextEditingController(
      text: cliente?.endereco ?? '',
    );

    _observacoesController = TextEditingController(
      text: cliente?.observacoes ?? '',
    );

    if (cliente != null && cliente.tipo.isNotEmpty) {
      _tipo = cliente.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _documentoController.dispose();
    _responsavelController.dispose();
    _telefoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _observacoesController.dispose();

    super.dispose();
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cliente = Cliente(
      id: widget.cliente?.id ?? '',
      nome: _nomeController.text.trim(),
      tipo: _tipo,
      documento: _documentoController.text.trim(),
      responsavel: _responsavelController.text.trim(),
      telefone: _telefoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      email: _emailController.text.trim(),
      endereco: _enderecoController.text.trim(),
      observacoes: _observacoesController.text.trim(),
    );

    Navigator.of(context).pop(cliente);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.cliente == null
            ? 'Novo cliente'
            : 'Editar cliente',
      ),
      content: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText:
                        'Nome, empresa ou condomínio',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null ||
                        valor.trim().isEmpty) {
                      return 'Informe o nome do cliente.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cliente',
                    prefixIcon:
                        Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Condomínio',
                      child: Text('Condomínio'),
                    ),
                    DropdownMenuItem(
                      value: 'Empresa',
                      child: Text('Empresa'),
                    ),
                    DropdownMenuItem(
                      value: 'Pessoa Física',
                      child: Text('Pessoa Física'),
                    ),
                    DropdownMenuItem(
                      value: 'Outro',
                      child: Text('Outro'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        _tipo = valor;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _documentoController,
                  decoration: const InputDecoration(
                    labelText: 'CPF / CNPJ',
                    prefixIcon:
                        Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _responsavelController,
                  decoration: const InputDecoration(
                    labelText: 'Responsável',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    prefixIcon:
                        Icon(Icons.chat_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    prefixIcon:
                        Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _observacoesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon:
                        Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFFE30613),
          ),
          onPressed: _salvar,
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _ClienteCard({
    required this.cliente,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE30613),
          foregroundColor: Colors.white,
          child: Icon(Icons.business),
        ),
        title: Text(
          cliente.nome,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Tipo: ${cliente.tipo.isEmpty ? "Não informado" : cliente.tipo}\n'
            'Responsável: ${cliente.responsavel.isEmpty ? "Não informado" : cliente.responsavel}\n'
            'Telefone: ${cliente.telefone.isEmpty ? "Não informado" : cliente.telefone}\n'
            'E-mail: ${cliente.email.isEmpty ? "Não informado" : cliente.email}',
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (opcao) {
            if (opcao == 'editar') {
              onEditar();
            }

            if (opcao == 'excluir') {
              onExcluir();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 10),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'excluir',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text('Excluir'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}