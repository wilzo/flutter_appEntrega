import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class EntregadorSelecaoPage extends StatefulWidget {
  @override
  _EntregadorSelecaoPageState createState() => _EntregadorSelecaoPageState();
}

class _EntregadorSelecaoPageState extends State<EntregadorSelecaoPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _entregadores = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listarEntregadores();
  }

  Future<void> _listarEntregadores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseHelper.connect();
      _entregadores = await _databaseHelper.listarEntregadores();
      setState(() {});
    } catch (e) {
      print('Erro ao listar entregadores: $e');
    } finally {
      await _databaseHelper.closeConnection();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selecionarEntregador(int id) {
    Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Entregador'),
        backgroundColor: Colors.red, // Cor padrão
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : _entregadores.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum entregador encontrado',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _entregadores.length,
                  itemBuilder: (context, index) {
                    final entregador = _entregadores[index];
                    final id = entregador['id_Entregador'];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Icon(
                          Icons.delivery_dining,
                          size: 50,
                          color: Colors.red,
                        ),
                        title: Text(
                          entregador['nome'] ?? 'Nome',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: Text('Telefone: ${entregador['telefone'] ?? 'Telefone'}'),
                        onTap: () {
                          _selecionarEntregador(id);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
