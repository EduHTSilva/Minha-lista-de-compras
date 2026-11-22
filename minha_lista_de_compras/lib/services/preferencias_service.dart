import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  static const String _chaveTemaEscuro = 'tema_escuro';
  static const String _chaveSomentePendentes = 'somente_pendentes';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // READ: se a chave ainda não existir, o padrão é false.
  Future<bool> lerTemaEscuro() async {
    return await _prefs.getBool(_chaveTemaEscuro) ?? false;
  }

  Future<bool> lerSomentePendentes() async {
    return await _prefs.getBool(_chaveSomentePendentes) ?? false;
  }

  // UPDATE: grava a nova escolha do usuário.
  Future<void> salvarTemaEscuro(bool valor) async {
    await _prefs.setBool(_chaveTemaEscuro, valor);
  }

  Future<void> salvarSomentePendentes(bool valor) async {
    await _prefs.setBool(_chaveSomentePendentes, valor);
  }
}
