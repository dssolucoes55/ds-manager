import '../models/cliente.dart';

class ClienteService {
  static final List<Cliente> clientes = [
    Cliente(
      id: '1',
      nome: 'Condomínio Leonardo da Vinci',
      tipo: 'Condomínio',
      responsavel: 'Administração',
      telefone: '(85) 99999-9999',
      whatsapp: '(85) 99999-9999',
      email: 'administracao@condominio.com',
    ),
    Cliente(
      id: '2',
      nome: 'Shopping Central',
      tipo: 'Empresa',
      responsavel: 'Setor de Manutenção',
      telefone: '(85) 98888-8888',
      whatsapp: '(85) 98888-8888',
      email: 'manutencao@shopping.com',
    ),
    Cliente(
      id: '3',
      nome: 'Empresa ABC',
      tipo: 'Empresa',
      responsavel: 'Carlos',
      telefone: '(85) 97777-7777',
      whatsapp: '(85) 97777-7777',
      email: 'carlos@empresaabc.com',
    ),
  ];

  static void adicionar(Cliente cliente) {
    clientes.add(cliente);
  }

  static void atualizar(int index, Cliente cliente) {
    clientes[index] = cliente;
  }

  static void remover(Cliente cliente) {
    clientes.remove(cliente);
  }

  static String gerarId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}