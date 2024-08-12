import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:intl/intl.dart';

class EntregaService {
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

  Future<void> createEntregasTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS entregas (
        id_Entrega SERIAL PRIMARY KEY,
        data DATE NOT NULL,
        hora_Entrega VARCHAR(100) NOT NULL,
        id_Entregador INTEGER REFERENCES entregador(id_Entregador) ON DELETE SET NULL,
        id_Cliente INTEGER REFERENCES clientes(id) ON DELETE SET NULL,
        id_Itens INTEGER REFERENCES itens_entrega(id_Itens) ON DELETE SET NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'futura'
      )
    ''');
  }

  Future<void> createEntrega(
    DateTime dataEntrega,
    String horaEntrega,
    int idEntregador,
    int idCliente,
    int idItens
  ) async {
    if (_connection == null) {
      await connect();
    }

    String formattedData = DateFormat('yyyy-MM-dd').format(dataEntrega);
    String formattedHora = horaEntrega;

    String query = '''
      INSERT INTO entregas (data, hora_Entrega, id_Entregador, id_Cliente, id_Itens, status)
      VALUES (\$1, \$2, \$3, \$4, \$5, 'futura')
    ''';

    await _connection!.execute(
      query,
      parameters: [
        formattedData,
        formattedHora,
        idEntregador,
        idCliente,
        idItens,
      ],
    );
  }

  Future<List<Map<String, dynamic>>> listarEntregas([String searchQuery = '']) async {
    if (_connection == null) {
      await connect();
    }

    String sql = '''
      SELECT e.id_Entrega, e.data, e.hora_Entrega, ent.nome AS entregador_nome, c.nome AS cliente_nome, i.descricao, e.status
      FROM entregas e
      LEFT JOIN entregador ent ON e.id_Entregador = ent.id_Entregador
      LEFT JOIN clientes c ON e.id_Cliente = c.id
      LEFT JOIN itens_entrega i ON e.id_Itens = i.id_Itens
      WHERE ent.nome LIKE \$1 OR c.nome LIKE \$1 OR i.descricao LIKE \$1
      ORDER BY e.data
    ''';

    List<List<dynamic>> results = await _connection!.execute(
      sql,
      parameters: [
        '%$searchQuery%',
      ],
    );

    List<Map<String, dynamic>> entregas = [];

    for (var row in results) {
      Map<String, dynamic> map = {
        'id_Entrega': row[0],
        'data': row[1],
        'hora_Entrega': row[2],
        'entregador_nome': row[3],
        'cliente_nome': row[4],
        'descricao': row[5],
        'status': row[6],
      };
      entregas.add(map);
    }

    return entregas;
  }

  Future<void> deleteEntrega(int idEntrega) async {
    if (_connection == null) {
      await connect();
    }

    print('Tentando deletar entrega com ID: $idEntrega');

    try {
      await _connection!.execute(
        'DELETE FROM entregas WHERE id_Entrega = \$1',
        parameters: [idEntrega],
      );
    } catch (e) {
      print('Erro ao deletar entrega: $e');
    }
  }

  Future<void> updateEntrega(
    int idEntrega,
    DateTime dataEntrega,
    String horaEntrega,
    int idEntregador,
    int idCliente,
    int idItens,
    String status
  ) async {
    if (_connection == null) {
      await connect();
    }

    String formattedData = DateFormat('yyyy-MM-dd').format(dataEntrega);
    String formattedHora = horaEntrega;

    try {
      await _connection!.execute(
        '''
        UPDATE entregas
        SET data = \$1, hora_Entrega = \$2, id_Entregador = \$3, id_Cliente = \$4, id_Itens = \$5, status = \$6
        WHERE id_Entrega = \$7
        ''',
        parameters: [
          formattedData,
          formattedHora,
          idEntregador,
          idCliente,
          idItens,
          status,
          idEntrega,
        ],
      );
    } catch (e) {
      print('Erro ao atualizar entrega: $e');
    }
  }

  Future<Map<String, dynamic>?> listarEntregaPorId(int idEntrega) async {
    if (_connection == null) {
      await connect();
    }

    try {
      List<List<dynamic>> results = await _connection!.execute(
        '''
        SELECT e.id_Entrega, e.data, e.hora_Entrega, ent.nome AS entregador_nome, c.nome AS cliente_nome, i.descricao, e.status
        FROM entregas e
        LEFT JOIN entregador ent ON e.id_Entregador = ent.id_Entregador
        LEFT JOIN clientes c ON e.id_Cliente = c.id
        LEFT JOIN itens_entrega i ON e.id_Itens = i.id_Itens
        WHERE e.id_Entrega = \$1
        ''',
        parameters: [idEntrega],
      );

      if (results.isEmpty) return null;

      var row = results.first;
      Map<String, dynamic> map = {
        'id_Entrega': row[0],
        'data': row[1],
        'hora_Entrega': row[2],
        'entregador_nome': row[3],
        'cliente_nome': row[4],
        'descricao': row[5],
        'status': row[6],
      };
      return map;
    } catch (e) {
      print('Erro ao listar entrega por ID: $e');
      return null;
    }
  }

  Future<void> checkAndUpdateEntregaStatus() async {
    if (_connection == null) {
      await connect();
    }

    String query = '''
      UPDATE entregas
      SET status = CASE
        WHEN data < CURRENT_DATE THEN 'pendente'
        WHEN data >= CURRENT_DATE THEN status
      END
    ''';

    await _connection!.execute(query);
  }

  Future<void> atualizarStatusEntrega(int idEntrega, String novoStatus) async {
    if (_connection == null) {
      await connect();
    }

    String query = '''
      UPDATE entregas
      SET status = \$1
      WHERE id_Entrega = \$2
    ''';

    await _connection!.execute(
      query,
      parameters: [
        novoStatus,
        idEntrega,
      ],
    );
  }

  // Novo método para pegar todas as entregas
  Future<List<Map<String, dynamic>>> getEntregas() async {
    return await listarEntregas();
  }
}
