import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class EnderecoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Connection? _connection;

  // Conectar ao banco de dados
  Future<void> connect() async {
    _connection = _databaseHelper.connection;
    if (_connection == null) {
      await _databaseHelper.connect();
      _connection = _databaseHelper.connection;
    }
  }

  // Criar a tabela de endereços com o campo link
  Future<void> createEnderecoTable() async {
    if (_connection == null) {
      await connect();
    }
    try {
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS endereco (
          id SERIAL PRIMARY KEY,
          rua TEXT NOT NULL,
          numero TEXT NOT NULL,
          bairro TEXT NOT NULL,
          cidade TEXT NOT NULL,
          estado TEXT NOT NULL,
          link TEXT NOT NULL
        )
      ''');
    } catch (e) {
      print('Erro ao criar tabela de endereços: $e');
    }
  }

  // Criar um novo endereço e armazenar o link gerado
  Future<void> createEndereco(String rua, String numero, String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect(); //CONECTA COM O BANCO
    }
    try {
      String link = 'https://maps.google.com/?q=${rua.replaceAll(' ', '+')},${bairro.replaceAll(' ', '+')},${numero.replaceAll(' ', '+')}'; //CRIA A STRING LINK, COM BASE NOS DADOS PASSADOS
      await     _connection!.execute(
        r'INSERT INTO endereco (rua, numero, bairro, cidade, estado, link) VALUES ($1, $2, $3, $4, $5, $6)', //FAZ O INSERT NO BANCO
        parameters: [rua, numero, bairro, cidade, estado, link],
      );
    } catch (e) {
      print('Erro ao criar endereço: $e');
    }
  }

  // Obter endereço por ID, incluindo o link
  Future<Map<String, dynamic>?> getEnderecoPorId(int id) async {
    if (_connection == null) {
      await connect();
    }
    try {
      List<List<dynamic>> results = await _connection!.execute(
        r'SELECT * FROM endereco WHERE id = $1',
        parameters: [id],
      );
      if (results.isEmpty) return null;
      return {
        'id': results.first[0],
        'rua': results.first[1],
        'numero': results.first[2],
        'bairro': results.first[3],
        'cidade': results.first[4],
        'estado': results.first[5],
        'link': results.first[6],
      };
    } catch (e) {
      print('Erro ao obter endereço por ID: $e');
      return null;
    }
  }

  // Atualizar um endereço e gerar um novo link
  Future<void> updateEndereco(int id, String rua, String numero, String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    try {
      String link = 'https://maps.google.com/?q=${rua.replaceAll(' ', '+')},${bairro.replaceAll(' ', '+')},${numero.replaceAll(' ', '+')}';
      await _connection!.execute(
        r'UPDATE endereco SET rua = $1, numero = $2, bairro = $3, cidade = $4, estado = $5, link = $6 WHERE id = $7',
        parameters: [rua, numero, bairro, cidade, estado, link, id],
      );
    } catch (e) {
      print('Erro ao atualizar endereço: $e');
    }
  }

 Future<bool> temClientesAssociados(int enderecoId) async {
    await connect();
    try {
      var result = await _connection!.execute(
        'SELECT COUNT(*) FROM clientes WHERE endereco_id = @enderecoId',
        parameters: [enderecoId],
      );

      final count = result.isNotEmpty ? result.first[0] as int : 0;
      return count > 0;
    } catch (e) {
      print('Erro ao verificar clientes associados: $e');
      return false;
    }
  }

Future<bool> deleteEndereco(int id) async {
  if (_connection == null) {
    await connect();
  }
  try {
    // Verifica se há clientes associados ao endereço
    List<List<dynamic>> clienteCount = await _connection!.execute(
      'SELECT COUNT(*) FROM clientes WHERE id = \$1',
      parameters: [id],
    );

    int numClientes = clienteCount.first[0];

    if (numClientes > 0) {
      // Retorna `false` se houver clientes associados, para que a UI possa mostrar um pop-up
      return false;
    }

    // Deleta o endereço se não houver clientes associados
    await _deleteEnderecoEClientes(id);
    return true;
  } catch (e) {
    print('Erro ao deletar endereço: $e');
    return false;
  }
}

// Método privado para deletar o endereço e os clientes associados
Future<void> _deleteEnderecoEClientes(int id) async {
  try {
    // Deletar clientes associados ao endereço
    await _connection!.execute(
      'DELETE FROM clientes WHERE id = \$1',
      parameters: [id],
    );

    // Deletar o endereço
    await _connection!.execute(
      'DELETE FROM endereco WHERE id = \$1',
      parameters: [id],
    );

    print('Endereço e clientes associados deletados com sucesso.');
  } catch (e) {
    print('Erro ao deletar endereço e clientes associados: $e');
  }
}
  // Verificar se um endereço já existe
  Future<bool> verificarEnderecoExiste(String rua, String numero, String bairro, String cidade, String estado) async {
    if (_connection == null) {
      await connect();
    }
    try {
      List<List<dynamic>> result = await _connection!.execute(
        r'SELECT COUNT(*) FROM endereco WHERE rua = $1 AND numero = $2 AND bairro = $3 AND cidade = $4 AND estado = $5',
        parameters: [rua, numero, bairro, cidade, estado],
      );
      return result[0][0] > 0;
    } catch (e) {
      print('Erro ao verificar se o endereço existe: $e');
      return false;
    }
  }

  // Listar endereços, incluindo o link
  Future<List<Map<String, dynamic>>> listarEnderecos([String searchQuery = '']) async {
    if (_connection == null) {
      await connect();
    }
    try {
      List<List<dynamic>> results = await _connection!.execute(
        '''
        SELECT id, rua, numero, bairro, cidade, estado, link
        FROM endereco
        WHERE rua LIKE \$1 OR numero LIKE \$1 OR bairro LIKE \$1 OR cidade LIKE \$1 OR estado LIKE \$1
        ORDER BY rua
        ''',
        parameters: ['%$searchQuery%'],
      );

      List<Map<String, dynamic>> enderecos = [];
      for (var row in results) {
        Map<String, dynamic> map = {
          'id': row[0],
          'rua': row[1],
          'numero': row[2],
          'bairro': row[3],
          'cidade': row[4],
          'estado': row[5],
          'link': row[6],
        };
        enderecos.add(map);
      }

      return enderecos;
    } catch (e) {
      print('Erro ao listar endereços: $e');
      return [];
    }
  }
  Future<String?> getLinkEnderecoById(int id) async {
    if (_connection == null) {
      await connect();
    }
    
    try {
      // Consultar o link do endereço com base no ID
      List<List<dynamic>> results = await _connection!.execute(
        'SELECT link FROM endereco WHERE id = @id',
        parameters: [
          id,
        ],
      );

      // Retornar o link se encontrado, caso contrário, retornar null
      if (results.isNotEmpty) {
        return results[0][0] as String;
      }
    } catch (e) {
      print('Erro ao obter o link do endereço por ID: $e');
    }

    return null; // Retorna null se não encontrou o endereço
  }

  Future<String?> pegarLink( id) async {
  // Verifica se a conexão está estabelecida, senão conecta
  if (_connection == null) {
    await connect(); // Estabelece a conexão se ainda não estiver conectada
  }

  // Executa a consulta SQL para obter o link baseado no id_endereco fornecido
  List<List<dynamic>> results = await _connection!.execute(
    r'SELECT link FROM endereco WHERE id = @id_endereco',
    parameters: [id],
  );

  // Verifica se a consulta retornou resultados e retorna o link ou null
  if (results.isNotEmpty) {
    return results[0][0] as String?;
  }
  return null; // Retorna null se não houver resultados
}

}
