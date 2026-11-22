class ItemCompra {
  final int produtoId;
  final String nome;
  final int precoCentavos;
  final int quantidade;
  final bool comprado;

  const ItemCompra({
    required this.produtoId,
    required this.nome,
    required this.precoCentavos,
    required this.quantidade,
    required this.comprado,
  });

  // Subtotal = preço em centavos × quantidade (conta só com inteiros).
  int get subtotalCentavos => precoCentavos * quantidade;

  // Conversão do objeto Dart para um mapa (SQLite).
  // comprado vira 0 (pendente) ou 1 (comprado).
  Map<String, Object?> toMap() => {
        'produto_id': produtoId,
        'nome': nome,
        'preco_centavos': precoCentavos,
        'quantidade': quantidade,
        'comprado': comprado ? 1 : 0,
      };

  // Conversão de mapa para objeto Dart.
  factory ItemCompra.fromMap(Map<String, Object?> mapa) {
    return ItemCompra(
      produtoId: (mapa['produto_id'] as num).toInt(),
      nome: mapa['nome'] as String,
      precoCentavos: (mapa['preco_centavos'] as num).toInt(),
      quantidade: (mapa['quantidade'] as num).toInt(),
      comprado: (mapa['comprado'] as num).toInt() == 1,
    );
  }
}

// Apresenta centavos como US$ com duas casas decimais (ex.: 4550 -> US$ 45,50).
String formatarCentavos(int centavos) {
  return 'US\$ ${(centavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';
}
