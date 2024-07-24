import 'package:flutter/material.dart';
import 'enderecoListagemPage.dart'; // Importe a página de listagem de endereços
import 'package:flutter_projeto/models/databaseHelper.dart';

class ClienteCadastroPage extends StatefulWidget {
  @override
  _ClienteCadastroPageState createState() => _ClienteCadastroPageState();
}

class _ClienteCadastroPageState extends State<ClienteCadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  int? _enderecoSelecionado; // Variável para armazenar o ID do endereço selecionado

  bool _isLoading = false;

  void _cadastrarCliente() async {
    setState(() {
      _isLoading = true;
    });

    String nome = _nomeController.text.trim();
    String telefone = _telefoneController.text.trim();
    String email = _emailController.text.trim();
    int? enderecoId = _enderecoSelecionado; // Obtenha o ID selecionado

    if (nome.isEmpty || telefone.isEmpty || email.isEmpty || enderecoId == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }

    try {
      await _databaseHelper.createCliente(nome, telefone, email, enderecoId);

      Navigator.pop(context); // Navegar de volta ou para a página desejada
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

  void _abrirListagemEnderecos() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EnderecoListagemPage()),
    );

    if (resultado != null && resultado is int) {
      setState(() {
        _enderecoSelecionado = resultado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao botão "Cadastrar"
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22, // Aumenta o tamanho da fonte
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
                    height: 100,
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
              const SizedBox(height: 30),
              _buildTextField(Icons.person, 'Nome', _nomeController, 'Nome Completo'),
              const SizedBox(height: 15),
              _buildTextField(Icons.phone, 'Telefone', _telefoneController, 'Telefone'),
              const SizedBox(height: 15),
              _buildTextField(Icons.email, 'Email', _emailController, 'email@email.com'),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50, // Aumenta a altura do botão
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: _abrirListagemEnderecos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE0E0E0), // Cor de fundo igual ao campo de input
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.location_on, color: Colors.black), // Ícone adicionado
                  label: Text(
                    _enderecoSelecionado == null
                        ? 'Selecionar endereço do cliente'
                        : 'Endereço ID: $_enderecoSelecionado',
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cadastrarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF0000), // Cor de fundo do botão
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

  Widget _buildTextField(
      IconData icon, String label, TextEditingController controller, String hintText) {
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
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[600]),
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
