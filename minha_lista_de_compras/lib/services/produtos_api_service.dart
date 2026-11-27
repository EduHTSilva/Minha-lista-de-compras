import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto_remoto.dart';

class ProdutosApiService {
  Future<List<ProdutoRemoto>> buscarProdutos() async {
    final url = Uri.parse(
      'https://dummyjson.com/products?limit=5',
    );

    // timeout impede uma espera indefinida.
    final resposta = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    if (resposta.statusCode != 200) {
      throw Exception('Erro HTTP: ${resposta.statusCode}');
    }

    // bodyBytes evita problemas com caracteres UTF-8.
    final dynamic dados = jsonDecode(
      utf8.decode(resposta.bodyBytes),
    );

    if (dados is! Map<String, dynamic>) {
      throw const FormatException('Resposta JSON inesperada.');
    }

    final dynamic itens = dados['products'];
    if (itens is! List) {
      throw const FormatException('Campo products ausente.');
    }

    return itens.map((item) {
      return ProdutoRemoto.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();
  }
}
