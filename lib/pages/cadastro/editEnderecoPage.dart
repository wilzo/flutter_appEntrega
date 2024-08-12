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
      Navigator.pop(context, true);
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isLoading ? null : _deletarEndereco,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _ruaController,
                    decoration: InputDecoration(labelText: 'Rua'),
                  ),
                  TextField(
                    controller: _numeroController,
                    decoration: InputDecoration(labelText: 'Número'),
                  ),
                  TextField(
                    controller: _bairroController,
                    decoration: InputDecoration(labelText: 'Bairro'),
                  ),
                  TextField(
                    controller: _cidadeController,
                    decoration: InputDecoration(labelText: 'Cidade'),
                  ),
                  TextField(
                    controller: _estadoController,
                    decoration: InputDecoration(labelText: 'Estado'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _atualizarEndereco,
                    child: Text('Atualizar Endereço'),
                  ),
                ],
              ),
      ),
    );
  }
}
