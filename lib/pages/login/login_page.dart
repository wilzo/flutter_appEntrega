import 'package:flutter_projeto/models/userLocal.dart';
import 'package:flutter_projeto/pages/main/main_page.dart';
import 'package:flutter_projeto/pages/login/signup_page.dart';
import 'package:flutter_projeto/services/user_services.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  UserLocal _userLocal = UserLocal();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50, top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/images/entrega.jpg',
                height: 80,
                width: 100,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              'ENTREGAJA APP!!!',
              style: TextStyle(
                  color: Color.fromARGB(255, 252, 9, 1),
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              "Organize suas entregas",
              style: TextStyle(
                  color: Color.fromARGB(255, 252, 9, 1),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _emailController,
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
              controller: _passwordController,
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
            Container(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              alignment: Alignment.centerRight,
              child: const Text(
                'Esqueceu a senha?',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                UserServices userServices = UserServices();

                _userLocal.email = _emailController.text;
                _userLocal.password = _passwordController.text;

                Future<bool> ok = userServices.signIn(
                  _userLocal.email.toString(),
                  _userLocal.password.toString(),
                );
                if (await ok) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 1.8,
                minimumSize: const Size.fromHeight(60),
                shape: LinearBorder.bottom(),
              ),
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 50, 3),
                  fontSize: 19,
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
                    'assets/images/google.png',
                    height: 3,
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
            Container(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Ainda não tem conta?'),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registre-se aqui',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
