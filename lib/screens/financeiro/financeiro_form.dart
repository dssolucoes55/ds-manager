import 'package:flutter/material.dart';

import '../../models/lancamento_financeiro.dart';
import '../../services/financeiro_service.dart';

class FinanceiroForm extends StatefulWidget {
  const FinanceiroForm({super.key});

  @override
  State<FinanceiroForm> createState() => _FinanceiroFormState();
}

class _FinanceiroFormState extends State<FinanceiroForm> {
  String _tipo = 'Receita';
  String _status = 'Pendente';

  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _categoriaController.dispose();
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();
    final categoria = _categoriaController.text.trim();
    final valorTexto =
        _valorController.text.trim().replaceAll(',', '.');

    if (descricao.isEmpty ||
        categoria.isEmpty ||
        valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha descrição, categoria e valor.',
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

    setState(() {
      _salvando = true;
    });

    try {
      final lancamento = LancamentoFinanceiro(
        id: '',
        tipo: _tipo,
        descricao: descricao,
        categoria: categoria,
        valor: valor,
        status: _status,
        data: DateTime.now(),
        observacoes:
            _observacoesController.text.trim(),
      );

      await FinanceiroService.adicionar(
        lancamento,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar lançamento: $erro',
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
        title: const Text(
          'Novo Lançamento',
        ),
        backgroundColor:
            const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              prefixIcon:
                  Icon(Icons.swap_vert),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Receita',
                child: Text('Receita'),
              ),
              DropdownMenuItem(
                value: 'Despesa',
                child: Text('Despesa'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _tipo = value;
              });
            },
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              prefixIcon:
                  Icon(Icons.description_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _categoriaController,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              prefixIcon:
                  Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _valorController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
              prefixIcon:
                  Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon:
                  Icon(Icons.flag_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Pendente',
                child: Text('Pendente'),
              ),
              DropdownMenuItem(
                value: 'Pago',
                child: Text('Pago'),
              ),
              DropdownMenuItem(
                value: 'Recebido',
                child: Text('Recebido'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _status = value;
              });
            },
          ),

          const SizedBox(height: 18),

          TextField(
            controller:
                _observacoesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Observações',
              alignLabelWithHint: true,
              prefixIcon:
                  Icon(Icons.notes_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _salvando ? null : _salvar,
              style:
                  ElevatedButton.styleFrom(
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
                    : 'SALVAR LANÇAMENTO',
              ),
            ),
          ),
        ],
      ),
    );
  }
}