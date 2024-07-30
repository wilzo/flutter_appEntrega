import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

import 'package:flutter_projeto/models/endereco_service.dart';
import 'package:flutter_projeto/models/cliente_service.dart';
import 'package:flutter_projeto/models/entrega_service.dart';
import 'package:flutter_projeto/models/entregador_service.dart';
import 'package:flutter_projeto/models/itens_service.dart';
import 'package:flutter_projeto/models/user_services.dart';
class EnderecoCadastroPage extends StatefulWidget {
  @override
  _EnderecoCadastroPageState createState() => _EnderecoCadastroPageState();
}

class _EnderecoCadastroPageState extends State<EnderecoCadastroPage> {
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  bool _isLoading = false;

  void _cadastrarEndereco() async {
    setState(() {
      _isLoading = true;
    });

    String rua = _ruaController.text.trim();
    String numero = _numeroController.text.trim();
    String bairro = _bairroController.text.trim();
    String cidade = _cidadeController.text.trim();
    String cep = _cepController.text.trim();

    if (rua.isEmpty || numero.isEmpty || bairro.isEmpty || cidade.isEmpty || cep.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }

    try {
      await _databaseHelper.createEnderecoTable();

      bool enderecoExiste = await _databaseHelper.verificarEnderecoExiste(rua, numero, bairro, cidade, cep);
      if (enderecoExiste) {
        bool criarMesmoAssim = await _mostrarPopupEnderecoExistente();
        if (!criarMesmoAssim) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      await _databaseHelper.createEndereco(rua, numero, bairro, cidade, cep);
      Navigator.pop(context, '$rua, $numero, $bairro, $cidade, $cep');
    } catch (e) {
      print('Erro ao cadastrar endereço: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar endereço: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _mostrarPopupEnderecoExistente() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Endereço já cadastrado'),
          content: Text('Este endereço já está cadastrado. Deseja criar mesmo assim?'),
          actions: [
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Endereço'),
        backgroundColor: Colors.red, // Cor padrão
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField('Rua', _ruaController, 'Rua'),
              const SizedBox(height: 15), // Ajuste o espaçamento aqui
              _buildTextField('Número', _numeroController, 'Número'),
              const SizedBox(height: 15), // Ajuste o espaçamento aqui
              _buildTextField('Bairro', _bairroController, 'Bairro'),
              const SizedBox(height: 15), // Ajuste o espaçamento aqui
              _buildTextField('Cidade', _cidadeController, 'Cidade'),
              const SizedBox(height: 15), // Ajuste o espaçamento aqui
              _buildTextField('CEP', _cepController, 'CEP'),
              const SizedBox(height: 30), // Ajuste o espaçamento aqui
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cadastrarEndereco,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cor de fundo
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

  Widget _buildTextField(String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.red, // Cor padrão
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
