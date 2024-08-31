import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/endereco_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/entrega_service.dart';
import 'package:flutter_projeto/pages/cadastro/clienteCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregaCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/clienteListagemPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorListagemPage.dart';
import 'package:url_launcher/url_launcher.dart'; // Adicione isso no início do seu arquivo
import 'package:flutter_projeto/pages/cadastro/enderecoListagemPage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_projeto/pages/cadastro/EditEntregaPage.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final EntregaService _entregaService = EntregaService();
  final EnderecoService _enderecoService = EnderecoService();

  bool _showClienteOptions = false;
  bool _showEntregadorOptions = false;
  bool _showEntregaOptions = false;
  List<Map<String, dynamic>> _entregasPendentes = [];
  List<Map<String, dynamic>> _entregasFuturas = [];
  List<Map<String, dynamic>> _entregasConcluidas = [];
  String _searchQuery = '';
  final _horaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _databaseHelper.connect();
    await _entregaService.checkAndUpdateEntregaStatus();
    await _loadEntregas();
  }

  Future<void> _editarEntrega(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntregaPage(entregaId: id),
      ),
    );

    if (result == true) {
      _loadEntregas(); // Atualiza a lista após editar
    }
  }

  Future<void> _loadEntregas() async {
    List<Map<String, dynamic>> entregas = await _entregaService.getEntregas();
    setState(() {
      _entregasPendentes =
          entregas.where((entrega) => entrega['status'] == 'pendente').toList();
      _entregasFuturas =
          entregas.where((entrega) => entrega['status'] == 'futura').toList();
      _entregasConcluidas = entregas
          .where((entrega) => entrega['status'] == 'concluída')
          .toList();
    });
  }

  Future<void> _concluirEntrega(int idEntrega) async {
    await _entregaService.atualizarStatusEntrega(idEntrega, 'concluída');
    await _loadEntregas();
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    await _loadEntregas();
  }

  String _formatarData(dynamic data) {
    if (data is DateTime) {
      return DateFormat('dd/MM/yyyy', 'pt_BR')
          .format(data); // Adiciona o código do local
    } else if (data is String) {
      try {
        DateTime dateTime = DateTime.parse(data);
        return DateFormat('dd/MM/yyyy', 'pt_BR')
            .format(dateTime); // Adiciona o código do local
      } catch (e) {
        return data;
      }
    }
    return data.toString();
  }

  String _formatarHora(dynamic hora) {
    if (hora is DateTime) {
      return DateFormat('HH:mm').format(hora);
    } else if (hora is String) {
      try {
        DateTime dateTime = DateFormat('HH:mm:ss').parse(hora);
        return DateFormat('HH:mm').format(dateTime);
      } catch (e) {
        return hora;
      }
    }
    return hora.toString();
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sair'),
          content: Text('Você realmente deseja sair?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o pop-up
                Navigator.of(context).pushReplacementNamed(
                    '/login'); // Navegar para a tela de login
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleClienteOptions() {
    setState(() {
      _showClienteOptions = !_showClienteOptions;
    });
  }

  void _toggleEntregadorOptions() {
    setState(() {
      _showEntregadorOptions = !_showEntregadorOptions;
    });
  }

  void _toggleEntregaOptions() {
    setState(() {
      _showEntregaOptions = !_showEntregaOptions;
    });
  }

  Future<void> _abrirLink(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o link.')),
      );
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
                if (link != null && link.isNotEmpty) {
                  _abrirLink(link);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('URL do endereço não disponível')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getEnderecoLink(int idEndereco) async {
    return await _entregaService.getLinkEnderecoByIdEntrega(idEndereco);
  }

  Widget _buildEntregaCard(Map<String, dynamic> entrega) {
    return FutureBuilder<String?>(
      future: _getEnderecoLink(entrega['id_Entrega']),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        String? urlEndereco = snapshot.data;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrega #${entrega['id_Entrega']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  entrega['descricao'],
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14),
                    SizedBox(width: 5),
                    Text(
                      _formatarData(entrega['data']),
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14),
                    SizedBox(width: 5),
                    Text(
                      _formatarHora(entrega['hora_Entrega']),
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.person, size: 14),
                    SizedBox(width: 5),
                    Text(
                      entrega['entregador_nome'] ?? 'N/A',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14),
                    SizedBox(width: 5),
                    Text(
                      entrega['cliente_nome'] ?? 'N/A',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (entrega['status'] == 'pendente' ||
                        entrega['status'] == 'futura')
                      ElevatedButton(
                        onPressed: () =>
                            _concluirEntrega(entrega['id_Entrega']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Concluir', style: TextStyle(fontSize: 12)),
                      ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue, size: 24),
                      onPressed: () => _editarEntrega(entrega['id_Entrega']),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: Icon(Icons.map, size: 24, color: Colors.blue),
                      onPressed: () {
                        if (urlEndereco != null && urlEndereco.isNotEmpty) {
                          _mostrarDialogo(urlEndereco);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Endereço não encontrado ou inválido.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntregaColumn(
      String title, List<Map<String, dynamic>> entregas, Color color) {
    return Container(
      width: 400, // Ajuste a largura conforme necessário
      color: color,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: entregas
                    .where((entrega) => (entrega['cliente_nome'] ?? '')
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .map((entrega) => _buildEntregaCard(entrega))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TELA PRINCIPAL'),
        backgroundColor: Color(0xFFFF0000), // Cor igual ao padrão
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'meu_perfil') {
                // Ação para "Meu Perfil"
                // Aqui você pode navegar para a página de perfil do usuário
              } else if (value == 'sair') {
                _confirmarLogout(context);
              }
            },
            icon: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person,
                  color:
                      Colors.white), // Ícone temporário para a foto de perfil
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'meu_perfil',
                  child: Text('Meu Perfil'),
                ),
                PopupMenuItem<String>(
                  value: 'sair',
                  child: Text('Sair'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/entrega.jpg',
                      height: 50, width: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'ENTREGAJÁ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: const Text('Tela principal'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: const Text('Entregas'),
              onTap: _toggleEntregaOptions,
            ),
            if (_showEntregaOptions) ...[
              ListTile(
                title: const Text('Adicionar Entrega'),
                onTap: () async {
                  await _navigateAndRefresh(EntregaCadastroPage());
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Entregadores'),
              onTap: _toggleEntregadorOptions,
            ),
            if (_showEntregadorOptions) ...[
              ListTile(
                title: const Text('Listar Entregadores'),
                onTap: () {
                  _navigateAndRefresh(EntregadorListagemPage());
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
            ListTile(
              leading: Icon(Icons.person_outline),
              title: const Text('Clientes'),
              onTap: _toggleClienteOptions,
            ),
            if (_showClienteOptions) ...[
              ListTile(
                title: const Text('Listar Clientes'),
                onTap: () {
                  _navigateAndRefresh(ClienteListagemPage());
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
            ],
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width:
                  1200, // Define a largura do Container para corresponder à largura das colunas
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pesquisar por nome do cliente',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
                height: 20), // Espaço entre o campo de pesquisa e as colunas
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEntregaColumn('Pendentes', _entregasPendentes,
                        Color.fromARGB(255, 255, 247, 2)),
                    _buildEntregaColumn('Futuras', _entregasFuturas,
                        Color.fromARGB(235, 231, 134, 8)),
                    _buildEntregaColumn('Concluídas', _entregasConcluidas,
                        const Color.fromARGB(255, 0, 239, 8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
