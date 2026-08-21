import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../models/ordem_servico.dart';

class FinalizarOrdemServicoDialog extends StatefulWidget {
  final OrdemServico ordem;

  const FinalizarOrdemServicoDialog({
    super.key,
    required this.ordem,
  });

  @override
  State<FinalizarOrdemServicoDialog> createState() =>
      _FinalizarOrdemServicoDialogState();
}

class _FinalizarOrdemServicoDialogState
    extends State<FinalizarOrdemServicoDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _observacoesController;
  late final TextEditingController _nomeTecnicoController;
  late final TextEditingController _nomeClienteController;
  late final SignatureController _assinaturaTecnicoController;
  late final SignatureController _assinaturaClienteController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _observacoesController = TextEditingController(
      text: widget.ordem.observacoes,
    );
    _nomeTecnicoController = TextEditingController(
      text: widget.ordem.nomeAssinanteTecnico.isNotEmpty
          ? widget.ordem.nomeAssinanteTecnico
          : widget.ordem.tecnico,
    );
    _nomeClienteController = TextEditingController(
      text: widget.ordem.nomeAssinanteCliente,
    );
    _assinaturaTecnicoController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _assinaturaClienteController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    _nomeTecnicoController.dispose();
    _nomeClienteController.dispose();
    _assinaturaTecnicoController.dispose();
    _assinaturaClienteController.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_assinaturaTecnicoController.isEmpty) {
      _mostrarErro('Solicite a assinatura do técnico.');
      return;
    }
    if (_assinaturaClienteController.isEmpty) {
      _mostrarErro('Solicite a assinatura do cliente ou responsável.');
      return;
    }

    setState(() => _salvando = true);

    try {
      final Uint8List? assinaturaTecnico =
          await _assinaturaTecnicoController.toPngBytes(
        width: 600,
        height: 250,
      );
      final Uint8List? assinaturaCliente =
          await _assinaturaClienteController.toPngBytes(
        width: 600,
        height: 250,
      );

      if (assinaturaTecnico == null || assinaturaCliente == null) {
        _mostrarErro('Não foi possível processar as assinaturas.');
        return;
      }

      final ordemFinalizada = widget.ordem.copyWith(
        status: 'Concluída',
        observacoes: _observacoesController.text.trim(),
        nomeAssinanteTecnico: _nomeTecnicoController.text.trim(),
        nomeAssinanteCliente: _nomeClienteController.text.trim(),
        assinaturaTecnico: assinaturaTecnico,
        assinaturaCliente: assinaturaCliente,
        dataConclusao: DateTime.now(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(ordemFinalizada);
    } catch (erro) {
      _mostrarErro('Erro ao processar as assinaturas: $erro');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Finalizar Ordem de Serviço',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: _salvando
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  widget.ordem.numero,
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 24),

                _titulo('Serviço executado'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacoesController,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Serviço executado / observações finais',
                    hintText: 'Descreva o que o técnico realizou na OS',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Descreva o serviço que foi executado.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),

                _titulo('Identificação e assinatura do técnico'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeTecnicoController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo do técnico',
                    hintText: 'Digite o nome de quem assinou',
                    prefixIcon: Icon(Icons.engineering_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Informe o nome do técnico.'
                      : null,
                ),
                const SizedBox(height: 14),
                _campoAssinatura(
                  controller: _assinaturaTecnicoController,
                  texto: 'Assine com o dedo dentro do espaço abaixo',
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),

                _titulo('Identificação e assinatura do cliente'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeClienteController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo do cliente ou responsável',
                    hintText: 'Digite o nome de quem assinou',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Informe o nome do cliente ou responsável.'
                      : null,
                ),
                const SizedBox(height: 14),
                _campoAssinatura(
                  controller: _assinaturaClienteController,
                  texto: 'Peça ao cliente para assinar neste espaço',
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _salvando
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _salvando ? null : _finalizar,
                        icon: _salvando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _salvando
                              ? 'Finalizando...'
                              : 'Finalizar serviço',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE30613),
      ),
    );
  }

  Widget _campoAssinatura({
    required SignatureController controller,
    required String texto,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Signature(
              controller: controller,
              height: 180,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _salvando
                ? null
                : () {
                    controller.clear();
                    setState(() {});
                  },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Limpar assinatura'),
          ),
        ),
      ],
    );
  }
}
