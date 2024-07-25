import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/pages/cadastro/editEntregadorPage.dart';

class EntregadorListagemPage extends StatefulWidget {
  @override
  _EntregadorListagemPageState createState() => _EntregadorListagemPageState();
}

class _EntregadorListagemPageState extends State<EntregadorListagemPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _entregadores = [];

  @override
  void initState() {
    super.initState();
    _listarEntregadores();
  }

  Future<void> _listarEntregadores() async {
    try {
      await _databaseHelper.connect();
      _entregadores = await _databaseHelper.listarEntregadores();
      _entregadores.forEach((entregador) {
        if (entregador['id_Entregador'] == null) {
          print(
              'Erro: ID do entregador é nulo para o entregador ${entregador['nome']}');
        }
      });
      setState(() {});
    } catch (e) {
      print('Erro ao listar entregadores: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _deletarEntregador(int id) async {
    try {
      await _databaseHelper.connect();
      await _databaseHelper.deleteEntregador(id);
      await _listarEntregadores(); // Atualiza a lista após deletar
    } catch (e) {
      print('Erro ao deletar entregador: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _editarEntregador(int id) async {
    // Lógica para editar entregador
    // Navegar para uma página de edição ou abrir um diálogo para editar os dados do entregador
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregadores Cadastrados'),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _entregadores.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF0000), // Cor igual ao padrão
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _entregadores.length,
              itemBuilder: (context, index) {
                final entregador = _entregadores[index];
                final id = entregador['id_Entregador'];
                print('Entregador ID: $id'); // Verificação para depuração

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
                      Icons.local_shipping,
                      size: 50,
                      color: Color(0xFFFF0000), // Cor igual ao padrão
                    ),
                    title: Text(
                      entregador['nome'] ?? 'Nome',
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
                            Text(
                                'Telefone: ${entregador['telefone'] ?? 'Telefone'}'),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.card_membership,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text('CNH: ${entregador['cnh'] ?? 'CNH'}'),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text(
                                'Veículo: ${entregador['veiculo'] ?? 'Veículo'}'),
                          ],
                        ),
                      ],
                    ),
                    trailing: id != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditEntregadorPage(entregadorId: id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Chama o método de deletar entregador
                                  _deletarEntregador(id);
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
