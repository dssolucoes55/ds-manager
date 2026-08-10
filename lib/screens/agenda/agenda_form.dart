import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/evento_agenda.dart';
import '../../services/agenda_service.dart';
import '../../services/cliente_service.dart';

class AgendaForm extends StatefulWidget {
  const AgendaForm({super.key});

  @override
  State<AgendaForm> createState() => _AgendaFormState();
}

class _AgendaFormState extends State<AgendaForm> {
  String? _clienteSelecionadoId;

  String _tipo = 'Visita';
  String _status = 'Agendado';

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (data == null) return;

    setState(() {
      _dataSelecionada = data;
    });
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );

    if (hora == null) return;

    setState(() {
      _horaSelecionada = hora;
    });
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

    final dataCompleta = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    setState(() {
      _salvando = true;
    });

    try {
      final evento = EventoAgenda(
        id: '',
        titulo: titulo,
        descricao: descricao,
        clienteId: cliente.id,
        clienteNome: cliente.nome,
        data: dataCompleta,
        tipo: _tipo,
        status: _status,
        observacoes:
            _observacoesController.text.trim(),
      );

      await AgendaService.adicionar(evento);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao salvar compromisso: $erro',
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

  String _formatarData(DateTime data) {
    final dia =
        data.day.toString().padLeft(2, '0');

    final mes =
        data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('Novo Compromisso'),
        backgroundColor:
            const Color(0xFFE30613),
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

          final clientes =
              snapshot.data ?? [];

          return ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                initialValue:
                    _clienteSelecionadoId,
                isExpanded: true,
                decoration:
                    const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon:
                      Icon(Icons.business),
                  border:
                      OutlineInputBorder(),
                ),
                items: clientes.map((cliente) {
                  return DropdownMenuItem<String>(
                    value: cliente.id,
                    child: Text(
                      cliente.nome,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _clienteSelecionadoId =
                        value;
                  });
                },
              ),

              const SizedBox(height: 18),

              TextField(
                controller:
                    _tituloController,
                decoration:
                    const InputDecoration(
                  labelText: 'Título',
                  prefixIcon:
                      Icon(Icons.title),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller:
                    _descricaoController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  prefixIcon:
                      Icon(Icons.description),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Tipo de compromisso',
                  prefixIcon:
                      Icon(Icons.event_note),
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Visita',
                    child: Text('Visita'),
                  ),
                  DropdownMenuItem(
                    value: 'Serviço',
                    child: Text('Serviço'),
                  ),
                  DropdownMenuItem(
                    value: 'Vistoria',
                    child: Text('Vistoria'),
                  ),
                  DropdownMenuItem(
                    value: 'Reunião',
                    child: Text('Reunião'),
                  ),
                  DropdownMenuItem(
                    value: 'Retorno',
                    child: Text('Retorno'),
                  ),
                  DropdownMenuItem(
                    value: 'Outro',
                    child: Text('Outro'),
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _selecionarData,
                      icon: const Icon(
                        Icons.calendar_today,
                      ),
                      label: Text(
                        _formatarData(
                          _dataSelecionada,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _selecionarHora,
                      icon: const Icon(
                        Icons.access_time,
                      ),
                      label: Text(
                        _horaSelecionada.format(
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration:
                    const InputDecoration(
                  labelText: 'Status',
                  prefixIcon:
                      Icon(Icons.flag_outlined),
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Agendado',
                    child: Text('Agendado'),
                  ),
                  DropdownMenuItem(
                    value: 'Confirmado',
                    child: Text('Confirmado'),
                  ),
                  DropdownMenuItem(
                    value: 'Concluído',
                    child: Text('Concluído'),
                  ),
                  DropdownMenuItem(
                    value: 'Cancelado',
                    child: Text('Cancelado'),
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
                decoration:
                    const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                  prefixIcon:
                      Icon(Icons.notes),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      clientes.isEmpty ||
                              _salvando
                          ? null
                          : () =>
                              _salvar(clientes),
                  style:
                      ElevatedButton.styleFrom(
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
                            strokeWidth: 2,
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
                        : 'SALVAR COMPROMISSO',
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