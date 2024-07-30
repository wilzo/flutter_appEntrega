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

  Future<List<Map<String, dynamic>>> listarEntregadores() async {
    if (_connection == null) {
      await connect();
    }

    final results = await _connection!.execute('''
      SELECT id_Entregador, nome, telefone, cnh, veiculo
      FROM entregador
    ''');

    final entregadores = results.map((row) {
      final entregador = {
        'id_Entregador': row[0],
        'nome': row[1],
        'telefone': row[2],
        'cnh': row[3],
        'veiculo': row[4],
      };
      print('Row data: $entregador');
      return entregador;
    }).toList();

    return entregadores;
  }

  Future<void> deleteEntregador(int id) async {
    if (_connection == null) {
      throw Exception("Connection is not established");
    }

    print('Tentando deletar entregador com ID: $id');

    try {
      await _connection!.execute(
        r'DELETE FROM entregador WHERE id_Entregador = $1',
        parameters: [id], // O valor do parâmetro é passado aqui
      );
    } catch (e) {
      print('Erro ao deletar entregador: $e');
    }
  }

  Future<Map<String, dynamic>?> listarEntregadorPorId(int id) async {
    if (_connection == null) {
      await connect();
    }

    try {
      final results = await _connection!.execute(
        'SELECT id_Entregador, nome, telefone, cnh, veiculo FROM entregador WHERE id_Entregador = $id',
        parameters: [id],
      );

      if (results.isEmpty) return null;
      return results.first.toColumnMap();
    } catch (e) {
      print('Erro ao listar entregador por ID: $e');
      return null;
    }
  }

  Future<void> updateEntregador(
      int id, String nome, String telefone, String cnh, String veiculo) async {
    if (_connection == null) {
      throw Exception("Connection is not established");
    }

    try {
      await _connection!.execute(
        r'''
      UPDATE entregador
      SET nome = $2, telefone = $3, cnh = $4, veiculo = $5
      WHERE id_Entregador = $1
      ''',
        parameters: [
          id, // $1
          nome, // $2
          telefone, // $3
          cnh, // $4
          veiculo, // $5
        ],
      );
    } catch (e) {
      print('Erro ao atualizar entregador: $e');
    }
  }
}
