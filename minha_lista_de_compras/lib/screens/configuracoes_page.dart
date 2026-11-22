import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatelessWidget {
  final bool temaEscuro;
  final bool somentePendentes;
  final Future<void> Function(bool) onTemaEscuro;
  final Future<void> Function(bool) onSomentePendentes;

  const ConfiguracoesPage({
    super.key,
    required this.temaEscuro,
    required this.somentePendentes,
    required this.onTemaEscuro,
    required this.onSomentePendentes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema escuro'),
            value: temaEscuro,
            onChanged: (valor) => onTemaEscuro(valor),
          ),
          SwitchListTile(
            title: const Text('Mostrar somente pendentes'),
            subtitle: const Text('Oculta da Minha lista os itens comprados.'),
            value: somentePendentes,
            onChanged: (valor) => onSomentePendentes(valor),
          ),
        ],
      ),
    );
  }
}
