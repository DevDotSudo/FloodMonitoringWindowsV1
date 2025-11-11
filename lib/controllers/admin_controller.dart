import 'package:flood_monitoring/models/admin_registration.dart';
import 'package:flood_monitoring/services/mysql_services/admin_service.dart';
import 'package:flood_monitoring/utils/encrypt_util.dart';

class AdminController {
  final AdminService _adminService;

  AdminController(this._adminService);

  Future<bool> login(String username, String password) async {
    try {
      final encryptedUsername = Encryption.encryptText(username);
      return await _adminService.login(encryptedUsername, password);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<String?> getAdminNameByUsername(String username) async {
    try {
      return await _adminService.getAdminNameByUsername(username);
    } catch (e) {
      throw Exception('Failed to retrieve admin name: $e');
    }
  }

  Future<AdminRegistration?> getAdminByUsername(String username) async {
    try {
      return await _adminService.getAdminByUsername(username);
    } catch (e) {
      throw Exception('Failed to retrieve admin : $e');
    }
  }

  Future<void> delete(String id) async {
    await _adminService.deleteAdmin(id);
  }
}
