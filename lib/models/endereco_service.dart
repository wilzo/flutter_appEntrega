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
  }

  Future<void> createEndereco(String rua, String numero, String bairro,
      String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute(
      r'INSERT INTO endereco (rua, numero, bairro, cidade, estado) VALUES ($1, $2, $3, $4, $5)',
      parameters: [
        rua,
        numero,
        bairro,
        cidade,
        estado,
      ],
    );
  }

  Future<Map<String, dynamic>?> getEndereco(String rua, String numero,
      String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    final results = await _connection!.execute(
      r'SELECT * FROM endereco WHERE rua = $1 AND numero = $2 AND bairro = $3 AND cidade = $4 AND estado = $5',
      parameters: [
        rua,
        numero,
        bairro,
        cidade,
        estado,
      ],
    );
    if (results.isEmpty) return null;
    return results.first.toColumnMap();
  }

  Future<bool> verificarEnderecoExiste(String rua, String numero, String bairro,
      String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    final result = await _connection!.execute(
      r'SELECT COUNT(*) FROM endereco WHERE rua = $1 AND numero = $2 AND bairro = $3 AND cidade = $4 AND estado = $5',
      parameters: [
        rua,
        numero,
        bairro,
        cidade,
        estado,
      ],
    );
    return result[0][0] == 1;
  }

  // Método para listar todos os endereços
  Future<List<Map<String, dynamic>>> listarEndereco() async {
    if (_connection == null) {
      await connect();
    }
    final results = await _connection!.execute(
        'SELECT id, rua, numero, bairro, cidade, estado FROM endereco');
    return results.map((row) => row.toColumnMap()).toList();
  }

}
