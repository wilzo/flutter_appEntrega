import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class ClienteService {
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

  Future<void> createClienteTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id SERIAL PRIMARY KEY,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      endereco_id INTEGER REFERENCES endereco(id) ON DELETE SET NULL
    )
  ''');
  }

  Future<void> createCliente(String nome, String telefone, String email, int? enderecoId) async {
    if (_connection == null) {
      await connect();
    }

    String query = '''
    INSERT INTO clientes (nome, telefone, email, endereco_id)
    VALUES (\$1, \$2, \$3, \$4)
  ''';

    await _connection!.execute(
      query,
      parameters: [
        nome,
        telefone,
        email,
        enderecoId,
      ],
    );
  }

  Future<List<Map<String, dynamic>>> listarClientes() async {
    if (_connection == null) {
      await connect();
    }

    final results = await _connection!.execute('''
      SELECT c.id, c.nome, c.telefone, c.email, e.rua, e.numero, e.bairro, e.cidade, e.estado
      FROM clientes c
      LEFT JOIN endereco e ON c.endereco_id = e.id
    ''');

    return results.map((row) => row.toColumnMap()).toList();
  }

  Future<void> deleteCliente(int id) async {
    if (_connection == null) {
      await connect();
    }

    print('Tentando deletar cliente com ID: $id');

    try {
      await _connection!.execute(
        r'DELETE FROM clientes WHERE id = $1',
        parameters: [id],
      );
    } catch (e) {
      print('Erro ao deletar cliente: $e');
    }
  }

  Future<void> updateCliente(int id, String nome, String telefone, String email, int? enderecoId) async {
    if (_connection == null) {
      await connect();
    }

    try {
      await _connection!.execute(
        r'''
        UPDATE clientes
        SET nome = $2, telefone = $3, email = $4, endereco_id = $5
        WHERE id = $1
        ''',
        parameters: [
          id,       // $1
          nome,     // $2
          telefone, // $3
          email,    // $4
          enderecoId // $5
        ],
      );
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
    }
  }

  Future<Map<String, dynamic>?> listarClientePorId(int id) async {
    if (_connection == null) {
      await connect();
    }

    try {
      final results = await _connection!.execute(
        r'''
        SELECT c.id, c.nome, c.telefone, c.email, e.rua, e.numero, e.bairro, e.cidade, e.estado
        FROM clientes c
        LEFT JOIN endereco e ON c.endereco_id = e.id
        WHERE c.id = $1
        ''',
        parameters: [id],
      );

      if (results.isEmpty) return null;
      return results.first.toColumnMap();
    } catch (e) {
      print('Erro ao listar cliente por ID: $e');
      return null;
    }
  }
}
