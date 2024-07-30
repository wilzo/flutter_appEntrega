import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/pages/cadastro/enderecoCadastroPage.dart';

import 'package:flutter_projeto/models/endereco_service.dart';
import 'package:flutter_projeto/models/cliente_service.dart';
import 'package:flutter_projeto/models/entrega_service.dart';
import 'package:flutter_projeto/models/entregador_service.dart';
import 'package:flutter_projeto/models/itens_service.dart';
import 'package:flutter_projeto/models/user_services.dart';
class EnderecoListagemPage extends StatefulWidget {
  @override
  _EnderecoListagemPageState createState() => _EnderecoListagemPageState();
}

class _EnderecoListagemPageState extends State<EnderecoListagemPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _enderecos = [];

  @override
  void initState() {
    super.initState();
    _listarEnderecos();
  }

  Future<void> _listarEnderecos() async {
    try {
      await _databaseHelper.connect();
      _enderecos = await _databaseHelper.listarEndereco();
      setState(() {});
    } catch (e) {
      print('Erro ao listar endereços: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  void _abrirCadastroEndereco() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EnderecoCadastroPage()),
    );

    if (resultado != null && resultado is String) {
      // Atualize a lista de endereços se necessário
      _listarEnderecos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Endereços Cadastrados'),
        backgroundColor: Colors.red, // Cor padrão
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _enderecos.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _enderecos.length,
                  itemBuilder: (context, index) {
                    final endereco = _enderecos[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.red,
                        ),
                        title: Text(
                          '${endereco['rua']} - ${endereco['bairro']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${endereco['cidade']}, ${endereco['estado']}',
                            ),
                          ],
                        ),
                        trailing: Text(
                          'ID: ${endereco['id']}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, endereco['id']);
                        },
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: ElevatedButton.icon(
              onPressed: _abrirCadastroEndereco,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Cor de fundo
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Adicionar Novo Endereço',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
