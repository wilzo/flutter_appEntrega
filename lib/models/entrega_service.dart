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
        id_Itens INTEGER REFERENCES itens_entrega(id_Itens) ON DELETE SET NULL
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
    INSERT INTO entregas (data, hora_Entrega, id_Entregador, id_Cliente, id_Itens)
    VALUES (\$1, \$2, \$3, \$4, \$5)
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
      SELECT e.id_Entrega, e.data, e.hora_Entrega, ent.nome AS entregador_nome, c.nome AS cliente_nome, i.descricao
      FROM entregas e
      LEFT JOIN entregadores ent ON e.id_Entregador = ent.id_Entregador
      LEFT JOIN clientes c ON e.id_Cliente = c.id
      LEFT JOIN itens i ON e.id_Itens = i.id_Itens
    ''');

    return results.map((row) => row.toColumnMap()).toList();
  }

}