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

  // Adicione mais métodos conforme necessário, por exemplo:
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


Future<bool> loginUser(String username, String password) async {
  try {
    final conn = await database(); // Presumindo que você tem uma função para obter a conexão

    // Execute a consulta usando o método `query` correto
    final result = await conn.query(
      '''
      SELECT COUNT(*) AS count
      FROM users
      WHERE username = username AND password = password
      ''',
      substitutionValues: {
        'username': username,
        'password': password,
      },
    );

    await conn.close(); // Feche a conexão após a consulta

    // Verifique se a consulta retornou algum resultado e se a contagem é igual a 1
    if (result.isNotEmpty && result[0][0] == 1) {
      return true; // Usuário autenticado com sucesso
    } else {
      return false; // Credenciais inválidas
    }
  } catch (e) {
    print('Error logging in: $e');
    return false; // Retorne false em caso de erro
  }
}
}