import 'package:flutter/material.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final TextEditingController _pesquisaController = TextEditingController();

  final List<Cliente> _clientes = [
    Cliente(
      nome: 'Condomínio Leonardo da Vinci',
      responsavel: 'Administração',
      telefone: '(85) 99999-9999',
      email: 'administracao@condominio.com',
    ),
    Cliente(
      nome: 'Shopping Central',
      responsavel: 'Setor de Manutenção',
      telefone: '(85) 98888-8888',
      email: 'manutencao@shopping.com',
    ),
    Cliente(
      nome: 'Empresa ABC',
      responsavel: 'Carlos',
      telefone: '(85) 97777-7777',
      email: 'carlos@empresaabc.com',
    ),
  ];

  String _pesquisa = '';

  List<Cliente> get _clientesFiltrados {
    if (_pesquisa.trim().isEmpty) {
      return _clientes;
    }

    final texto = _pesquisa.toLowerCase();

    return _clientes.where((cliente) {
      return cliente.nome.toLowerCase().contains(texto) ||
          cliente.responsavel.toLowerCase().contains(texto) ||
          cliente.telefone.toLowerCase().contains(texto) ||
          cliente.email.toLowerCase().contains(texto);
    }).toList();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario({Cliente? cliente, int? indice}) async {
    final nomeController = TextEditingController(text: cliente?.nome ?? '');
    final responsavelController = TextEditingController(
      text: cliente?.responsavel ?? '',
    );
    final telefoneController = TextEditingController(
      text: cliente?.telefone ?? '',
    );
    final emailController = TextEditingController(text: cliente?.email ?? '');

    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<Cliente>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            cliente == null ? 'Novo cliente' : 'Editar cliente',
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome, empresa ou condomínio',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o nome do cliente.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: responsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Responsável',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone ou WhatsApp',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email),
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
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                Navigator.pop(
                  context,
                  Cliente(
                    nome: nomeController.text.trim(),
                    responsavel: responsavelController.text.trim(),
                    telefone: telefoneController.text.trim(),
                    email: emailController.text.trim(),
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

    nomeController.dispose();
    responsavelController.dispose();
    telefoneController.dispose();
    emailController.dispose();

    if (resultado == null) {
      return;
    }

    setState(() {
      if (indice == null) {
        _clientes.add(resultado);
      } else {
        _clientes[indice] = resultado;
      }
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          indice == null
              ? 'Cliente cadastrado com sucesso.'
              : 'Cliente atualizado com sucesso.',
        ),
      ),
    );
  }

  Future<void> _excluirCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir cliente'),
          content: Text(
            'Deseja realmente excluir o cliente "${cliente.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    setState(() {
      _clientes.remove(cliente);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente excluído com sucesso.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientesFiltrados = _clientesFiltrados;

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
        onPressed: () {
          _abrirFormulario();
        },
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
              child: clientesFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum cliente encontrado.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final cliente = clientesFiltrados[index];
                        final indiceOriginal = _clientes.indexOf(cliente);

                        return _ClienteCard(
                          cliente: cliente,
                          onEditar: () {
                            _abrirFormulario(
                              cliente: cliente,
                              indice: indiceOriginal,
                            );
                          },
                          onExcluir: () {
                            _excluirCliente(cliente);
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

class Cliente {
  final String nome;
  final String responsavel;
  final String telefone;
  final String email;

  Cliente({
    required this.nome,
    required this.responsavel,
    required this.telefone,
    required this.email,
  });
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
            'Responsável: ${cliente.responsavel.isEmpty ? "Não informado" : cliente.responsavel}\n'
            'Telefone: ${cliente.telefone.isEmpty ? "Não informado" : cliente.telefone}\n'
            'E-mail: ${cliente.email.isEmpty ? "Não informado" : cliente.email}',
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (opcao) {
            if (opcao == 'editar') {
              onEditar();
            }

            if (opcao == 'excluir') {
              onExcluir();
            }
          },
          itemBuilder: (context) {
            return const [
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
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Excluir'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}