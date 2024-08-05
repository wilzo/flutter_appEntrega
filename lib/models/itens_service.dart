import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class ItensService {
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

  Future<void> createItensTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS itens (
        id_Itens SERIAL PRIMARY KEY,
        descricao VARCHAR(255) NOT NULL
      )
    ''');
  }

  Future<int?> createItem(String descricao) async {
    if (_connection == null) {
      await connect();
    }
    try {
      final result = await _connection!.execute(
        'INSERT INTO itens_entrega (descricao) VALUES (\$1) RETURNING id_Itens',
        parameters: [descricao],
      );
      return result.isNotEmpty ? result[0][0] as int : null;
    } catch (e) {
      print('Erro ao adicionar item: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getItens() async {
    if (_connection == null) {
      await connect();
    }
    try {
      final result = await _connection!.execute('SELECT * FROM itens');
      return result
          .map((row) => {
                'id': row[0],
                'descricao': row[1],
              })
          .toList();
    } catch (e) {
      print('Erro ao obter itens: $e');
      return [];
    }
  }
}
