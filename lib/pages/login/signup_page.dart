import 'package:flutter_projeto/models/userLocal.dart';
import 'package:flutter_projeto/services/user_services.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserLocal user = UserLocal();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 50, right: 50, top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registre-se',
                        style: TextStyle(
                            color: Color.fromARGB(255, 240, 119, 5),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Aplicativo para Commodities",
                        style: TextStyle(
                            color: Color.fromARGB(255, 240, 119, 5),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "multi-funcional",
                        style: TextStyle(
                            color: Color.fromARGB(255, 240, 119, 5),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/entrega.jpg',
                      height: 150,
                      width: 150,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: userNameController,
                decoration: const InputDecoration(
                  label: Text('Nome do usuário'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  label: Text('E-mail'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.2),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    label: Text("Senha"),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.2),
                    )),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  //utilizando objeto DTO
                  user.userName = userNameController.text;
                  user.password = passwordController.text;
                  user.email = emailController.text;
                  //criando instância da classe UserServices
                  UserServices userServices = UserServices();

                  //utilizando a instância da classe UserServices
                  userServices.signUp(
                    user.userName.toString(),
                    user.email.toString(),
                    user.password.toString(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 1.8,
                  minimumSize: const Size.fromHeight(60),
                  shape: LinearBorder.bottom(),
                ),
                child: const Text(
                  "Registrar",
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 50, 3),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Center(
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 50, 3),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/googlee.png',
                      height: 50,
                    ),
                    const Text(
                      "Login com Google",
                      style: TextStyle(
                        color: Color.fromARGB(255, 1, 50, 3),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Já tem uma conta?'),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Login',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
