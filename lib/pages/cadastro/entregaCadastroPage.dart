  import 'package:flutter/material.dart';
  import 'package:flutter_projeto/pages/cadastro/clienteSelecaoPage.dart';
  import 'package:flutter_projeto/pages/cadastro/entregadorSelecaoPage.dart';
  import 'package:flutter_projeto/pages/cadastro/ItemSelecaoPage.dart'; // Importe a página de listagem de itens
  import 'package:flutter_projeto/models/databaseHelper.dart';
  import 'package:flutter_projeto/models/entrega_service.dart';

  import 'package:intl/intl.dart';

  class EntregaCadastroPage extends StatefulWidget {
    @override
    _EntregaCadastroPageState createState() => _EntregaCadastroPageState();
  }

  class _EntregaCadastroPageState extends State<EntregaCadastroPage> {
    final TextEditingController _dataController = TextEditingController();
    final TextEditingController _horaController = TextEditingController();
    final TextEditingController _descricaoController = TextEditingController();
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final EntregaService _entregaService = EntregaService();
    String? _entregadorSelecionadoDescricao;
    int? _entregadorSelecionadoId;
    String? _clienteSelecionadoDescricao;
    int? _clienteSelecionadoId;
    String? _itemSelecionadoDescricao;
    int? _itemSelecionadoId;


    bool _isLoading = false;

    void _selectDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        
      );

      if (pickedDate != null) {
        // Formata a data no formato yyyy-MM-dd
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        setState(() {
          _dataController.text = formattedDate;
        });
      }
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
 
   void _cadastrarEntrega() async {
  setState(() {
    _isLoading = true;
  });

  String data = _dataController.text.trim();
  String hora = _horaController.text.trim();
  String descricao = _descricaoController.text.trim();
  int? entregadorId = _entregadorSelecionadoId;
  int? clienteId = _clienteSelecionadoId;
  int? itemId = _itemSelecionadoId;

  if (data.isEmpty ||
      hora.isEmpty ||
      descricao.isEmpty ||
      entregadorId == null ||
      clienteId == null ||
      itemId == null) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Todos os campos são obrigatórios')),
    );
    return;
  }

  // Validação da data
  DateTime? dataEntrega;
  try {
    dataEntrega = DateFormat('yyyy-MM-dd').parseStrict(data);
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data inválida. Use o formato yyyy-MM-dd.')),
    );
    return;
  }

  // Validação da hora
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
    await _entregaService.createEntrega(
        dataEntrega, hora, entregadorId, clienteId, itemId);

    _showSuccessDialog();
  } catch (e) {
    print('Erro ao cadastrar entrega: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao cadastrar entrega: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
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

    void _abrirListagemClientes() async {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClienteSelecaoPage()),
      );

      if (resultado != null && resultado is Map<String, dynamic>) {
        setState(() {
          _clienteSelecionadoDescricao = '${resultado['nome']} ';
          _clienteSelecionadoId = resultado['id'];
        });

        print('ID Selecionado: $_clienteSelecionadoId');
        print('Descrição Selecionada: $_clienteSelecionadoDescricao');
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
    void _showSuccessDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cadastro Realizado!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text('A entrega foi cadastrada com sucesso!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar o pop-up
                  Navigator.pop(context); // Navegar de volta para a tela anterior
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cadastrar Entrega'),
          backgroundColor: Color(0xFFFF0000),
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
                          'CADASTRE SUAS ENTREGAS',
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
                _buildTextField(Icons.calendar_today, 'Data', _dataController,
                    'Data da entrega (yyyy-MM-dd)', _selectDate),
                const SizedBox(height: 15),
                _buildTextField(Icons.access_time, 'Hora', _horaController,
                    'Hora da entrega (HH:mm)'),
                const SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _abrirListagemEntregadores,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE0E0E0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.person, color: Colors.black),
                    label: Text(
                      _entregadorSelecionadoDescricao ?? 'Selecionar entregador',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _abrirListagemClientes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE0E0E0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.person, color: Colors.black),
                    label: Text(
                      _clienteSelecionadoDescricao ?? 'Selecionar cliente',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _abrirListagemItens,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE0E0E0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.list, color: Colors.black),
                    label: Text(
                      _itemSelecionadoDescricao == null
                          ? 'Selecionar item'
                          : 'Descrição: $_itemSelecionadoDescricao', // Atualiza o texto para mostrar a descrição
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _cadastrarEntrega,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF0000),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildTextField(
        IconData icon, String label, TextEditingController controller,
        [String hintText = '', Function()? onTap]) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black),
            hintText: hintText,
            labelText: label,
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          ),
          onTap: onTap,
        ),
      );
    }
  }
