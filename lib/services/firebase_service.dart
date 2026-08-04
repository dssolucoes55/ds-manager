class DashboardService {

  static int totalClientes() {
    return ClienteService.clientes.length;
  }

  static int totalOrdens() {
    return OrdemServicoService.ordens.length;
  }

}