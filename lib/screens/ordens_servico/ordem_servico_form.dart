import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/ordem_servico.dart';
import '../../services/agenda_service.dart';
import '../../services/cliente_service.dart';
import '../../services/ordem_servico_service.dart';

class OrdemServicoForm extends StatefulWidget {
  final OrdemServico? ordem;

  const OrdemServicoForm({super.key, this.ordem});

  @override
  State<OrdemServicoForm> createState() => _OrdemServicoFormState();
}

class _OrdemServicoFormState extends State<OrdemServicoForm> {
  String? _clienteSelecionadoId;
  final _tecnicoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacaoController = TextEditingController();
  String _prioridade = 'Normal';
  DateTime? _dataAgendamento;
  bool _salvando = false;

  bool get _editando => widget.ordem != null;

  @override
  void initState() {
    super.initState();
    final ordem = widget.ordem;
    if (ordem != null) {
      _clienteSelecionadoId = ordem.clienteId;
      _tecnicoController.text = ordem.tecnico;
      _descricaoController.text = ordem.descricao;
      _observacaoController.text = ordem.observacoes;
      _prioridade = ordem.prioridade;
      _dataAgendamento = ordem.dataAgendamento;
    }
  }

  @override
  void dispose() {
    _tecnicoController.dispose();
    _descricaoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarAgendamento() async {
    final agora = DateTime.now();
    final inicial = _dataAgendamento ?? agora;
    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(agora.year - 1),
      lastDate: DateTime(agora.year + 10),
    );
    if (data == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
    );
    if (hora == null) return;
    setState(() {
      _dataAgendamento = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  String _formatarAgendamento(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  Future<void> _salvar(List<Cliente> clientes) async {
    if (_clienteSelecionadoId == null ||
        _descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios.')),
      );
      return;
    }

    final cliente = clientes.firstWhere(
      (cliente) => cliente.id == _clienteSelecionadoId,
    );
    setState(() => _salvando = true);

    try {
      if (_editando) {
        final atualizada = widget.ordem!.copyWith(
          clienteId: cliente.id,
          clienteNome: cliente.nome,
          tecnico: _tecnicoController.text.trim(),
          descricao: _descricaoController.text.trim(),
          prioridade: _prioridade,
          observacoes: _observacaoController.text.trim(),
          dataAgendamento: _dataAgendamento,
          removerAgendamento: _dataAgendamento == null,
        );
        await OrdemServicoService.atualizar(atualizada);
        await AgendaService.sincronizarOrdemServico(atualizada);
      } else {
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
          dataAgendamento: _dataAgendamento,
        );
        final salva = await OrdemServicoService.adicionar(ordem);
        await AgendaService.sincronizarOrdemServico(salva);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao salvar Ordem de Serviço: $erro'),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço'),
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: ClienteService.observarClientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar clientes:\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final clientes = snapshot.data ?? [];
          final clienteValido = clientes.any(
            (cliente) => cliente.id == _clienteSelecionadoId,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                initialValue: clienteValido ? _clienteSelecionadoId : null,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                items: clientes.map((cliente) {
                  return DropdownMenuItem(value: cliente.id, child: Text(cliente.nome));
                }).toList(),
                onChanged: (value) => setState(() => _clienteSelecionadoId = value),
              ),
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
                  DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                  DropdownMenuItem(value: 'Urgente', child: Text('Urgente')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _prioridade = value);
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
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _selecionarAgendamento,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _dataAgendamento == null
                      ? 'Agendar data e horário'
                      : _formatarAgendamento(_dataAgendamento!),
                ),
              ),
              if (_dataAgendamento != null)
                TextButton.icon(
                  onPressed: () => setState(() => _dataAgendamento = null),
                  icon: const Icon(Icons.event_busy),
                  label: const Text('Remover agendamento'),
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
                        : _editando
                            ? 'SALVAR ALTERAÇÕES'
                            : 'SALVAR',
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
