import 'package:postgres/postgres.dart';
import 'package:intl/intl.dart';

import '../database/config.dart';

class DatabaseHelper {
  Connection? _connection;

  Future<void> connect() async {
    _connection = await database();
  }

  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
    }
  }

  Future<void> createUserTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<void> createUser(
      String username, String email, String password) async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute(
      r'INSERT INTO users (username, email, password) VALUES ($1, $2, $3)',
      parameters: [
        username,
        email,
        password, // Certifique-se de hash a senha antes de armazená-la
      ],
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    if (_connection == null) {
      await connect();
    }
    final results = await _connection!.execute(
      'SELECT * FROM users WHERE username = username',
      parameters: [
        'username',
      ],
    );
    if (results.isEmpty) return null;
    return results.first.toColumnMap();
  }

  Future<bool> loginUser(String email, String password) async {
    if (_connection == null) {
      await connect();
    }
    try {
      final result = await _connection!.execute(
        r'''
        SELECT COUNT(*) AS count
        FROM users
        WHERE email = $1 AND password = $2
        ''',
        parameters: [
          email,
          password,
        ],
      );

      if (result.isNotEmpty && result[0][0] == 1) {
        return true; // Usuário autenticado com sucesso
      } else {
        return false; // Credenciais inválidas
      }
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
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

  Future<void> createCliente(
      String nome, String telefone, String email, int? enderecoId) async {
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
      throw Exception("Connection is not established");
    }

    print('Tentando deletar cliente com ID: $id');

    try {
      await _connection!.execute(
        r'DELETE FROM clientes WHERE id = $1',
        parameters: [id], // O valor do parâmetro é passado aqui
      );
    } catch (e) {
      print('Erro ao deletar cliente: $e');
    }
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
Future<void> deleteCliente(int id) async {
  if (_connection == null) {
    throw Exception("Connection is not established");
  }

  try {
    await _connection!.execute(
      r'DELETE FROM clientes WHERE id = $1',
      parameters: [id],
    );
  } catch (e) {
    print('Erro ao deletar cliente: $e');
  }
}



  Future<void> updateEntregador(int id, String nome, String telefone, String cnh, String veiculo) async {
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
        id,       // $1
        nome,     // $2
        telefone, // $3
        cnh,      // $4
        veiculo,  // $5
      ],
    );
  } catch (e) {
    print('Erro ao atualizar entregador: $e');
  }
}

Future<void> updateCliente(int id, String nome, String telefone, String email, int? enderecoId) async {
  if (_connection == null) {
    throw Exception("Connection is not established");
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

   Future<void> createItensEntregaTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS itens_entrega (
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
        parameters:[descricao],
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
      return result.map((row) => {
        'id': row[0],
        'descricao': row[1],
      }).toList();
    } catch (e) {
      print('Erro ao obter itens: $e');
      return [];
    }
  }

}
