# 📦 App de Entregas - Flutter + PostgreSQL

Um sistema completo de gerenciamento de entregas, desenvolvido com **Flutter Desktop** e banco de dados **PostgreSQL**. O aplicativo permite o cadastro e gerenciamento de clientes, entregadores, endereços e entregas, além da integração com **mapas interativos** via Mapbox.

---

## 🧭 Funcionalidades principais

- 👤 Cadastro e listagem de **clientes**
- 🏍️ Cadastro e controle de **entregadores**
- 🏠 Registro e seleção de **endereços**
- 📦 Criação e visualização de **entregas**
- 🗺️ Visualização de **localizações em mapa** (via Mapbox/Leaflet)
- 🧹 Edição e exclusão de dados com segurança
- 🎨 Interface estilizada e responsiva com foco em usabilidade

---

## 💻 Tecnologias utilizadas

- [Flutter Desktop](https://docs.flutter.dev/desktop) (Windows)
- [Dart](https://dart.dev/)
- [PostgreSQL](https://www.postgresql.org/)
- [Mapbox](https://www.mapbox.com/)
- [Leaflet (via flutter_map)](https://pub.dev/packages/flutter_map)
- [Material Design](https://m3.material.io/)

---

## 📁 Estrutura do Projeto

lib/
├── main.dart # Entry point
├── pages/ # Telas principais (cadastro, listagem, mapa)
│ ├── clientes/
│ ├── entregadores/
│ ├── enderecos/
│ └── entregas/
├── database/ # Conexão e manipulação do PostgreSQL
│ ├── db_config.dart
│ └── dao/ # Métodos SQL para CRUD
├── widgets/ # Componentes reutilizáveis
└── utils/ # Funções auxiliares e modelos

🌍 Mapa interativo
O sistema permite vincular localizações reais a cada endereço.

As localizações são exibidas em um mapa interativo com marcadores para visualizar os pontos de entrega.

Integração com o plugin flutter_map + Mapbox.

🤝 Contribuições
Contribuições são bem-vindas! Sinta-se livre para abrir issues ou pull requests.

👨‍💻 Autor
Desenvolvido por Wilzo (Junior Wilson)

