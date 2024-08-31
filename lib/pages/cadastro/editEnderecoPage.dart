import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/endereco_service.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class EditEnderecoPage extends StatefulWidget {
  final int enderecoId;

  EditEnderecoPage({required this.enderecoId});

  @override
  _EditEnderecoPageState createState() => _EditEnderecoPageState();
}

class _EditEnderecoPageState extends State<EditEnderecoPage> {
  final EnderecoService _enderecoService = EnderecoService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  late TextEditingController _ruaController;
  late TextEditingController _numeroController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ruaController = TextEditingController();
    _numeroController = TextEditingController();
    _bairroController = TextEditingController();
    _cidadeController = TextEditingController();
    _estadoController = TextEditingController();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      await _databaseHelper.connect();
      final endereco = await _enderecoService.getEnderecoPorId(widget.enderecoId);

      if (endereco != null) {
        setState(() {
          _ruaController.text = endereco['rua'] ?? '';
          _numeroController.text = endereco['numero'] ?? '';
          _bairroController.text = endereco['bairro'] ?? '';
          _cidadeController.text = endereco['cidade'] ?? '';
          _estadoController.text = endereco['estado'] ?? '';
        });
      } else {
        print('Endereço não encontrado');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _atualizarEndereco() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseHelper.connect();
      await _enderecoService.updateEndereco(
        widget.enderecoId,
        _ruaController.text,
        _numeroController.text,
        _bairroController.text,
        _cidadeController.text,
        _estadoController.text,
      );

      // Exibe o pop-up após a atualização bem-sucedida
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Endereço Atualizado'),
          content: Text('O endereço foi atualizado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Erro ao atualizar endereço: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar endereço: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _deletarEndereco() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseHelper.connect();
      await _enderecoService.deleteEndereco(widget.enderecoId);
      Navigator.pop(context, true);
    } catch (e) {
      print('Erro ao deletar endereço: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar endereço: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      await _databaseHelper.closeConnection();
    }
  }

  @override
  void dispose() {
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Endereço'),
        backgroundColor: Color.fromARGB(255, 255, 20, 20),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isLoading ? null : _deletarEndereco,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rua',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _ruaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Número',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _numeroController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Bairro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _bairroController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Cidade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _cidadeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Estado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _estadoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _atualizarEndereco,
                        child: Text(
                          'Atualizar Endereço',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 20, 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
