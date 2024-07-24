import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class ClienteListagemPage extends StatefulWidget {
  @override
  _ClienteListagemPageState createState() => _ClienteListagemPageState();
}

class _ClienteListagemPageState extends State<ClienteListagemPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _listarClientes();
  }

  Future<void> _listarClientes() async {
    try {
      await _databaseHelper.connect();
      _clientes = await _databaseHelper.listarClientes();
      setState(() {});
    } catch (e) {
      print('Erro ao listar clientes: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _clientes.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF0000), // Cor igual ao padrão
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFFFF0000), // Cor igual ao padrão
                    ),
                    title: Text(
                      cliente['nome'] ?? 'Nome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF0000), // Cor igual ao padrão
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text('Telefone: ${cliente['telefone'] ?? 'Telefone'}'),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text('Email: ${cliente['email'] ?? 'Email'}'),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Endereço: ${cliente['rua'] ?? 'Rua'}, ${cliente['numero'] ?? 'Número'}, ${cliente['bairro'] ?? 'Bairro'}, ${cliente['cidade'] ?? 'Cidade'}, ${cliente['estado'] ?? 'Estado'}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      'ID: ${cliente['id']}',
                      style: TextStyle(
                        color: Color(0xFFFF0000), // Cor igual ao padrão
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
