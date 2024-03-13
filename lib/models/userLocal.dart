//classe a ser utilizada para transferência de dados do usuário
class UserLocal {
//definir variáveis de instância para representar
//os dados do usuário
  String? id;
  String? userName;
  String? password;
  String? email;

  UserLocal({this.id, this.userName, this.password, this.email});

  //método para converter dados deste objeto (UserLocal) em
  //formato compatível com o JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'password': password,
      'email': email,
    };
  }
}
