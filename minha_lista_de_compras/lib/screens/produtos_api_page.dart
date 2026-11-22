import 'package:flutter/material.dart';
import '../models/produto_remoto.dart';
import '../services/produtos_api_service.dart';
import 'produto_detalhe_page.dart';

class ProdutosApiPage extends StatefulWidget {
  final Future<bool> Function(ProdutoRemoto)? onSalvar;

  const ProdutosApiPage({super.key, this.onSalvar});

  @override
  State<ProdutosApiPage> createState() => _ProdutosApiPageState();
}

class _ProdutosApiPageState extends State<ProdutosApiPage> {
  final ProdutosApiService _servico = ProdutosApiService();
  late Future<List<ProdutoRemoto>> _produtosFuturos;

  @override
  void initState() {
    super.initState();
    // A consulta começa uma vez; o Future fica guardado no estado.
    _produtosFuturos = _servico.buscarProdutos();
  }

  // Atualizar e Tentar novamente criam um novo Future (novo GET).
  void _recarregar() {
    setState(() {
      _produtosFuturos = _servico.buscarProdutos();
    });
  }

  void _abrirDetalhes(ProdutoRemoto produto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProdutoDetalhePage(
          produto: produto,
          onSalvar: widget.onSalvar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ProdutoRemoto>>(
        future: _produtosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível consultar a API. '
                      'Verifique a conexão com a internet.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _recarregar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final produtos = snapshot.data ?? [];
          if (produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto retornado.'));
          }

          return ListView.separated(
            itemCount: produtos.length,
            separatorBuilder: (context, indice) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              final produto = produtos[indice];
              return ListTile(
                leading: SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.network(
                    produto.imagem,
                    errorBuilder: (context, erro, pilha) =>
                        const Icon(Icons.image_outlined),
                  ),
                ),
                title: Text(produto.titulo),
                subtitle: Text(
                  'US\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _abrirDetalhes(produto),
              );
            },
          );
        },
      ),
    );
  }
}
