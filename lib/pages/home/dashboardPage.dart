import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
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
                  Image.asset('assets/images/entrega.jpg', height: 50, width: 50),
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
              onTap: () {},
            ),
            ListTile(
              title: const Text('Adicionar Entregas'),
              onTap: () {},
              contentPadding: EdgeInsets.only(left: 50.0),
            ),
            ListTile(
              title: const Text('Excluir Entregas'),
              onTap: () {},
              contentPadding: EdgeInsets.only(left: 50.0),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Entregadores'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: const Text('Clientes'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: const Text('Mapa de Entregas'),
              onTap: () {},
            ),
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
                  _buildDeliveryColumn('Entregas Pendentes', Colors.red.shade800, Colors.red.shade300),
                  _buildDeliveryColumn('Entregas Futuras', Colors.orange.shade800, Colors.orange.shade300),
                  _buildDeliveryColumn('Entregas Concluídas', Colors.green.shade800, Colors.green.shade300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryColumn(String title, Color headerColor, Color cardColor) {
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
                itemCount: 3, // Este número pode ser dinâmico, conforme necessário
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('Entrega #$index'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1 Tinta exterior branco 18lt,\n1 Rolo 23cm atlas, 2 lixas ferro 180, 5 trinchas 395'),
                          SizedBox(height: 5),
                          Text('Data: 01/09/2024'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Entrega concluída', style: TextStyle(color: Colors.green)),
                          Icon(Icons.check_circle, color: Colors.green),
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
