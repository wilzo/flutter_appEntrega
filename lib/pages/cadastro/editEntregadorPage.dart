import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/entregador_service.dart';

class EditEntregadorPage extends StatefulWidget {
  final int entregadorId;

  EditEntregadorPage({required this.entregadorId});

  @override
  _EditEntregadorPageState createState() => _EditEntregadorPageState();
}

class _EditEntregadorPageState extends State<EditEntregadorPage> {
  final EntregadorService _entregadorService = EntregadorService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _cnhController;
  late TextEditingController _veiculoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _cnhController = TextEditingController();
    _veiculoController = TextEditingController();
    _carregarDados();
  }

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

  Future<void> _carregarDados() async {
    try {
      await _databaseHelper.connect();
      final entregador =
          await _entregadorService.listarEntregadorPorId(widget.entregadorId);

      if (entregador != null) {
        setState(() {
          _nomeController.text = entregador['nome'] ?? '';
          _telefoneController.text = entregador['telefone'] ?? '';
          _cnhController.text = entregador['cnh'] ?? '';
          _veiculoController.text = entregador['veiculo'] ?? '';
        });
      } else {
        print('Entregador não encontrado');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }
  Future<void> _atualizarEntregador() async {
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

  // Validar telefone
  if (!validarTelefone(telefone)) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Telefone inválido')),
    );
    return;
  }

  // Validar CNH
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
    await _databaseHelper.connect();
    await _entregadorService.updateEntregador(
      widget.entregadorId,
      nome,
      telefone,
      cnh,
      veiculo,
    );

    // Exibir pop-up de confirmação
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sucesso'),
          content: Text('Entregador atualizado com sucesso!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o pop-up
                Navigator.pop(context, true); // Retorna à tela anterior e atualiza a lista
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Erro ao atualizar entregador: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao atualizar entregador: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
    await _databaseHelper.closeConnection();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Entregador'),
        backgroundColor: const Color.fromARGB(255, 245, 16, 0),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22, // Tamanho da fonte do título
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 200.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          'ENTREGAS JA',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Editar entregador',
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
              _buildTextField('Nome', _nomeController, 'Nome'),
              const SizedBox(height: 15),
              _buildTextField('Telefone', _telefoneController, 'Telefone'),
              const SizedBox(height: 15),
              _buildTextField('CNH', _cnhController, 'CNH'),
              const SizedBox(height: 15),
              _buildTextField('Veículo', _veiculoController, 'Veículo'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _atualizarEntregador,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 255, 17, 0), // Cor de fundo
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
