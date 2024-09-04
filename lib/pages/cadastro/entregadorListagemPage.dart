import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/pages/cadastro/editEntregadorPage.dart';
import 'package:flutter_projeto/models/entregador_service.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorCadastroPage.dart';

class EntregadorListagemPage extends StatefulWidget {
  @override
  _EntregadorListagemPageState createState() => _EntregadorListagemPageState();
}

class _EntregadorListagemPageState extends State<EntregadorListagemPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final EntregadorService _entregadorService = EntregadorService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _entregadores = [];

  @override
  void initState() {
    super.initState();
    _listarEntregadores();
  }

  Future<void> _listarEntregadores([String searchQuery = '']) async {
    try {
      await _databaseHelper.connect();
      _entregadores = await _entregadorService.listarEntregadores(searchQuery);
      setState(() {});
    } catch (e) {
      print('Erro ao listar entregadores: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }
Future<void> _deletarEntregador(int id, String nome) async {
  // Verificar se o entregador pode ser excluído
  bool podeDeletar = await _entregadorService.canDeleteEntregador(id);

  if (!podeDeletar) {
    // Mostrar um diálogo ao usuário informando sobre o problema
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text('Não é possível excluir o entregador $nome porque ele está vinculado a uma entrega.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  // Mostrar um diálogo de confirmação
  bool confirmar = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmação'),
      content: Text('Deseja realmente excluir o entregador $nome?'),
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
      await _databaseHelper.connect(); // Conectar com o banco de dados
      await _entregadorService.deleteEntregador(id); // Deletar entregador
      await _listarEntregadores(); // Atualizar a lista após deletar
    } catch (e) {
      print('Erro ao deletar entregador: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }
}


  Future<void> _editarEntregador(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntregadorPage(entregadorId: id),
      ),
    );

    if (result == true) {
      _listarEntregadores(); // Atualiza a lista após editar
    }
  }

  Future<void> _adicionarEntregador() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntregadorCadastroPage(),
      ),
    );

    if (result == true) {
      _listarEntregadores(); // Atualiza a lista após adicionar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregadores Cadastrados'),
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
                      hintText: 'Pesquisar entregador...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _listarEntregadores(_searchController.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _entregadores.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Nenhum entregador cadastrado.'
                          : 'Não foram encontrados resultados.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _entregadores.length,
                    itemBuilder: (context, index) {
                      final entregador = _entregadores[index];
                      final id = entregador['id_Entregador'];
                      final nome = entregador['nome'];

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
                            Icons.local_shipping,
                            size: 50,
                            color: Color(0xFFFF0000), // Cor igual ao padrão
                          ),
                          title: Text(
                            entregador['nome'] ?? 'Nome',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFFF0000), // Cor igual ao padrão
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                      'Telefone: ${entregador['telefone'] ?? 'Telefone'}'),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.card_membership,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text('CNH: ${entregador['cnh'] ?? 'CNH'}'),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.directions_car,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                      'Veículo: ${entregador['veiculo'] ?? 'Veículo'}'),
                                ],
                              ),
                            ],
                          ),
                          trailing: id != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editarEntregador(id),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deletarEntregador(id, nome),
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
        onPressed: _adicionarEntregador,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
      ),
    );
  }
}
