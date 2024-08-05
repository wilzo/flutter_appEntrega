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

    // Formatar data e hora no formato que o banco de dados espera
    String formattedData = DateFormat('yyyy-MM-dd').format(dataEntrega);

    // Ajustar o formato da hora, se necessário
    // No caso de já estar no formato correto, apenas passe o valor recebido
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

  Future<List<Map<String, dynamic>>> listarEntregas() async {
    if (_connection == null) {
      await connect();
    }

    final results = await _connection!.execute('''
      SELECT e.id_Entrega, e.data, e.hora_Entrega, ent.nome AS entregador_nome, c.nome AS cliente_nome, i.descricao, e.status
      FROM entregas e
      LEFT JOIN entregador ent ON e.id_Entregador = ent.id_Entregador
      LEFT JOIN clientes c ON e.id_Cliente = c.id
      LEFT JOIN itens_entrega i ON e.id_Itens = i.id_Itens
    ''');

    return results.map((row) => row.toColumnMap()).toList();
  }

Future<List<Map<String, dynamic>>> getEntregas() async {
  if (_connection == null) {
    await connect();
  }
  final results = await _connection!.execute(
    r'''
    SELECT 
      e.id_Entrega,
      e.data,
      e.hora_Entrega,
      e.id_Entregador,
      e.id_Cliente,
      e.id_Itens,
      e.status,
      et.nome AS entregador_nome,
      c.nome AS cliente_nome,
      i.descricao AS descricao
    FROM 
      entregas e
    LEFT JOIN 
      entregador et ON e.id_Entregador = et.id_Entregador
    LEFT JOIN 
      clientes c ON e.id_Cliente = e.id_Cliente
    LEFT JOIN 
      itens_entrega i ON e.id_Itens = i.id_Itens
    '''
  );

  List<Map<String, dynamic>> entregas = results.map((row) {
    return {
      'id_Entrega': row[0],
      'data': row[1],
      'hora_Entrega': row[2],
      'id_Entregador': row[3],
      'id_Cliente': row[4],
      'id_Itens': row[5],
      'status': row[6],
      'entregador_nome': row[7],
      'cliente_nome': row[8],
      'descricao': row[9],
    };
  }).toList();

  return entregas;
}



  Future<void> updateEntregaStatus(int idEntrega, String status) async {
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
      parameters: [status, idEntrega],
    );
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
      novoStatus, // O novo status que será atribuído à entrega
      idEntrega, // O ID da entrega que será atualizada
    ],
  );
}
}
