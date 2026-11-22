import 'package:flutter/material.dart';
import '../models/item_compra.dart';

class QuantidadeDialog extends StatefulWidget {
  final ItemCompra item;

  const QuantidadeDialog({super.key, required this.item});

  @override
  State<QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<QuantidadeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantidadeController;

  @override
  void initState() {
    super.initState();
    _quantidadeController = TextEditingController(
      text: '${widget.item.quantidade}',
    );
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final quantidade = int.parse(_quantidadeController.text.trim());

    // O diálogo só valida; quem grava no banco é a tela.
    Navigator.of(context).pop(quantidade);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar quantidade'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.item.nome),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade (1 a 99)',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final quantidade = int.tryParse((valor ?? '').trim());
                  if (quantidade == null || quantidade < 1 || quantidade > 99) {
                    return 'Informe um número inteiro de 1 a 99.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: const Text('Salvar')),
      ],
    );
  }
}
