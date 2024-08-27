import 'package:flutter/material.dart';
import 'enderecoListagemPage.dart';
import 'package:flutter_projeto/models/cliente_service.dart';

class ClienteCadastroPage extends StatefulWidget {
  @override
  _ClienteCadastroPageState createState() => _ClienteCadastroPageState();
}

class _ClienteCadastroPageState extends State<ClienteCadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ClienteService _databaseHelper = ClienteService();

  int? _enderecoSelecionadoId;
  int? _enderecoSelecionadoIdArmazenado; // Nova variável para armazenar o ID
  String? _enderecoSelecionadoDescricao; 

  bool _isLoading = false;
bool validarEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Função para validar telefone
  bool validarTelefone(String telefone) {
    final telefoneRegex = RegExp(
      r'^\+?[0-9]{10,15}$', // Ajuste conforme o formato esperado
    );
    return telefoneRegex.hasMatch(telefone);
  }


  void _cadastrarCliente() async {
  setState(() {
    _isLoading = true;
  });

  // Remover espaços em branco dos campos
  String nome = _nomeController.text.trim();
  String telefone = _telefoneController.text.trim();
  String email = _emailController.text.trim();
  int? enderecoId = _enderecoSelecionadoId; // Usando a nova variável

  // Verificar se algum dos campos está vazio ou nulo
  if (nome.isEmpty || telefone.isEmpty || email.isEmpty || enderecoId == null) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Todos os campos são obrigatórios')),
    );
    return;
  }

  if (!validarEmail(email)) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('E-mail inválido')),
    );
    return;
  }

  if (!validarTelefone(telefone)) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Telefone inválido')),
    );
    return;
  }

  try {
    await _databaseHelper.createCliente(nome, telefone, email, enderecoId);

    // Exibe o pop-up de sucesso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sucesso'),
          content: Text('Cliente cadastrado com sucesso!'),
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
          content: Text('O cliente foi cadastrado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o pop-up
                Navigator.pop(context); // Navegar para a tela anterior
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
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
        title: const Text('Cadastrar Cliente'),
        backgroundColor: Color(0xFFFF0000),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Cadastrar Cliente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF0000),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _telefoneController,
              decoration: InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _abrirListagemEnderecos,
              child:
                  Text(_enderecoSelecionadoDescricao ?? 'Selecionar Endereço'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _cadastrarCliente,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Cadastrar'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
