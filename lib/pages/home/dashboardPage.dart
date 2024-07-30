import 'package:flutter/material.dart';
import 'package:flutter_projeto/pages/cadastro/clienteCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregaCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/clienteListagemPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorListagemPage.dart';

class Delivery {
  final String id;
  final String descricao;
  final DateTime data;
  final String status;

  Delivery({
    required this.id,
    required this.descricao,
    required this.data,
    required this.status,
  });
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showClienteOptions = false;
  bool _showEntregadorOptions = false;
  bool _showEntregaOptions = false;

  final List<Delivery> deliveries = [
    Delivery(id: '1', descricao: '1 Tinta exterior branco 18lt', data: DateTime.now(), status: 'Pendente'),
    Delivery(id: '2', descricao: '1 Rolo 23cm atlas', data: DateTime.now().add(Duration(days: 1)), status: 'Futura'),
    Delivery(id: '3', descricao: '2 lixas ferro 180, 5 trinchas 395', data: DateTime.now().subtract(Duration(days: 1)), status: 'Concluída'),
  ];

  void _toggleClienteOptions() {
    setState(() {
      _showClienteOptions = !_showClienteOptions;
    });
  }

  void _toggleEntregadorOptions() {
    setState(() {
      _showEntregadorOptions = !_showEntregadorOptions;
    });
  }

  void _toggleEntregaOptions() {
    setState(() {
      _showEntregaOptions = !_showEntregaOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/entrega.jpg',
                      height: 50, width: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'ENTREGAJÁ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: const Text('Entregas'),
              onTap: () {
                _toggleEntregaOptions();
              },
            ),
            if (_showEntregaOptions) ...[
              ListTile(
                title: const Text('Adicionar Entrega'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EntregaCadastroPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Entregadores'),
              onTap: _toggleEntregadorOptions,
            ),
            if (_showEntregadorOptions) ...[
              ListTile(
                title: const Text('Cadastrar Entregador'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EntregadorCadastroPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
             
              ListTile(
                title: const Text('Listar Entregadores'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EntregadorListagemPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.people),
              title: const Text('Clientes'),
              onTap: _toggleClienteOptions,
            ),
            if (_showClienteOptions) ...[
              ListTile(
                title: const Text('Cadastrar Cliente'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClienteCadastroPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
              
              ListTile(
                title: const Text('Listar Clientes'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClienteListagemPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Organize suas entregas'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar entregas por cliente',
                prefixIcon: Icon(Icons.search, color: Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDeliveryColumn('Entregas Pendentes',
                      Colors.red.shade800, Colors.red.shade300, 'Pendente'),
                  _buildDeliveryColumn('Entregas Futuras',
                      Colors.orange.shade800, Colors.orange.shade300, 'Futura'),
                  _buildDeliveryColumn('Entregas Concluídas',
                      Colors.green.shade800, Colors.green.shade300, 'Concluída'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryColumn(
      String title, Color headerColor, Color cardColor, String statusFilter) {
    final filteredDeliveries = deliveries
        .where((delivery) => delivery.status == statusFilter)
        .toList();

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: headerColor,
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: cardColor,
              child: ListView.builder(
                itemCount: filteredDeliveries.length,
                itemBuilder: (context, index) {
                  final delivery = filteredDeliveries[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('Entrega ${delivery.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(delivery.descricao),
                          SizedBox(height: 5),
                          Text('Data: ${delivery.data.toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(delivery.status,
                              style: TextStyle(
                                color: delivery.status == 'Concluída'
                                    ? Colors.green
                                    : Colors.red,
                              )),
                          Icon(
                            delivery.status == 'Concluída'
                                ? Icons.check_circle
                                : Icons.access_time,
                            color: delivery.status == 'Concluída'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
