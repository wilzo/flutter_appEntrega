import 'package:flutter_projeto/pages/home/home_page.dart';
import 'package:flutter_projeto/pages/profile/profile_page.dart';
import 'package:flutter_projeto/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Commodities"),
      ),
      body: [
        HomePage(), //representa a posição zero da lista
        ProfilePage(), //representa a posição um da lista
        SettingsPage(), //representa a posição dois da lista
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        indicatorShape: const CircleBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_4_rounded),
            label: 'Perfil de Usuário',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_applications),
            label: 'Configurações',
          )
        ],
      ),
    );
  }
}
