# P2 de Flutter — Minha Lista de Compras

- Aluno(a): _preencher_
- RA: _preencher_
- Turma: _preencher_
- Entrega: 27/11/2026
- Vídeo: _preencher o link (testar antes de enviar)_

## O que o app faz

- **Catálogo**: consulta a API DummyJSON (`https://dummyjson.com/products?limit=20`), mostra nome, preço e imagem e abre os **Detalhes** do produto com o botão **Adicionar à lista**.
- **Minha lista**: mostra os itens gravados no SQLite, altera a quantidade (1 a 99), marca como **comprado** ou **pendente**, exclui com confirmação e calcula o **total estimado**.
- **Configurações**: **Tema escuro** e **Mostrar somente pendentes**, restaurados ao fechar e reabrir o app.

## De onde vem cada dado

| Recurso           | O que guarda / fornece                                                                    |
|-------------------|-------------------------------------------------------------------------------------------|
| API REST          | Catálogo e dados dos detalhes: `id`, `title`, `price`, `description`, `thumbnail`         |
| SQLite            | Tabela `itens_compra` em `compras.db`: `produto_id`, `nome`, `preco_centavos`, `quantidade`, `comprado` |
| SharedPreferences | `tema_escuro` (bool, padrão false) e `somente_pendentes` (bool, padrão false)             |

O preço é gravado em centavos, com `(preco * 100).round()`, para que subtotal e total sejam contas com inteiros. O `produto_id` é a chave primária, então o banco não aceita o mesmo produto duas vezes.

## Organização dos arquivos

Segue a mesma estrutura do capítulo "Dois CRUDs" (models, data, widgets, screens) e do Capítulo 10 (services e páginas da API).

| Pasta / arquivo                              | Responsabilidade                                                  |
|----------------------------------------------|-------------------------------------------------------------------|
| `lib/main.dart`                              | `MeuApp` (lê as preferências e aplica o tema) e `HomePage` (NavigationBar) |
| `lib/models/produto_remoto.dart`             | Produto da API (`fromJson`)                                       |
| `lib/models/item_compra.dart`                | Item do banco local (`toMap` / `fromMap`)                         |
| `lib/services/produtos_api_service.dart`     | `buscarProdutos()`: GET, status 200 e chave `products`            |
| `lib/services/preferencias_service.dart`     | Lê e grava `tema_escuro` e `somente_pendentes` (SharedPreferencesAsync) |
| `lib/data/lista_compras_repository.dart`     | SQLite: `listar`, `inserir`, `atualizarQuantidade`, `atualizarComprado`, `excluir` |
| `lib/widgets/quantidade_dialog.dart`         | Formulário que valida a quantidade (1 a 99)                       |
| `lib/screens/produtos_api_page.dart`         | Catálogo com FutureBuilder, Atualizar e Tentar novamente          |
| `lib/screens/produto_detalhe_page.dart`      | Detalhes e botão Adicionar à lista                                |
| `lib/screens/lista_compras_page.dart`        | Minha lista: quantidade, comprado/pendente, exclusão e total      |
| `lib/screens/configuracoes_page.dart`        | Tema escuro e Mostrar somente pendentes                           |

## Como executar no Android (VS Code)

1. Abra a pasta `minha_lista_de_compras` no VS Code.
2. No terminal do VS Code, execute uma vez:

```
flutter create --platforms android .
flutter pub get
flutter analyze
```

3. Abra o emulador Android: `Ctrl+Shift+P` → **Flutter: Launch Emulator**, ou pelo canto inferior direito da barra de status. Não selecione Windows nem Chrome: o SQLite deste projeto funciona no Android.
4. Confira com `flutter devices` e execute com `flutter run -d ID_DO_EMULADOR`, ou abra `lib/main.dart` e pressione **F5**.

A permissão de internet já está no `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Prática guiada — Capítulo 10

1. Abri `https://dummyjson.com/products?limit=12` no navegador e localizei a lista `products` e os campos `id`, `title` e `price`.
2. Executei o catálogo do capítulo e abri os detalhes de um produto.
3. Troquei `limit=12` por `limit=5`, atualizei e apareceram cinco produtos.
4. Desliguei a internet, pedi uma nova consulta e apareceu a mensagem de erro. Religuei e o botão **Tentar novamente** carregou o catálogo.

**Captura 1: catálogo com cinco produtos**

![limit=5](docs/pratica_limit5.png)

**Captura 2: mensagem de erro sem conexão**

![erro](docs/pratica_erro.png)

**Como o JSON vira `ProdutoRemoto`:** o `http.get` devolve a resposta e o serviço confere se o status é 200. Depois, o `jsonDecode(utf8.decode(resposta.bodyBytes))` transforma o texto em um `Map`. A lista fica na chave `products`, então o código confere se ela é uma `List` e, num `for`, passa cada item para `ProdutoRemoto.fromJson`. O `fromJson` lê `id`, `title`, `description`, `price` (convertido com `toDouble()`) e `thumbnail` e cria o objeto. No fim, a função devolve uma `List<ProdutoRemoto>` para o `FutureBuilder` mostrar na tela.

## Dados de teste

| Item | Produto do catálogo (id)           | Preço anotado | Quantidade usada | Observação                       |
|------|------------------------------------|--------------:|-----------------:|----------------------------------|
| 1    | Essence Mascara Lash Princess (1)  | US$ 9,99      | 3                | Adicionar duas vezes; marcar comprado |
| 2    | Eyeshadow Palette with Mirror (2)  | US$ 19,99     | 1                | Excluir no T7                    |

Conferir os preços no catálogo antes de adicionar. Se forem diferentes, refazer as contas abaixo.

Fórmulas usadas: subtotal 1 = 3 × 9,99 = 29,97; subtotal 2 = 1 × 19,99 = 19,99; total = 29,97 + 19,99 = 49,96.

## Resultados esperados

| Momento                                        | Itens no banco | Itens visíveis | Total estimado |
|------------------------------------------------|---------------:|---------------:|---------------:|
| Após adicionar o item 1 duas vezes (T3)        | 1              | 1              | US$ 9,99       |
| Após adicionar o item 2 e mudar o 1 para 3 (T4)| 2              | 2              | US$ 49,96      |
| Após tentar gravar 0 e 100 (sem mudança)       | 2              | 2              | US$ 49,96      |
| Item 1 comprado + filtro ligado (T5)           | 2              | 1              | US$ 49,96      |
| Após reabrir o app (T6)                        | 2              | 1              | US$ 49,96      |
| Após cancelar a exclusão do item 2 (T7)        | 2              | conforme filtro | US$ 49,96     |
| Após confirmar a exclusão do item 2 (T7)       | 1              | conforme filtro | US$ 29,97     |

## Testes de aceitação (T1 a T7)

Aparelho / emulador: _preencher_

| Teste | O que foi feito                                                        | Resultado observado | Status |
|-------|------------------------------------------------------------------------|---------------------|--------|
| T1    | Abrir o catálogo com internet e selecionar um produto                  | _preencher_         | _OK / Falhou_ |
| T2    | Sem rede, tocar em Atualizar; religar e tocar em Tentar novamente      | _preencher_         |        |
| T3    | Adicionar o mesmo produto duas vezes e abrir Minha lista               | _preencher_         |        |
| T4    | Adicionar outro produto; mudar o primeiro para 3; tentar 0 e 100       | _preencher_         |        |
| T5    | Marcar o primeiro como comprado e ligar o filtro de pendentes          | _preencher_         |        |
| T6    | Ligar tema escuro e filtro; fechar e reabrir o app                     | _preencher_         |        |
| T7    | Sem rede: editar um item, cancelar uma exclusão e depois confirmar     | _preencher_         |        |

`flutter analyze`: _preencher_

## Uso de IA

Foram usadas as seguintes ferramentas de IA:
_preencher_

Finalidade:
_preencher_
