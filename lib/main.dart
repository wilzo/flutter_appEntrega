import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/dataBaseHelper.dart'; // Certifique-se de que o caminho está correto
import 'package:flutter_projeto/models/user_services.dart';
import 'package:flutter_projeto/pages/login/login_page.dart'; // Adicione os imports necessários para o seu app
import 'package:flutter_projeto/pages/main/main_page.dart';
import 'package:flutter_projeto/models/itens_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inicializa o Flutter

  final DatabaseHelper _databaseHelper = DatabaseHelper();
    final UserService _userService = UserService();


  try {
    // Conecta ao banco de dados
    await _databaseHelper.connect();

    // Cria a tabela de usuários se não existir
    await _userService.createUserTable(); 

    // Cria um usuário
    await _userService.createUser('testuser', 'testuser@example.com', 'password123');

    // Tenta logar o usuário
    bool isAuthenticated = await _userService.loginUser('testuser', 'password123');
    print('User authentication status: $isAuthenticated');

    // Fecha a conexão
    await _databaseHelper.closeConnection();
  } catch (e) {
    print('Erro ao conectar ou operar no banco de dados: $e');
  }

  // Inicia o app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Ajuste para a página inicial do seu app
    );
  }
}
