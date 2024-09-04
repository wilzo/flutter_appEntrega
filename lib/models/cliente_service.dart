import 'package:postgres/postgres.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';

class ClienteService {
  final DatabaseHelper _clienteservice = DatabaseHelper();
  Connection? _connection;

  // Conectar ao banco de dados
  Future<void> connect() async {
    _connection = _clienteservice.connection;
    if (_connection == null) {
      await _clienteservice.connect();
      _connection = _clienteservice.connection;
    }
  }

  Future<void> createClienteTable() async {
    if (_connection == null) {
      await connect();
    }
    await _connection!.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id SERIAL PRIMARY KEY,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      endereco_id INTEGER REFERENCES endereco(id) ON DELETE SET NULL
    )
  ''');
  }

  Future<bool> createCliente(String nome, String telefone, String email, int? enderecoId) async {
  if (_connection == null) {
    await connect();
  }

  String query = '''
  INSERT INTO clientes (nome, telefone, email, endereco_id)
  VALUES (\$1, \$2, \$3, \$4)
  ''';

  try {
    await _connection!.execute(
      query,
      parameters: [
        nome,
        telefone,
        email,
        enderecoId,
      ],
    );
    return true; // Retorna true se a inserção for bem-sucedida
  } catch (e) {
    print('Erro ao inserir cliente: $e');
    return false; // Retorna false se ocorrer um erro
  }
}


Future<List<Map<String, dynamic>>> listarClientes(String searchQuery) async {
  if (_connection == null) {
    await connect(); //VERIFICA CONEXAO COM O BANCO 
  }
// STRING SQL PARA BUSCAR OS DADOS DO CLIENTE
  String sql = ''' 
    SELECT c.id, c.nome, c.telefone, c.email, e.rua, e.numero, e.bairro, e.cidade, e.estado
    FROM clientes c
    LEFT JOIN endereco e ON c.endereco_id = e.id
    WHERE c.nome LIKE \$1 
       OR c.telefone LIKE \$1 
       OR c.email LIKE \$1
       OR e.rua LIKE \$1
       OR e.bairro LIKE \$1
    ORDER BY c.nome ASC
  ''';
// APOS BUSCAR OS DADOS ELE VAI COMEÇAR A MAPEAR ESSES DADOS 
  try {
    final results = await _connection!.execute(
      sql,
      parameters: ['%$searchQuery%'],  //Execução: A consulta é executada no banco de dados com o método execute, onde o searchQuery é passado como parâmetro. O parâmetro é colocado dentro de % para permitir a busca parcial.
    );

    return results.map((row) {
      return {
        'id': row[0],
        'nome': row[1],
        'telefone': row[2],
        'email': row[3],
        'rua': row[4],
        'numero': row[5],
        'bairro': row[6],
        'cidade': row[7],
        'estado': row[8],
      };
    }).toList();  // APÓS MAPEAR A LISTA ELE A RETORNA PARA UTILIZAR
  } catch (e) {
    print('Erro ao listar clientes: $e');
    return [];
  }
}
Future<void> deleteCliente(int id) async {
  if (_connection == null) {
    await connect();
  }

  try {
    await _connection!.execute(
      'DELETE FROM clientes WHERE id = \$1',
      parameters: [id],
    );
    print('Cliente deletado com sucesso.');
  } catch (e) {
    print('Erro ao deletar cliente: $e');
  }
}


Future<bool> canDeleteCliente(int id) async {
  if (_connection == null) {
    await connect();
  }

  try {
    // Verificar se o cliente possui entregas associadas
    final result = await _connection!.execute(
      'SELECT COUNT(*) FROM entregas WHERE id_Cliente = \$1',
      parameters: [id],
    );

    // Verifica se o cliente possui entregas associadas
    if (result.isNotEmpty && (result.first[0] as int?)! > 0) {
      return false;  // Não pode deletar
    } else {
      await _connection!.execute(
        'DELETE FROM clientes WHERE id = \$1',
        parameters: [id],
      );
      return true;  // Deleção bem-sucedida
    }
  } catch (e) {
    print('Erro ao deletar cliente: $e');
    return false;
  }
}

   Future<void> updateCliente(int id, String nome, String telefone, String email, int? enderecoId) async {
    if (_connection == null) {
      await connect(); //CONECTA NO BANCO
    }

    try {
      await _connection!.execute( //STRING SQL PARA DAR UPDATE NOS DADOS, ESSE TERMO '\$1' É UTILIZADO PARA MOSTRAR CADA PARAMETRO COM O EXECUTE NO DART. 
        '''
        UPDATE clientes
        SET nome = \$1, telefone = \$2, email = \$3, endereco_id = \$4
        WHERE id = \$5
        ''',
        parameters: [
          nome,
          telefone,
          email,
          enderecoId,
          id,
        ],
      );
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
      rethrow; // Re-lança a exceção para ser capturada no método chamador
    }
  }

  Future<Map<String, dynamic>?> listarClientePorId(int id) async {
    if (_connection == null) {
      await connect();
    }

    try {
      List<List<dynamic>> results = await _connection!.execute(
        '''
        SELECT c.id, c.nome, c.telefone, c.email, e.rua, e.numero, e.bairro, e.cidade, e.estado
        FROM clientes c
        LEFT JOIN endereco e ON c.endereco_id = e.id
        WHERE c.id = \$1
        ''',
        parameters: [id],
      );

      if (results.isEmpty) return null;
      
      var row = results.first;
      Map<String, dynamic> map = {
        'id': row[0],
        'nome': row[1],
        'telefone': row[2],
        'email': row[3],
        'rua': row[4],
        'numero': row[5],
        'bairro': row[6],
        'cidade': row[7],
        'estado': row[8],
      };
      return map;
    } catch (e) {
      print('Erro ao listar cliente por ID: $e');
      return null;
    }
  }
}
