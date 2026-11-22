import 'package:flutter/material.dart';
import '../data/lista_compras_repository.dart';
import '../models/item_compra.dart';
import '../widgets/quantidade_dialog.dart';

class ListaComprasPage extends StatefulWidget {
  final ListaComprasRepository repositorio;
  final bool somentePendentes;

  const ListaComprasPage({
    super.key,
    required this.repositorio,
    required this.somentePendentes,
  });

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  List<ItemCompra> _itens = [];
  bool _carregando = true;
  bool _processando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // READ: lê os itens do SQLite (funciona sem internet).
  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final itens = await widget.repositorio.listar();
      if (!mounted) return;
      setState(() {
        _itens = itens;
        _erro = null;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erro = 'Falha ao carregar: $erro');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // Com o filtro ligado, aparecem só os pendentes.
  List<ItemCompra> get _itensVisiveis {
    if (!widget.somentePendentes) return _itens;
    return _itens.where((item) => !item.comprado).toList();
  }

  // O total usa TODOS os itens, inclusive comprados e ocultos pelo filtro.
  int get _totalCentavos {
    return _itens.fold<int>(0, (soma, item) => soma + item.subtotalCentavos);
  }

  // UPDATE: alterna entre comprado e pendente.
  Future<void> _alternarComprado(ItemCompra item) async {
    if (_processando) return;
    setState(() => _processando = true);
    try {
      await widget.repositorio.atualizarComprado(
        item.produtoId,
        !item.comprado,
      );
      await _carregar();
    } catch (erro) {
      if (mounted) _mensagem('Erro ao atualizar: $erro');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  // UPDATE: o diálogo valida 1 a 99; valores inválidos não são gravados.
  Future<void> _editarQuantidade(ItemCompra item) async {
    if (_processando) return;

    final quantidade = await showDialog<int>(
      context: context,
      builder: (_) => QuantidadeDialog(item: item),
    );
    if (quantidade == null || !mounted) return;

    setState(() => _processando = true);
    try {
      await widget.repositorio.atualizarQuantidade(item.produtoId, quantidade);
      await _carregar();
      if (mounted) _mensagem('Quantidade atualizada.');
    } catch (erro) {
      if (mounted) _mensagem('Erro ao salvar: $erro');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  // DELETE: solicita confirmação antes de excluir.
  Future<void> _excluir(ItemCompra item) async {
    if (_processando) return;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text('Deseja excluir "${item.nome}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() => _processando = true);
    try {
      await widget.repositorio.excluir(item.produtoId);
      await _carregar();
      if (mounted) _mensagem('Item excluído.');
    } catch (erro) {
      if (mounted) _mensagem('Erro ao excluir: $erro');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_itens.isEmpty) {
      return const Center(child: Text('Ainda não há itens na lista.'));
    }

    final visiveis = _itensVisiveis;
    if (visiveis.isEmpty) {
      return const Center(child: Text('Não há itens pendentes.'));
    }

    return ListView.builder(
      itemCount: visiveis.length,
      itemBuilder: (context, indice) {
        final item = visiveis[indice];
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: item.comprado,
              onChanged: _processando ? null : (_) => _alternarComprado(item),
            ),
            title: Text(
              item.nome,
              style: TextStyle(
                decoration: item.comprado ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${item.quantidade} × ${formatarCentavos(item.precoCentavos)}'
              ' = ${formatarCentavos(item.subtotalCentavos)}\n'
              '${item.comprado ? 'Comprado' : 'Pendente'}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Alterar quantidade',
                  onPressed:
                      _processando ? null : () => _editarQuantidade(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  onPressed: _processando ? null : () => _excluir(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha lista'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.somentePendentes)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Filtro ligado: mostrando somente pendentes.'),
            ),
          Expanded(child: _conteudo()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Itens: ${_itens.length}   '
              'Total estimado: ${formatarCentavos(_totalCentavos)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
