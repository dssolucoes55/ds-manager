import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DS Soluções"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _menu(Icons.people, "Clientes"),
            _menu(Icons.assignment, "Ordens de Serviço"),
            _menu(Icons.request_quote, "Orçamentos"),
            _menu(Icons.description, "Laudos"),
            _menu(Icons.attach_money, "Financeiro"),
            _menu(Icons.settings, "Configurações"),
          ],
        ),
      ),
    );
  }

  Widget _menu(IconData icon, String titulo) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.blue),
            const SizedBox(height: 15),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}