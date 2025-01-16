import 'package:shared_preferences/shared_preferences.dart';

final preferencesDataSource = PreferencesDataSource();
class PreferencesDataSource {


  Future<void> saveIP(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', value);
  }

  Future<String> loadIP() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString('server_ip');
    return savedValue ?? "";
  }

  Future<void> clearIP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_ip');
  }

}