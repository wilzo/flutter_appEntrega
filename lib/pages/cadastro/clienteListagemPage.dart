import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/pages/cadastro/editClientePage.dart';
import 'package:flutter_projeto/models/cliente_service.dart';
import 'package:flutter_projeto/pages/cadastro/clienteCadastroPage.dart';

class ClienteListagemPage extends StatefulWidget {
  @override
  _ClienteListagemPageState createState() => _ClienteListagemPageState();
}

class _ClienteListagemPageState extends State<ClienteListagemPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ClienteService _clienteService = ClienteService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _listarClientes();
  }

  Future<void> _listarClientes([String searchQuery = '']) async {
    //ESSE TERMO SEARCHQUERY É USADO PARA BUSCAR COM BASE EM ALGUM PARAMETRO DADO PELO USUARIO
    try {
      await _databaseHelper.connect();
      _clientes = await _clienteService.listarClientes(
          searchQuery); // AQUI ELE ESTÁ BUSCANDO O MÉTODO LISTARCLIENTES EM CLIENTESERVICE
      setState(() {}); // SETA O STATUS
    } catch (e) {
      print('Erro ao listar clientes: $e');
    } finally {
      await _databaseHelper.closeConnection();
    }
  }

  Future<void> _deletarCliente(int id, String nome) async {
    bool podeDeletar = await _clienteService.canDeleteCliente(id);

    if (!podeDeletar) {
      // Mostrar um diálogo ao usuário informando sobre o problema
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text(
              'Não é possível excluir o cliente $nome porque ele possui entregas associadas.'),
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
        content: Text('Deseja realmente excluir o cliente $nome?'),
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
        await _clienteService.deleteCliente(id); // Deletar cliente
        await _listarClientes(); // Atualizar a lista após deletar
      } catch (e) {
        print('Erro ao deletar cliente: $e');
      } finally {
        await _databaseHelper.closeConnection();
      }
    }
  }

  Future<void> _editarCliente(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClientePage(
            clienteId:
                id), //ABRE A PAGINA DE EDITAR E ENVIA O ID DO CLIENTE SELECIONADO PARA EDIÇÃO
      ),
    );

    if (result == true) {
      _listarClientes(); // Atualiza a lista após editar
    }
  }

  Future<void> _adicionarCliente() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteCadastroPage(),
      ),
    );

    if (result == true) {
      _listarClientes(); // Atualiza a lista após adicionar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
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
                      hintText: 'Pesquisar cliente...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _listarClientes(_searchController.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _clientes.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Nenhum cliente cadastrado.'
                          : 'Não foram encontrados resultados.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = _clientes[index];
                      final id = cliente['id'];
                      final nome = cliente['nome'];

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
                            Icons.person,
                            size: 50,
                            color: Color(0xFFFF0000), // Cor igual ao padrão
                          ),
                          title: Text(
                            cliente['nome'] ?? 'Nome',
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
                                  Icon(Icons.phone,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                      'Telefone: ${cliente['telefone'] ?? 'Telefone'}'),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.email,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text('Email: ${cliente['email'] ?? 'Email'}'),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Endereço: ${cliente['rua'] ?? 'Rua'}, ${cliente['numero'] ?? 'Número'}, ${cliente['bairro'] ?? 'Bairro'}, ${cliente['cidade'] ?? 'Cidade'}, ${cliente['estado'] ?? 'Estado'}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: id != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editarCliente(id),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () =>
                                          _deletarCliente(id, nome),
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
        onPressed: _adicionarCliente,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
      ),
    );
  }
}
