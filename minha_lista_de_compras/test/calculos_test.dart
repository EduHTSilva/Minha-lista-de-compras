import 'package:flutter_test/flutter_test.dart';
import 'package:minha_lista_de_compras/models/item_compra.dart';
import 'package:minha_lista_de_compras/models/produto_remoto.dart';

void main() {
  test('fromJson converte as chaves da DummyJSON', () {
    final produto = ProdutoRemoto.fromJson({
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'Descrição',
      'price': 9.99,
      'thumbnail': '',
    });
    expect(produto.id, 1);
    expect(produto.preco, 9.99);
  });

  test('exemplo do roteiro: 12,50 x 3 + 8,00 x 1 = US\$ 45,50', () {
    const itens = [
      ItemCompra(
        produtoId: 1,
        nome: 'A',
        precoCentavos: 1250,
        quantidade: 3,
        comprado: true,
      ),
      ItemCompra(
        produtoId: 2,
        nome: 'B',
        precoCentavos: 800,
        quantidade: 1,
        comprado: false,
      ),
    ];
    final total = itens.fold<int>(0, (soma, i) => soma + i.subtotalCentavos);
    expect(formatarCentavos(total), 'US\$ 45,50');
  });
}
