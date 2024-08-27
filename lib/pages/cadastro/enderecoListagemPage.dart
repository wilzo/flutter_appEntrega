import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/pages/cadastro/enderecoCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/editEnderecoPage.dart';
import 'package:flutter_projeto/models/endereco_service.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir o link do Google Maps

class EnderecoListagemPage extends StatefulWidget {
  @override
  _EnderecoListagemPageState createState() => _EnderecoListagemPageState();
}

class _EnderecoListagemPageState extends State<EnderecoListagemPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final EnderecoService _enderecoService = EnderecoService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _enderecos = [];

  @override
  void initState() {
    super.initState();
    _listarEnderecos();
  }

  Future<void> _listarEnderecos([String searchQuery = '']) async {
    try {
      await _databaseHelper.connect();
      _enderecos = await _enderecoService.listarEnderecos(searchQuery);
      setState(() {});
    } catch (e) {
      print('Erro ao listar endereços: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

 Future<void> _deletarEndereco(int id) async {
  bool confirmar = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmação'),
      content: Text('Deseja realmente excluir este endereço e seus clientes associados?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Excluir'),
        ),
      ],
    ),
  );

  if (confirmar == true) {
    try {
      bool foiDeletado = await _enderecoService.deleteEndereco(id);

      if (foiDeletado) {
        // Exibe uma notificação de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Endereço e clientes associados deletados com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
        await _listarEnderecos(); // Atualiza a lista após deletar
      } else {
        // Exibe uma notificação avisando que há clientes associados
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não é possível excluir o endereço, pois há clientes associados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao deletar endereço: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao tentar deletar o endereço.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  Future<void> _editarEndereco(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEnderecoPage(enderecoId: id),
      ),
    );

    if (result == true) {
      _listarEnderecos(); // Atualiza a lista após editar
    }
  }

  Future<void> _adicionarEndereco() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnderecoCadastroPage(),
      ),
    );

    if (result == true) {
      _listarEnderecos(); // Atualiza a lista após adicionar
    }
  }

  void _abrirLink(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Não foi possível abrir o link: $link';
    }
  }

  Future<void> _mostrarDialogo(String link) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve clicar no botão para fechar
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Abrir Google Maps'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deseja abrir o link no Google Maps?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Abrir'),
              onPressed: () {
                Navigator.of(context).pop();
                _abrirLink(link);
              },
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
        title: const Text('Endereços Cadastrados'),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar endereço...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _listarEnderecos(_searchController.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _enderecos.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Nenhum endereço cadastrado.'
                          : 'Não foram encontrados resultados.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _enderecos.length,
                    itemBuilder: (context, index) {
                      final endereco = _enderecos[index];
                      final id = endereco['id'];
                      final rua = endereco['rua'];
                      final numero = endereco['numero'];
                      final link = endereco['link']; 

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: Icon(
                            Icons.location_on,
                            size: 50,
                            color: Color(0xFFFF0000), // Cor igual ao padrão
                          ),
                          title: Text(
                            '$rua, $numero',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFFF0000), // Cor igual ao padrão
                            ),
                          ),
                          trailing: id != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editarEndereco(id),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deletarEndereco(id),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check, color: Colors.green),
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          {
                                            'id': id, // Adiciona o ID do endereço aqui
                                            'rua': rua,
                                            'numero': numero,
                                          },
                                        ); // Retorna o nome da rua e o número
                                      },
                                    ),
                                    if (link != null && link.isNotEmpty)
                                      IconButton(
                                        icon: Icon(Icons.map, color: Colors.blue),
                                        onPressed: () => _mostrarDialogo(link),
                                      ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarEndereco,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
      ),
    );
  }
}
