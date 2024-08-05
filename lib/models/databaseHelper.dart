import 'package:postgres/postgres.dart';
import '../database/config.dart';

class DatabaseHelper {
  Connection? _connection;

  Future<void> connect() async {
    _connection = await database();
  }
  Connection? get connection => _connection;

  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
    }
  }

}