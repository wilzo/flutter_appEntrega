import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/entrega_service.dart'; // Supondo que você tenha um serviço para Entregas
import 'package:flutter_projeto/pages/cadastro/clienteSelecaoPage.dart'; // Importe a página de seleção de cliente
import 'package:flutter_projeto/pages/cadastro/entregadorSelecaopage.dart'; // Importe a página de seleção de entregador
import 'package:flutter_projeto/pages/cadastro/itemSelecaopage.dart'; // Importe a página de seleção de item

class EditEntregaPage extends StatefulWidget {
  final int entregaId;

  EditEntregaPage({required this.entregaId});

  @override
  _EditEntregaPageState createState() => _EditEntregaPageState();
}

class _EditEntregaPageState extends State<EditEntregaPage> {
  final EntregaService _entregaService = EntregaService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  late TextEditingController _descricaoController;
  int? _clienteSelecionadoId;
  int? _entregadorSelecionadoId;
  int? _itemSelecionadoId;
  String? _clienteSelecionadoDescricao;
  String? _entregadorSelecionadoDescricao;
  String? _itemSelecionadoDescricao;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataController = TextEditingController();
    _horaController = TextEditingController();
    _descricaoController = TextEditingController();
    _carregarDados();
  }

  bool _validarHora(String hora) {
  try {
    // Tenta analisar a hora com o formato HH:mm
    final parsedTime = DateFormat('HH:mm').parseStrict(hora);

    // Cria dois objetos DateTime representando o intervalo permitido
    final inicioIntervalo = DateTime(2020, 1, 1, 7, 0); // 07:00
    final fimIntervalo = DateTime(2020, 1, 1, 17, 0); // 17:00

    // Cria um objeto DateTime com a hora inserida
    final horaInserida = DateTime(2020, 1, 1, parsedTime.hour, parsedTime.minute);

    // Verifica se a hora está dentro do intervalo permitido
    return horaInserida.isAfter(inicioIntervalo) && horaInserida.isBefore(fimIntervalo);
  } catch (e) {
    return false; // Se ocorrer um erro ao analisar a hora, a entrada é inválida
  }
}


  Future<void> _carregarDados() async {
    try {
      await _databaseHelper.connect();
      final entrega = await _entregaService.listarEntregaPorId(widget.entregaId);

      if (entrega != null) {
        setState(() {
          _dataController.text = DateFormat('yyyy-MM-dd').format(entrega['data']);
          _horaController.text = entrega['hora_Entrega'];
          _descricaoController.text = entrega['descricao'] ?? '';
          _clienteSelecionadoId = entrega['id_Cliente'];
          _entregadorSelecionadoId = entrega['id_Entregador'];
          _itemSelecionadoId = entrega['id_Itens'];
          _clienteSelecionadoDescricao = entrega['cliente_nome'];
          _entregadorSelecionadoDescricao = entrega['entregador_nome'];
          _itemSelecionadoDescricao = entrega['item_descricao'];
        });
      } else {
        print('Entrega não encontrada');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _atualizarEntrega() async {
    setState(() {
      _isLoading = true;
    });

    String data = _dataController.text.trim();
    String hora = _horaController.text.trim();
    String descricao = _descricaoController.text.trim();

    if (data.isEmpty || hora.isEmpty || descricao.isEmpty || _clienteSelecionadoId == null || _entregadorSelecionadoId == null || _itemSelecionadoId == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }
    if (!_validarHora(hora)) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hora inválida. Use o formato HH:mm e esteja entre o tempo disponivel, entre 07:00 as 17:00')),
    );
    return;
  }

    try {
      await _entregaService.updateEntrega(
        widget.entregaId,
        DateFormat('yyyy-MM-dd').parse(data),
        hora,
        _entregadorSelecionadoId!,
        _clienteSelecionadoId!,
        _itemSelecionadoId!,
        'futura' // Supondo que o status é sempre 'futura'
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: const Text('Entrega atualizada com sucesso!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context, true);
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text('Ocorreu um erro ao atualizar a entrega: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
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

  void _abrirListagemClientes() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClienteSelecaoPage()),
    );

    if (resultado != null && resultado is Map<String, dynamic>) {
      setState(() {
        _clienteSelecionadoDescricao = '${resultado['nome']}';
        _clienteSelecionadoId = resultado['id'];
      });

      print('ID Selecionado: $_clienteSelecionadoId');
      print('Descrição Selecionada: $_clienteSelecionadoDescricao');
    }
  }

  void _abrirListagemEntregadores() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntregadorSelecaoPage()),
    );

    if (resultado != null && resultado is Map<String, dynamic>) {
      setState(() {
        _entregadorSelecionadoDescricao = '${resultado['nome']}';
        _entregadorSelecionadoId = resultado['id'];
      });

      print('ID Selecionado: $_entregadorSelecionadoId');
      print('Descrição Selecionada: $_entregadorSelecionadoDescricao');
    }
  }

  void _abrirListagemItens() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemSelecaoPage()),
    );

    if (resultado != null && resultado is Map<String, dynamic>) {
      setState(() {
        _itemSelecionadoDescricao = resultado['descricao'];
        _itemSelecionadoId = resultado['id'];
        _descricaoController.text = _itemSelecionadoDescricao!;
      });

      print('ID Selecionado: $_itemSelecionadoId');
      print('Descrição Selecionada: $_itemSelecionadoDescricao');
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dataController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  void dispose() {
    _dataController.dispose();
    _horaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Entrega'),
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
              _buildTextField('Data', _dataController, 'AAAA-MM-DD', TextInputType.datetime, _selectDate),
              const SizedBox(height: 15),
              _buildTextField('Hora', _horaController, 'HH:mm'),
              const SizedBox(height: 15),
              _buildSelectionButton('Selecionar Cliente', _clienteSelecionadoDescricao, _abrirListagemClientes),
              const SizedBox(height: 20),
              _buildSelectionButton('Selecionar Entregador', _entregadorSelecionadoDescricao, _abrirListagemEntregadores),
              const SizedBox(height: 20),
              _buildSelectionButton('Selecionar Item', _itemSelecionadoDescricao, _abrirListagemItens),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _atualizarEntrega,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                  backgroundColor: const Color.fromARGB(255, 245, 16, 0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Atualizar Entrega',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hintText, [TextInputType keyboardType = TextInputType.text, GestureTapCallback? onTap]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String label, String? selectedItem, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedItem ?? label,
              style: TextStyle(
                color: selectedItem == null ? Colors.black : Colors.red,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
