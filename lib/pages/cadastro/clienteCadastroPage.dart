import 'package:flutter/material.dart';
import 'package:flutter_projeto/pages/home/dashboardPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorCadastroPage.dart'; 
import 'package:flutter_projeto/pages/cadastro/entregaCadastroPage.dart';

class ClienteCadastroPage extends StatefulWidget {
  @override
  _ClienteCadastroPageState createState() => _ClienteCadastroPageState();
}

class _ClienteCadastroPageState extends State<ClienteCadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  bool _isLoading = false;

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

  void _cadastrarCliente() async {
    setState(() {
      _isLoading = true;
    });

    String nome = _nomeController.text.trim();
    String telefone = _telefoneController.text.trim();
    String email = _emailController.text.trim();
    String endereco = _enderecoController.text.trim();
    String bairro = _bairroController.text.trim();
    String cidade = _cidadeController.text.trim();

    if (nome.isEmpty || telefone.isEmpty || email.isEmpty || endereco.isEmpty || bairro.isEmpty || cidade.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }

    try {
      // Chame o método para cadastrar cliente aqui
      // Exemplo: await _databaseHelper.cadastrarCliente(nome, telefone, email, endereco, bairro, cidade);

      // Navegar para uma página de sucesso ou voltar para a página anterior
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao cadastrar cliente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar cliente: $e')),
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
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/entrega.jpg', height: 50, width: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'ENTREGAJÁ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
              onTap: () {
                // Navegar para o mapa de entregas
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
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
                        'CADASTRE SEUS CLIENTES',
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
              _buildTextField('Nome', _nomeController, 'Nome Completo'),
              const SizedBox(height: 20),
              _buildTextField('Telefone', _telefoneController, 'Telefone'),
              const SizedBox(height: 20),
              _buildTextField('Email', _emailController, 'email@email.com'),
              const SizedBox(height: 20),
              _buildTextField('Endereço', _enderecoController, 'Rua, Número'),
              const SizedBox(height: 20),
              _buildTextField('Bairro', _bairroController, 'Bairro'),
              const SizedBox(height: 20),
              _buildTextField('Cidade', _cidadeController, 'Cidade'),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cadastrarCliente,
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

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
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
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
