import 'package:flood_monitoring/dao/mysql/admin_dao.dart';
import 'package:flood_monitoring/models/admin_registration.dart';
import 'package:flood_monitoring/utils/encrypt_util.dart';
import 'package:flood_monitoring/utils/hash_util.dart';

class AdminService {
  final AdminDAO _adminDAO = AdminDAO();

  Future<void> registerAdmin(AdminRegistration admin) async {
    final encryptedAdmin = AdminRegistration(
      id: admin.id,
      username: Encryption.encryptText(admin.username),
      fullName: Encryption.encryptText(admin.fullName),
      email: Encryption.encryptText(admin.email),
      phoneNumber: Encryption.encryptText(admin.phoneNumber),
      password: HashPassword().hashPassword(admin.password),
    );
    await _adminDAO.createAdmin(encryptedAdmin);
  }

  Future<bool> login(String username, String password) async {
    final admin = await _adminDAO.getAdminByUsername(username);
    if (admin == null) return false;

    final isValidPassword = HashPassword().validPassword(
      password,
      admin.password,
    );
    return isValidPassword;
  }

  Future<AdminRegistration?> getAdminByUsername(String username) async {
    final encryptedUsername = Encryption.encryptText(username);
    final admin = await _adminDAO.getAdminByUsername(encryptedUsername);
    if (admin == null) return null;

    return AdminRegistration(
      id: admin.id,
      username: Encryption.decryptText(admin.username),
      fullName: Encryption.decryptText(admin.fullName),
      email: Encryption.decryptText(admin.email),
      phoneNumber: Encryption.decryptText(admin.phoneNumber),
      password: admin.password,
    );
  }

  Future<void> updateAdmin(AdminRegistration admin) async {
    final encryptedAdmin = AdminRegistration(
      id: admin.id,
      username: Encryption.encryptText(admin.username),
      fullName: Encryption.encryptText(admin.fullName),
      email: Encryption.encryptText(admin.email),
      phoneNumber: Encryption.encryptText(admin.phoneNumber),
      password:admin.password,
    );
    await _adminDAO.updateAdmin(encryptedAdmin);
  }

  Future<void> deleteAdmin(String id) async {
    await _adminDAO.deleteAdmin(id);
  }

  Future<String?> getAdminNameByUsername(String username) async {
    final admin = await getAdminByUsername(username);
    if (admin != null) {
      return admin.fullName;
    }
    return null;
  }
}
