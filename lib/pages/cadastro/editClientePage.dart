import 'package:flutter/material.dart';
import 'enderecoListagemPage.dart'; // Importe a página de listagem de endereços
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/cliente_service.dart';

class EditClientePage extends StatefulWidget {
  final int clienteId;

  EditClientePage({required this.clienteId});

  @override
  _EditClientePageState createState() => _EditClientePageState();
}

class _EditClientePageState extends State<EditClientePage> {
  final ClienteService _clienteService = ClienteService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  int? _enderecoSelecionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _emailController = TextEditingController();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      await _databaseHelper.connect();
      final cliente =
          await _clienteService.listarClientePorId(widget.clienteId);

      if (cliente != null) {
        setState(() {
          _nomeController.text = cliente['nome'] ?? '';
          _telefoneController.text = cliente['telefone'] ?? '';
          _emailController.text = cliente['email'] ?? '';
          _enderecoSelecionado = cliente['endereco_id'];
        });
      } else {
        print('Cliente não encontrado');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _atualizarCliente() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseHelper.connect();
      await _clienteService.updateCliente(
        widget.clienteId,
        _nomeController.text,
        _telefoneController.text,
        _emailController.text,
        _enderecoSelecionado,
      );
      Navigator.pop(context,
          true); // Envia um valor de retorno para indicar que a lista deve ser atualizada
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar cliente: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      await _databaseHelper.closeConnection();
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
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        backgroundColor: const Color.fromARGB(255, 245, 16, 0),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/entrega.jpg',
                      height: 200,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ENTREGA JA',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Editar Cliente',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Nome', _nomeController, 'Nome Completo'),
              const SizedBox(height: 15),
              _buildTextField('Telefone', _telefoneController, 'Telefone'),
              const SizedBox(height: 15),
              _buildTextField('Email', _emailController, 'email@email.com'),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: _abrirListagemEnderecos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE0E0E0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.location_on, color: Colors.black),
                  label: Text(
                    _enderecoSelecionado == null
                        ? 'Selecionar endereço do cliente'
                        : 'Endereço ID: $_enderecoSelecionado',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _atualizarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 17, 0),
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
                          'Atualizar',
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
      String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
