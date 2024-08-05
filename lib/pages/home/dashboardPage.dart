import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/entrega_service.dart';
import 'package:flutter_projeto/pages/cadastro/clienteCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregaCadastroPage.dart';
import 'package:flutter_projeto/pages/cadastro/clienteListagemPage.dart';
import 'package:flutter_projeto/pages/cadastro/entregadorListagemPage.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final EntregaService _entregaService = EntregaService();

  bool _showClienteOptions = false;
  bool _showEntregadorOptions = false;
  bool _showEntregaOptions = false;
  List<Map<String, dynamic>> _entregasPendentes = [];
  List<Map<String, dynamic>> _entregasFuturas = [];
  List<Map<String, dynamic>> _entregasConcluidas = [];

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

  Future<void> _loadEntregas() async {
    List<Map<String, dynamic>> entregas = await _entregaService.getEntregas();
    setState(() {
      _entregasPendentes = entregas.where((entrega) => entrega['status'] == 'pendente').toList();
      _entregasFuturas = entregas.where((entrega) => entrega['status'] == 'futura').toList();
      _entregasConcluidas = entregas.where((entrega) => entrega['status'] == 'concluída').toList();
    });
    print('Pendentes: $_entregasPendentes');
    print('Futuras: $_entregasFuturas');
    print('Concluídas: $_entregasConcluidas');
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
      return DateFormat('dd/MM/yyyy').format(data);
    } else if (data is String) {
      try {
        DateTime dateTime = DateTime.parse(data);
        return DateFormat('dd/MM/yyyy').format(dateTime);
      } catch (e) {
        print('Erro ao formatar data: $e');
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
        print('Erro ao formatar hora: $e');
        return hora;
      }
    }
    return hora.toString();
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

  Widget _buildEntregaCard(Map<String, dynamic> entrega) {
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
            SizedBox(height: 5),
            if (entrega['status'] == 'pendente' || entrega['status'] == 'futura')
              ElevatedButton(
                onPressed: () => _concluirEntrega(entrega['id_Entrega']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text('Entrega Concluída', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntregaColumn(String title, List<Map<String, dynamic>> entregas, Color color) {
    return Expanded(
      child: Container(
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
            entregas.isEmpty
                ? Text('Nenhuma entrega.')
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: entregas.map((entrega) => _buildEntregaCard(entrega)).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Image.asset('assets/images/entrega.jpg', height: 50, width: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'ENTREGAJÁ',
                    style: TextStyle(
                      color: Colors.white,
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
                title: const Text('Adicionar Entregador'),
                onTap: () {
                  _navigateAndRefresh(EntregadorCadastroPage());
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
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
                title: const Text('Adicionar Cliente'),
                onTap: () {
                  _navigateAndRefresh(ClienteCadastroPage());
                },
                contentPadding: EdgeInsets.only(left: 50.0),
              ),
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
      appBar: AppBar(
        title: const Text('Tela principal',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        centerTitle: true,
      ),
      body: Row(
        children: [
          _buildEntregaColumn('Pendentes', _entregasPendentes, const Color.fromARGB(255, 112, 11, 21)!),
          _buildEntregaColumn('Futuras', _entregasFuturas, Color.fromARGB(229, 235, 69, 9)!),
          _buildEntregaColumn('Concluídas', _entregasConcluidas, const Color.fromARGB(255, 9, 224, 16)!),
        ],
      ),
    );
  }
}
