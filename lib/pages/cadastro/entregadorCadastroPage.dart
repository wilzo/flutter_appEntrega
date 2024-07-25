import 'package:flutter/material.dart';
import 'package:flutter_projeto/pages/home/dashboardPage.dart';
import 'package:flutter_projeto/pages/cadastro/clienteCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregaCadastroPage.dart';
import 'package:flutter_projeto/models/databaseHelper.dart'; // Adicione esta importação

class EntregadorCadastroPage extends StatefulWidget {
  @override
  _EntregadorCadastroPageState createState() => _EntregadorCadastroPageState();
}

class _EntregadorCadastroPageState extends State<EntregadorCadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _veiculoController = TextEditingController();
  bool _isLoading = false;

  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Instanciar o DatabaseHelper

  bool _showClienteOptions = false;
  bool _showEntregadorOptions = false;
  bool _showEntregaOptions = false;

  void _toggleClienteOptions() {
    setState(() {
      _showClienteOptions = !_showClienteOptions;
    });
  }

  void _toggleEntregadorOptions() {
    setState(() {
      _showEntregadorOptions = !_showEntregadorOptions;
    });
  }

  void _toggleEntregaOptions() {
    setState(() {
      _showEntregaOptions = !_showEntregaOptions;
    });
  }

  void _cadastrarEntregador() async {
    setState(() {
      _isLoading = true;
    });

    String nome = _nomeController.text.trim();
    String telefone = _telefoneController.text.trim();
    String email = _emailController.text.trim();
    String veiculo = _veiculoController.text.trim();

    if (nome.isEmpty || telefone.isEmpty || email.isEmpty || veiculo.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }

    try {
      await _databaseHelper.createEntregadorTable();
      await _databaseHelper.cadastrarEntregador(nome, telefone, email, veiculo); // Chame o método para cadastrar entregador
      Navigator.pop(context); // Navegar de volta ou para a página desejada
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
                  Image.asset('assets/images/entrega.jpg', height: 50, width: 50),
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
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: const Text('Entregas'),
              onTap: _toggleEntregaOptions,
            ),
            if (_showEntregaOptions) ...[
              ListTile(
                title: const Text('Adicionar Entrega'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EntregaCadastroPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
              ListTile(
                title: const Text('Excluir Entregas'),
                onTap: () {},
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Entregadores'),
              onTap: _toggleEntregadorOptions,
            ),
            if (_showEntregadorOptions) ...[
              ListTile(
                title: const Text('Cadastrar Entregador'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EntregadorCadastroPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
              ListTile(
                title: const Text('Excluir Entregador'),
                onTap: () {
                  // Navegar para a tela de excluir entregador
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
              ListTile(
                title: const Text('Listar Entregadores'),
                onTap: () {
                  // Navegar para a tela de listar entregadores
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.people),
              title: const Text('Clientes'),
              onTap: _toggleClienteOptions,
            ),
            if (_showClienteOptions) ...[
              ListTile(
                title: const Text('Cadastrar Cliente'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClienteCadastroPage()),
                  );
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
              ListTile(
                title: const Text('Excluir Cliente'),
                onTap: () {
                  // Navegar para a tela de excluir cliente
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
              ListTile(
                title: const Text('Listar Clientes'),
                onTap: () {
                  // Navegar para a tela de listar clientes
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.map),
              title: const Text('Mapa de Entregas'),
              onTap: () {},
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
                        'ENTREGA JA',
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
              _buildTextField(Icons.person, 'Nome', _nomeController, 'Nome Completo'),
              const SizedBox(height: 20),
              _buildTextField(Icons.phone, 'Telefone', _telefoneController, 'Telefone'),
              const SizedBox(height: 20),
              _buildTextField(Icons.email, 'Email', _emailController, 'email@email.com'),
              const SizedBox(height: 20),
              _buildTextField(Icons.directions_car, 'Veículo', _veiculoController, 'Veículo'),
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

  Widget _buildTextField(IconData icon, String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Color(0xFFFF0000)),
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
