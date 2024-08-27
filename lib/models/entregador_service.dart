import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class EntregadorService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Connection? _connection;

  // Conectar ao banco de dados
  Future<void> connect() async {
    _connection = _databaseHelper.connection;
    if (_connection == null) {
      await _databaseHelper.connect();
      _connection = _databaseHelper.connection;
    }
  }

  Future<void> createEntregadorTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS entregador (
        id_Entregador SERIAL PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        telefone VARCHAR(100) NOT NULL,
        cnh VARCHAR(20) NOT NULL,
        veiculo VARCHAR(50) NOT NULL
      )
    ''');
  }

  Future<void> cadastrarEntregador(
      String nome, String telefone, String cnh, String veiculo) async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute(
      r'INSERT INTO entregador (nome, telefone, cnh, veiculo) VALUES ($1, $2, $3, $4)',
      parameters: [
        nome,
        telefone,
        cnh,
        veiculo,
      ],
    );
    
  }

  Future<List<Map<String, dynamic>>> listarEntregadores([String searchQuery = '']) async {
    if (_connection == null) {
      await connect();
    }

    String sql = '''
      SELECT id_Entregador, nome, telefone, cnh, veiculo
      FROM entregador
      WHERE nome LIKE \$1 OR telefone LIKE \$1 OR cnh LIKE \$1 OR veiculo LIKE \$1
      ORDER BY nome
    ''';

    List<List<dynamic>> results = await _connection!.execute(
      sql,
      parameters: [
        '%$searchQuery%',
      ],
    );

    List<Map<String, dynamic>> entregadores = [];

    for (var row in results) {
      Map<String, dynamic> map = {
        'id_Entregador': row[0],
        'nome': row[1],
        'telefone': row[2],
        'cnh': row[3],
        'veiculo': row[4],
      };
      entregadores.add(map);
    }

    return entregadores;
  }
  
  Future<void> deleteEntregador(int id) async {
    if (_connection == null) {
      await connect();
    }

    print('Tentando deletar entregador com ID: $id');

    try {
      await _connection!.execute(
        'DELETE FROM entregador WHERE id_Entregador = \$1',
        parameters: [id],
      );
    } catch (e) {
      print('Erro ao deletar entregador: $e');
    }
  }

  Future<void> updateEntregador(
      int id, String nome, String telefone, String cnh, String veiculo) async {
    if (_connection == null) {
      await connect();
    }

    try {
      await _connection!.execute(
        '''
        UPDATE entregador
        SET nome = \$1, telefone = \$2, cnh = \$3, veiculo = \$4
        WHERE id_Entregador = \$5
        ''',
        parameters: [
          nome,
          telefone,
          cnh,
          veiculo,
          id,
        ],
      );
    } catch (e) {
      print('Erro ao atualizar entregador: $e');
    }
  }

  Future<Map<String, dynamic>?> listarEntregadorPorId(int id) async {
    if (_connection == null) {
      await connect();
    }

    try {
      List<List<dynamic>> results = await _connection!.execute(
        '''
        SELECT id_Entregador, nome, telefone, cnh, veiculo
        FROM entregador
        WHERE id_Entregador = \$1
        ''',
        parameters: [id],
      );

      if (results.isEmpty) return null;
      
      var row = results.first;
      Map<String, dynamic> map = {
        'id_Entregador': row[0],
        'nome': row[1],
        'telefone': row[2],
        'cnh': row[3],
        'veiculo': row[4],
      };
      return map;
    } catch (e) {
      print('Erro ao listar entregador por ID: $e');
      return null;
    }
  }
}
