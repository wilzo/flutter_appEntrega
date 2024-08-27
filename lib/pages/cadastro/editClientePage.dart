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
    
    int? _enderecoSelecionadoId;
    int? _enderecoSelecionadoIdArmazenado; // Nova variável para armazenar o ID
    String? _enderecoSelecionadoDescricao; 
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
            _enderecoSelecionadoId = cliente['endereco_id'];
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
    // Atualiza o cliente no banco de dados
    await _clienteService.updateCliente(
      widget.clienteId,
      _nomeController.text,
      _telefoneController.text,
      _emailController.text,
      _enderecoSelecionadoId,
    );

    // Exibindo o pop-up de sucesso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Cliente atualizado com sucesso!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o pop-up
                Navigator.of(context).pop(); // Volta para a tela anterior
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    // Exibindo o pop-up de erro
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text('Ocorreu um erro ao atualizar o cliente: $e'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o pop-up
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }
}

    void _abrirListagemEnderecos() async {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EnderecoListagemPage()),
      );

      if (resultado != null && resultado is Map<String, dynamic>) {
        print('Resultado: $resultado'); // Adicione isto
        setState(() {
          _enderecoSelecionadoDescricao =
              '${resultado['rua']}, ${resultado['numero']}';
          _enderecoSelecionadoId = resultado['id'];
        });
        print('ID Selecionado: $_enderecoSelecionadoId'); // E isto
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
        titleTextStyle: const TextStyle(
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
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: _abrirListagemEnderecos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _enderecoSelecionadoDescricao ?? 'Selecionar Endereço',
                    style: const TextStyle(
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
