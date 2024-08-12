import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Método para gerar um salt aleatório
  String generateSalt() {
    var random = Random.secure();
    var values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(values);
  }

  // Método para gerar o hash da senha usando o salt
  String generateSaltedHash(String password, String salt) {
    var codec = utf8;
    var key = utf8.encode(password + salt);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(codec.encode(password));
    return digest.toString();
  }

  Future<void> createUserTable() async {
    await _dbHelper.connect();
    await _dbHelper.connection!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        salt TEXT NOT NULL
      )
    ''');
  }

  Future<void> createUser(String username, String email, String password) async {
    await _dbHelper.connect();

    // Gerar um salt aleatório para o usuário
    String salt = generateSalt();

    // Gerar o hash da senha usando o salt
    String hashedPassword = generateSaltedHash(password, salt);

    // Armazenar o hash da senha e o salt no banco de dados
    await _dbHelper.connection!.execute(
      r'INSERT INTO users (username, email, password, salt) VALUES ($1, $2, $3, $4)',
      parameters: [username, email, hashedPassword, salt],
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    await _dbHelper.connect();
    final results = await _dbHelper.connection!.execute(
      r'SELECT * FROM users WHERE username = $1',
      parameters: [username],
    );
    if (results.isEmpty) return null;
    return results.first.toColumnMap();
  }

  Future<bool> loginUser(String email, String password) async {
    await _dbHelper.connect();

    // Buscar o usuário pelo email
    final result = await _dbHelper.connection!.execute(
      r'SELECT password, salt FROM users WHERE email = $1',
      parameters: [email],
    );

    if (result.isEmpty) return false;

    // Extrair o hash da senha e o salt do banco de dados
    String storedHash = result.first.toColumnMap()['password'];
    String storedSalt = result.first.toColumnMap()['salt'];

    // Gerar o hash da senha fornecida com o salt armazenado
    String hashedPassword = generateSaltedHash(password, storedSalt);

    // Verificar se o hash gerado corresponde ao hash armazenado
    return storedHash == hashedPassword;
  }
}
