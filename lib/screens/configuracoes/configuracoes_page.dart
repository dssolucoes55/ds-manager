import 'package:flutter/material.dart';

import '../../models/configuracao_empresa.dart';
import '../../services/configuracao_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() =>
      _ConfiguracoesPageState();
}

class _ConfiguracoesPageState
    extends State<ConfiguracoesPage> {
  final _nomeEmpresaController =
      TextEditingController();

  final _cnpjController =
      TextEditingController();

  final _telefoneController =
      TextEditingController();

  final _whatsappController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _enderecoController =
      TextEditingController();

  final _responsavelController =
      TextEditingController();

  final _creaController =
      TextEditingController();

  final _artController =
      TextEditingController();

  final _observacoesController =
      TextEditingController();

  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final configuracao =
          await ConfiguracaoService.carregar();

      _nomeEmpresaController.text =
          configuracao.nomeEmpresa;

      _cnpjController.text =
          configuracao.cnpj;

      _telefoneController.text =
          configuracao.telefone;

      _whatsappController.text =
          configuracao.whatsapp;

      _emailController.text =
          configuracao.email;

      _enderecoController.text =
          configuracao.endereco;

      _responsavelController.text =
          configuracao.responsavelTecnico;

      _creaController.text =
          configuracao.crea;

      _artController.text =
          configuracao.artPadrao;

      _observacoesController.text =
          configuracao.observacoes;
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao carregar configurações: $erro',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _salvar() async {
    final nomeEmpresa =
        _nomeEmpresaController.text.trim();

    if (nomeEmpresa.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o nome da empresa.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final configuracao =
          ConfiguracaoEmpresa(
        id: 'empresa',
        nomeEmpresa: nomeEmpresa,
        cnpj:
            _cnpjController.text.trim(),
        telefone:
            _telefoneController.text.trim(),
        whatsapp:
            _whatsappController.text.trim(),
        email:
            _emailController.text.trim(),
        endereco:
            _enderecoController.text.trim(),
        responsavelTecnico:
            _responsavelController.text.trim(),
        crea:
            _creaController.text.trim(),
        artPadrao:
            _artController.text.trim(),
        observacoes:
            _observacoesController.text.trim(),
      );

      await ConfiguracaoService.salvar(
        configuracao,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Configurações salvas com sucesso.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar configurações: $erro',
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
  void dispose() {
    _nomeEmpresaController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _responsavelController.dispose();
    _creaController.dispose();
    _artController.dispose();
    _observacoesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title:
            const Text('Configurações'),
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor:
            Colors.white,
      ),

      body: _carregando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFFE30613),
              ),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              children: [
                const Text(
                  'Dados da Empresa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                const Text(
                  'Essas informações poderão ser usadas nos PDFs, laudos e documentos gerados pelo sistema.',
                  style: TextStyle(
                    color:
                        Colors.black54,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                _campo(
                  controller:
                      _nomeEmpresaController,
                  label:
                      'Nome da empresa',
                  icon:
                      Icons.business,
                ),

                _campo(
                  controller:
                      _cnpjController,
                  label: 'CNPJ',
                  icon:
                      Icons.badge_outlined,
                ),

                _campo(
                  controller:
                      _telefoneController,
                  label: 'Telefone',
                  icon:
                      Icons.phone_outlined,
                ),

                _campo(
                  controller:
                      _whatsappController,
                  label: 'WhatsApp',
                  icon:
                      Icons.chat_outlined,
                ),

                _campo(
                  controller:
                      _emailController,
                  label: 'E-mail',
                  icon:
                      Icons.email_outlined,
                ),

                _campo(
                  controller:
                      _enderecoController,
                  label: 'Endereço',
                  icon:
                      Icons.location_on_outlined,
                  maxLines: 2,
                ),

                const SizedBox(
                  height: 14,
                ),

                const Divider(),

                const SizedBox(
                  height: 14,
                ),

                const Text(
                  'Responsável Técnico',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                _campo(
                  controller:
                      _responsavelController,
                  label:
                      'Responsável técnico',
                  icon:
                      Icons.engineering_outlined,
                ),

                _campo(
                  controller:
                      _creaController,
                  label:
                      'CREA / Registro profissional',
                  icon:
                      Icons.workspace_premium_outlined,
                ),

                _campo(
                  controller:
                      _artController,
                  label:
                      'ART padrão',
                  icon:
                      Icons.assignment_outlined,
                ),

                const SizedBox(
                  height: 14,
                ),

                _campo(
                  controller:
                      _observacoesController,
                  label:
                      'Observações',
                  icon:
                      Icons.notes_outlined,
                  maxLines: 4,
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _salvando
                            ? null
                            : _salvar,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFE30613,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.save,
                          ),
                    label: Text(
                      _salvando
                          ? 'SALVANDO...'
                          : 'SALVAR CONFIGURAÇÕES',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
    );
  }

  Widget _campo({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration:
            InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon),
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }
}