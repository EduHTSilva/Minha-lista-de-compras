class ProdutoRemoto {
  final int id;
  final String titulo;
  final String descricao;
  final double preco;
  final String imagem;

  const ProdutoRemoto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.imagem,
  });

  // Transforma o mapa do JSON em um objeto Dart.
  factory ProdutoRemoto.fromJson(Map<String, dynamic> json) {
    return ProdutoRemoto(
      id: (json['id'] as num).toInt(),
      titulo: json['title'] as String,
      descricao: json['description'] as String? ?? '',
      preco: (json['price'] as num).toDouble(),
      imagem: json['thumbnail'] as String? ?? '',
    );
  }
}
