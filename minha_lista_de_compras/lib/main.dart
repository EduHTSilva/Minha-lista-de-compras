import 'package:flutter/material.dart';

import 'data/lista_compras_repository.dart';
import 'models/produto_remoto.dart';
import 'screens/configuracoes_page.dart';
import 'screens/lista_compras_page.dart';
import 'screens/produtos_api_page.dart';
import 'services/preferencias_service.dart';

// As preferências são lidas antes de runApp; por isso main é async
// e chama WidgetsFlutterBinding.ensureInitialized() primeiro.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencias = PreferenciasService();
  final temaEscuro = await preferencias.lerTemaEscuro();
  final somentePendentes = await preferencias.lerSomentePendentes();

  runApp(
    MeuApp(
      preferencias: preferencias,
      temaEscuroInicial: temaEscuro,
      somentePendentesInicial: somentePendentes,
    ),
  );
}

// MeuApp guarda o tema e o filtro perto do MaterialApp.
class MeuApp extends StatefulWidget {
  final PreferenciasService preferencias;
  final bool temaEscuroInicial;
  final bool somentePendentesInicial;

  const MeuApp({
    super.key,
    required this.preferencias,
    required this.temaEscuroInicial,
    required this.somentePendentesInicial,
  });

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  late bool _temaEscuro = widget.temaEscuroInicial;
  late bool _somentePendentes = widget.somentePendentesInicial;

  // Grava primeiro; a tela muda depois que a gravação termina.
  Future<void> _alterarTema(bool valor) async {
    await widget.preferencias.salvarTemaEscuro(valor);
    if (!mounted) return;
    setState(() => _temaEscuro = valor);
  }

  Future<void> _alterarFiltro(bool valor) async {
    await widget.preferencias.salvarSomentePendentes(valor);
    if (!mounted) return;
    setState(() => _somentePendentes = valor);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Lista de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _temaEscuro ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        temaEscuro: _temaEscuro,
        somentePendentes: _somentePendentes,
        onTemaEscuro: _alterarTema,
        onSomentePendentes: _alterarFiltro,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool temaEscuro;
  final bool somentePendentes;
  final Future<void> Function(bool) onTemaEscuro;
  final Future<void> Function(bool) onSomentePendentes;

  const HomePage({
    super.key,
    required this.temaEscuro,
    required this.somentePendentes,
    required this.onTemaEscuro,
    required this.onSomentePendentes,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ListaComprasRepository _repositorio = ListaComprasRepository();
  int _indice = 0;

  // Chamado pela tela de detalhes: true = adicionou, false = já existia.
  Future<bool> _salvarProduto(ProdutoRemoto produto) async {
    return _repositorio.inserir(produto);
  }

  // Cada aba é criada ao ser aberta; assim Minha lista relê o banco.
  Widget _paginaAtual() {
    if (_indice == 0) {
      return ProdutosApiPage(onSalvar: _salvarProduto);
    }
    if (_indice == 1) {
      return ListaComprasPage(
        repositorio: _repositorio,
        somentePendentes: widget.somentePendentes,
      );
    }
    return ConfiguracoesPage(
      temaEscuro: widget.temaEscuro,
      somentePendentes: widget.somentePendentes,
      onTemaEscuro: widget.onTemaEscuro,
      onSomentePendentes: widget.onSomentePendentes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginaAtual(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (valor) {
          setState(() => _indice = valor);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Minha lista',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
