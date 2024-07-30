import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> createUserTable() async {
    await _dbHelper.connect();
    await _dbHelper.connection!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<void> createUser(String username, String email, String password) async {
    await _dbHelper.connect();
    await _dbHelper.connection!.execute(
      r'INSERT INTO users (username, email, password) VALUES ($1, $2, $3)',
      parameters: [username, email, password],
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    await _dbHelper.connect();
    final results = await _dbHelper.connection!.execute(
      'SELECT * FROM users WHERE username = @username',
      parameters: [username],
    );
    if (results.isEmpty) return null;
    return results.first.toColumnMap();
  }

  Future<bool> loginUser(String email, String password) async {
    await _dbHelper.connect();
    final result = await _dbHelper.connection!.execute(
      r'SELECT COUNT(*) AS count FROM users WHERE email = $1 AND password = $2',
      parameters: [email, password],
    );
    return result.isNotEmpty && result[0][0] == 1;
  }
}
