import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

import 'package:flutter_projeto/models/endereco_service.dart';
import 'package:flutter_projeto/models/cliente_service.dart';
import 'package:flutter_projeto/models/entrega_service.dart';
import 'package:flutter_projeto/models/entregador_service.dart';
import 'package:flutter_projeto/models/itens_service.dart';
import 'package:flutter_projeto/models/user_services.dart';
class ClienteSelecaoPage extends StatefulWidget {
  @override
  _ClienteSelecaoPageState createState() => _ClienteSelecaoPageState();
}

class _ClienteSelecaoPageState extends State<ClienteSelecaoPage> {
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

  void _selecionarCliente(int clienteId) {
    Navigator.pop(context, clienteId);
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
                      color: Color(0xFFFF0000),
                    ),
                    title: Text(
                      cliente['nome'] ?? 'Nome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF0000),
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
                    onTap: () => _selecionarCliente(id),
                  ),
                );
              },
            ),
    );
  }
}
