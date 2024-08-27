import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/dataBaseHelper.dart'; // Certifique-se de que o caminho está correto
import 'package:flutter_projeto/models/user_services.dart';
import 'package:flutter_projeto/pages/login/login_page.dart'; // Ajustado para referência correta

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _databaseHelper.connect(); // Conectar ao banco de dados ao inicializar
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    String username = userNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos são obrigatórios')),
      );
      return;
    }

    try {
      await _userService.createUser(username, email, password);
      // Exibir o pop-up de sucesso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cadastro realizado'),
            content: Text('Seu cadastro foi realizado com sucesso!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o pop-up
                  Navigator.of(context).pop(); // Navega de volta para a página de login
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Erro ao criar usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 400.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/entrega.jpg',
                    height: 200,
                    fit: BoxFit.fitHeight,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ENTREGA JA',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 240, 5, 5),
                        ),
                      ),
                      const Text(
                        'GERENCIE SUAS ENTREGAS',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Nome do usuário',
                style: TextStyle(color: Colors.red),
              ),
              TextFormField(
                controller: userNameController,
                decoration: const InputDecoration(
                  hintText: 'Nome do usuário',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'E-mail',
                style: TextStyle(color: Colors.red),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'email@email.com',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Senha',
                style: TextStyle(color: Colors.red),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '••••••••',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Já tem uma conta? Entre',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
