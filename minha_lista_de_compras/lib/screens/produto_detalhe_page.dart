import 'package:flutter/material.dart';
import '../models/produto_remoto.dart';

class ProdutoDetalhePage extends StatefulWidget {
  final ProdutoRemoto produto;
  final Future<bool> Function(ProdutoRemoto)? onSalvar;

  const ProdutoDetalhePage({
    super.key,
    required this.produto,
    this.onSalvar,
  });

  @override
  State<ProdutoDetalhePage> createState() => _ProdutoDetalhePageState();
}

class _ProdutoDetalhePageState extends State<ProdutoDetalhePage> {
  bool _salvando = false;

  // Aguarda a gravação no SQLite antes de avisar o usuário.
  Future<void> _adicionarNaLista() async {
    if (_salvando || widget.onSalvar == null) return;
    setState(() => _salvando = true);

    try {
      final adicionou = await widget.onSalvar!(widget.produto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adicionou
                ? 'Produto adicionado à lista.'
                : 'Este produto já está na lista.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível adicionar: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 190,
            child: Image.network(
              produto.imagem,
              fit: BoxFit.contain,
              errorBuilder: (context, erro, pilha) =>
                  const Icon(Icons.image_not_supported, size: 70),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            produto.titulo,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Código: ${produto.id}'),
          Text(
            'Preço: US\$ '
            '${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
          ),
          const SizedBox(height: 16),
          Text(produto.descricao),
          if (widget.onSalvar != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvando ? null : _adicionarNaLista,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                _salvando ? 'Adicionando...' : 'Adicionar à lista',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
