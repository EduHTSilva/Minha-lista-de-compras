import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/item_compra.dart';
import '../models/produto_remoto.dart';

class ListaComprasRepository {
  Database? _banco;

  // Abre o arquivo SQLite e cria a tabela na primeira execução.
  Future<Database> get _database async {
    if (_banco != null) return _banco!;

    final pasta = await getDatabasesPath();
    final caminho = join(pasta, 'compras.db');
    _banco = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE itens_compra (
            produto_id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            preco_centavos INTEGER NOT NULL CHECK (preco_centavos >= 0),
            quantidade INTEGER NOT NULL CHECK (quantidade BETWEEN 1 AND 99),
            comprado INTEGER NOT NULL CHECK (comprado IN (0, 1))
          )
        ''');
      },
    );
    return _banco!;
  }

  // READ: SELECT * FROM itens_compra ORDER BY nome.
  Future<List<ItemCompra>> listar() async {
    final db = await _database;
    final registros = await db.query('itens_compra', orderBy: 'nome');
    return registros.map(ItemCompra.fromMap).toList();
  }

  // CREATE: copia id, nome e preço do produto da API.
  // Primeira inclusão: quantidade 1 e pendente (comprado = 0).
  // Devolve false se o produto já estava na lista (o registro é mantido).
  // A consulta e a inserção usam o mesmo objeto da transação (txn).
  Future<bool> inserir(ProdutoRemoto produto) async {
    final db = await _database;
    return db.transaction<bool>((txn) async {
      final existentes = await txn.query(
        'itens_compra',
        where: 'produto_id = ?',
        whereArgs: [produto.id],
      );
      if (existentes.isNotEmpty) return false;

      await txn.insert(
        'itens_compra',
        {
          'produto_id': produto.id,
          'nome': produto.titulo,
          'preco_centavos': (produto.preco * 100).round(),
          'quantidade': 1,
          'comprado': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    });
  }

  // UPDATE: altera somente a quantidade do item com o ID informado.
  Future<void> atualizarQuantidade(int produtoId, int quantidade) async {
    if (quantidade < 1 || quantidade > 99) {
      throw ArgumentError('A quantidade deve estar entre 1 e 99.');
    }
    final db = await _database;
    final alterados = await db.update(
      'itens_compra',
      {'quantidade': quantidade},
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
    if (alterados == 0) throw StateError('Item não encontrado.');
  }

  // UPDATE: marca o item como comprado (1) ou pendente (0).
  Future<void> atualizarComprado(int produtoId, bool comprado) async {
    final db = await _database;
    final alterados = await db.update(
      'itens_compra',
      {'comprado': comprado ? 1 : 0},
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
    if (alterados == 0) throw StateError('Item não encontrado.');
  }

  // DELETE: apaga somente o registro com o ID informado.
  Future<void> excluir(int produtoId) async {
    final db = await _database;
    final excluidos = await db.delete(
      'itens_compra',
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
    if (excluidos == 0) throw StateError('Item não encontrado.');
  }
}
