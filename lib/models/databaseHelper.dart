import 'package:postgres/postgres.dart';
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

  Future<void> createUser(String username, String email, String password) async {
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
    String nome,
    String telefone,
    String cnh,
    String veiculo) async {
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

  Future<void> createEndereco(
    String rua,
    String numero,
    String bairro,
    String cidade,
    String estado) async {
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

  Future<Map<String, dynamic>?> getEndereco(
    String rua,
    String numero,
    String bairro,
    String cidade,
    String estado) async {
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

  Future<bool> verificarEnderecoExiste(
    String rua,
    String numero,
    String bairro,
    String cidade,
    String estado) async {
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
    'SELECT id, rua, numero, bairro, cidade, estado FROM endereco'
  );
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
  
}
