import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class EnderecoService {
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

  Future<void> createEnderecoTable() async {
    if (_connection == null) {
      await connect();
    }
    try {
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS endereco (
          id SERIAL PRIMARY KEY,
          rua TEXT NOT NULL,
          numero TEXT NOT NULL,
          bairro TEXT NOT NULL,
          cidade TEXT NOT NULL,
          estado TEXT NOT NULL
        )
      ''');
    } catch (e) {
      print('Erro ao criar tabela de endereços: $e');
    }
  }

  Future<void> createEndereco(String rua, String numero, String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    try {
      await _connection!.execute(
        r'INSERT INTO endereco (rua, numero, bairro, cidade, estado) VALUES ($1, $2, $3, $4, $5)',
        parameters: [rua, numero, bairro, cidade, estado],
      );
    } catch (e) {
      print('Erro ao criar endereço: $e');
    }
  }

  Future<Map<String, dynamic>?> getEnderecoPorId(int id) async {
    if (_connection == null) {
      await connect();
    }
    try {
      List<List<dynamic>> results = await _connection!.execute(
        r'SELECT * FROM endereco WHERE id = $1',
        parameters: [id],
      );
      if (results.isEmpty) return null;
      return {
        'id': results.first[0],
        'rua': results.first[1],
        'numero': results.first[2],
        'bairro': results.first[3],
        'cidade': results.first[4],
        'estado': results.first[5],
      };
    } catch (e) {
      print('Erro ao obter endereço por ID: $e');
      return null;
    }
  }

  Future<void> updateEndereco(int id, String rua, String numero, String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    try {
      await _connection!.execute(
        r'UPDATE endereco SET rua = $1, numero = $2, bairro = $3, cidade = $4, estado = $5 WHERE id = $6',
        parameters: [rua, numero, bairro, cidade, estado, id],
      );
    } catch (e) {
      print('Erro ao atualizar endereço: $e');
    }
  }

  Future<void> deleteEndereco(int id) async {
    if (_connection == null) {
      await connect();
    }
    try {
      await _connection!.execute(
        r'DELETE FROM endereco WHERE id = $1',
        parameters: [id],
      );
    } catch (e) {
      print('Erro ao deletar endereço: $e');
    }
  }

  Future<bool> verificarEnderecoExiste(String rua, String numero, String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    try {
      List<List<dynamic>> result = await _connection!.execute(
        r'SELECT COUNT(*) FROM endereco WHERE rua = $1 AND numero = $2 AND bairro = $3 AND cidade = $4 AND estado = $5',
        parameters: [rua, numero, bairro, cidade, estado],
      );
      return result[0][0] > 0;
    } catch (e) {
      print('Erro ao verificar se o endereço existe: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listarEnderecos([String searchQuery = '']) async {
    if (_connection == null) {
      await connect();
    }
    try {
      List<List<dynamic>> results = await _connection!.execute(
        '''
        SELECT id, rua, numero, bairro, cidade, estado
        FROM endereco
        WHERE rua LIKE \$1 OR numero LIKE \$1 OR bairro LIKE \$1 OR cidade LIKE \$1 OR estado LIKE \$1
        ORDER BY rua
        ''',
        parameters: ['%$searchQuery%'],
      );

      List<Map<String, dynamic>> enderecos = [];
      for (var row in results) {
        Map<String, dynamic> map = {
          'id': row[0],
          'rua': row[1],
          'numero': row[2],
          'bairro': row[3],
          'cidade': row[4],
          'estado': row[5],
        };
        enderecos.add(map);
      }

      return enderecos;
    } catch (e) {
      print('Erro ao listar endereços: $e');
      return [];
    }
  }
}
