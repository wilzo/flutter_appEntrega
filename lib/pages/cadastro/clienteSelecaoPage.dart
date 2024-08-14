import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/cliente_service.dart';

class ClienteSelecaoPage extends StatefulWidget {
  @override
  _ClienteSelecaoPageState createState() => _ClienteSelecaoPageState();
}

class _ClienteSelecaoPageState extends State<ClienteSelecaoPage> {
  final ClienteService _clienteService = ClienteService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _listarClientes();
  }

  Future<void> _listarClientes() async {
    try {
      await _clienteService.connect();
      _clientes = await _clienteService.listarClientes('');
      setState(() {});
    } catch (e) {
      print('Erro ao listar clientes: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  void _selecionarCliente(String nome, int id) {
    Navigator.pop(context, {
      'nome': nome,
      'id': id,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Cliente'),
        backgroundColor: Color(0xFFFF0000),
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
                color: Color(0xFFFF0000),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                final id = cliente['id'];
                final nome = cliente['nome'] ?? 'Nome';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFFFF0000),
                    ),
                    title: Text(
                      nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF0000),
                      ),
                    ),
                    subtitle: Text('Telefone: ${cliente['telefone'] ?? 'Telefone'}'),
                    trailing: IconButton(
                      icon: Icon(Icons.check, color: Color(0xFFFF0000)),
                        onPressed: () {
                            Navigator.pop(
                              context,
                              {
                                'id': id, // Adiciona o ID do endereço aqui
                                'nome': nome,
                              },
                            ); // Retorna o nome da rua e o número
                          }, // R}                ),
                  ),
                  )
                );
              },
            ),
    );
  }
}
