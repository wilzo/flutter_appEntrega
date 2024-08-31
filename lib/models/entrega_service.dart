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
    id_Entregador INTEGER REFERENCES entregador(id_Entregador) ON DELETE CASCADE,
    id_Cliente INTEGER REFERENCES clientes(id) ON DELETE CASCADE,
    id_Itens INTEGER REFERENCES itens_entrega(id_Itens) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'futura'
);
);

    ''');
  }

  Future<void> createEntrega(DateTime dataEntrega, String horaEntrega,
      int idEntregador, int idCliente, int idItens) async {
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

  Future<List<Map<String, dynamic>>> listarEntregas(
      [String searchQuery = '']) async {
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

  Future<String?> getLinkEnderecoByIdEntrega(int idEntrega) async {
    if (_connection == null) {
      await connect();
    }

    try {
      // Buscar o id_cliente na tabela de entregas
      List<List<dynamic>> entregaResult = await _connection!.execute(
        'SELECT id_cliente FROM entregas WHERE id_Entrega = \$1',
        parameters: [idEntrega],
      );

      if (entregaResult.isNotEmpty) {
        int idCliente = entregaResult[0][0];

        // Buscar o id_endereco na tabela de clientes usando o id_cliente
        List<List<dynamic>> clienteResult = await _connection!.execute(
          'SELECT endereco_id FROM clientes WHERE id = \$1',
          parameters: [idCliente],
        );

        if (clienteResult.isNotEmpty) {
          int idEndereco = clienteResult[0][0];

          // Buscar o link na tabela de endereços usando o id_endereco
          List<List<dynamic>> enderecoResult = await _connection!.execute(
            'SELECT link FROM endereco WHERE id = \$1',
            parameters: [idEndereco],
          );

          if (enderecoResult.isNotEmpty) {
            return enderecoResult[0][0] as String?;
          }
        }
      }
    } catch (e) {
      print('Erro ao obter o link do endereço pela entrega: $e');
    }

    return null; // Retorna null se o link não for encontrado
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
  String status,
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


  } Future<void> atualizarEntrega(
    int idEntrega,
    DateTime data,
    String hora, // Hora como String no formato HH:mm
    String descricao,
    int enderecoId,
  ) async {
    if (_connection == null) {
      await _connect();
    }

    String query = '''
      UPDATE entrega
      SET data = \$1,
          hora = \$2,
          descricao = \$3,
          endereco_id = \$4
      WHERE id_entrega = \$5
    ''';

    await _connection!.execute(
      query,
      parameters: [
        data.toIso8601String().split('T').first, // Formato DATE
        hora, // Hora como String no formato HH:mm
        descricao,
        enderecoId,
        idEntrega,
      ],
    );

    print('Entrega atualizada com sucesso!');
  }

  Future<void> _connect() async {

  }
}


