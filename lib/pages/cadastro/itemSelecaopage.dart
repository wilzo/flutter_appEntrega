import 'package:flutter/material.dart';
import 'package:flutter_projeto/models/databaseHelper.dart';
import 'package:flutter_projeto/models/itens_service.dart';


class ItemSelecaoPage extends StatefulWidget {
  @override
  _ItemSelecaoPageState createState() => _ItemSelecaoPageState();
}

class _ItemSelecaoPageState extends State<ItemSelecaoPage> {
  final TextEditingController _descricaoController = TextEditingController();
    final ItensService _itensService = ItensService();

  bool _isLoading = false;

  void _adicionarItem() async {
    setState(() {
      _isLoading = true;
    });

    String descricao = _descricaoController.text.trim();

    if (descricao.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descrição é obrigatória')),
      );
      return;
    }

    try {
      final int? idNovoItem = await _itensService.createItem(descricao);
      _showSuccessDialog(idNovoItem);
    } catch (e) {
      print('Erro ao adicionar item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar item: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(int? idNovoItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Adicionado com Sucesso'),
          content: Text('O item foi adicionado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context, idNovoItem); // Retorna o ID do novo item
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _adicionarItem,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Adicionar Item'),
            ),
          ],
        ),
      ),
    );
  }
}
