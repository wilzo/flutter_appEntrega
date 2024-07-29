import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class EditEntregadorPage extends StatefulWidget {
  final int entregadorId;

  EditEntregadorPage({required this.entregadorId});

  @override
  _EditEntregadorPageState createState() => _EditEntregadorPageState();
}

class _EditEntregadorPageState extends State<EditEntregadorPage> {
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

  Future<void> _carregarDados() async {
    try {
      await _databaseHelper.connect();
      final entregador = await _databaseHelper.listarEntregadorPorId(widget.entregadorId);

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

    try {
      await _databaseHelper.connect();
      await _databaseHelper.updateEntregador(
        widget.entregadorId,
        _nomeController.text,
        _telefoneController.text,
        _cnhController.text,
        _veiculoController.text,
      );
      Navigator.pop(context);
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
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _cnhController.dispose();
    _veiculoController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 200.0, vertical: 30.0),
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
                    backgroundColor: const Color.fromARGB(255, 255, 17, 0), // Cor de fundo
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

  Widget _buildTextField(String label, TextEditingController controller, String hintText) {
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
