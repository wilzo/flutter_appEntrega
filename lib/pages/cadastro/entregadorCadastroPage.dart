import 'package:flutter/material.dart';
import 'package:flutter_projeto/pages/home/dashboardPage.dart';
import 'package:flutter_projeto/pages/cadastro/clienteCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregaCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/clienteListagemPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorCadastroPage.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

import 'package:flutter_projeto/pages/cadastro/entregadorListagemPage.dart';
import 'package:flutter_projeto/models/entregador_service.dart';

class EntregadorCadastroPage extends StatefulWidget {
  @override
  _EntregadorCadastroPageState createState() => _EntregadorCadastroPageState();
}

class _EntregadorCadastroPageState extends State<EntregadorCadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cnhController = TextEditingController();
  final TextEditingController _veiculoController = TextEditingController();
  bool _isLoading = false;
  final EntregadorService _entregadorService = EntregadorService();

  bool validarCNH(String cnh) {
  // Verifica se a CNH tem exatamente 11 dígitos e é composta apenas por números
  final RegExp regex = RegExp(r'^\d{11}$');
  return regex.hasMatch(cnh);
}


  bool validarTelefone(String telefone) {
    final telefoneRegex = RegExp(
      r'^\+?[0-9]{10,15}$', // Ajuste conforme o formato esperado
    );
    return telefoneRegex.hasMatch(telefone);
  }

  void _cadastrarEntregador() async {
    setState(() {
      _isLoading = true;
    });

    String nome = _nomeController.text.trim();
    String telefone = _telefoneController.text.trim();
    String cnh = _cnhController.text.trim();
    String veiculo = _veiculoController.text.trim();

    // Verificar se algum dos campos está vazio
    if (nome.isEmpty || telefone.isEmpty || cnh.isEmpty || veiculo.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }

    // Validar o telefone
    if (!validarTelefone(telefone)) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telefone inválido')),
      );
      return;
    }

    // Validação da CNH
    if (!validarCNH(cnh)) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CNH inválida')),
      );
      return;
    }

    try {
      await _entregadorService.createEntregadorTable();
      await _entregadorService.cadastrarEntregador(
          nome, telefone, cnh, veiculo);

      // Exibir pop-up de confirmação
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sucesso'),
            content: Text('Entregador cadastrado com sucesso!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o pop-up
                  Navigator.pop(context,
                      true); // Retorna à tela anterior e atualiza a lista
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Erro ao cadastrar entregador: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar entregador: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 17, 0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/entrega.jpg',
                      height: 50, width: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'ENTREGA JÁ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: const Text('Tela principal'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.local_shipping),
              title: const Text('Entregas'),
              children: <Widget>[
                ListTile(
                  title: const Text('Adicionar Entrega'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EntregaCadastroPage()),
                    );
                  },
                  contentPadding: EdgeInsets.only(left: 50.0),
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.person),
              title: const Text('Entregadores'),
              children: <Widget>[
                
                ListTile(
                  title: const Text('Listar Entregadores'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EntregadorListagemPage()),
                    );
                  },
                  contentPadding: EdgeInsets.only(left: 50.0),
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.people),
              title: const Text('Clientes'),
              children: <Widget>[
                               ListTile(
                  title: const Text('Listar Clientes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClienteListagemPage()),
                    );
                  },
                  contentPadding: EdgeInsets.only(left: 50.0),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Cadastrar Entregador'),
        backgroundColor: Colors.red,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22, // Tamanho da fonte do título
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/entrega.jpg',
                    height: 200,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const Text(
                        'ENTREGA JÁ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFF0000),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CADASTRE SEUS ENTREGADORES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFF0000),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildTextField(
                  Icons.person, 'Nome', _nomeController, 'Nome Completo'),
              const SizedBox(height: 20),
              _buildTextField(
                  Icons.phone, 'Telefone', _telefoneController, 'Telefone'),
              const SizedBox(height: 20),
              _buildTextField(
                  Icons.credit_card, 'CNH', _cnhController, 'Número da CNH'),
              const SizedBox(height: 20),
              _buildTextField(Icons.directions_car, 'Veículo',
                  _veiculoController, 'Veículo'),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cadastrarEntregador,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF0000),
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

  Widget _buildTextField(IconData icon, String label,
      TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Color(0xFFFF0000)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFFF0000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFFF0000)),
            ),
          ),
        ),
      ],
    );
  }
}
