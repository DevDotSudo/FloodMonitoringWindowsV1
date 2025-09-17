import 'package:flood_monitoring/dao/mysql_connection.dart';
import 'package:flood_monitoring/models/admin_registration.dart';

class AdminDAO {
  Future<void> createAdmin(AdminRegistration admin) async {
    final conn = await MySQLService.getConnection();
    try {
      await conn.execute(
        'INSERT INTO admins (id, username, fullName, email, phoneNumber, password) '
        'VALUES (:id, :username, :fullName, :email, :phone, :password)',
        {
          'id': admin.id,
          'username': admin.username,
          'fullName': admin.fullName,
          'email': admin.email,
          'phone': admin.phoneNumber,
          'password': admin.password,
        },
      );
    } catch (e) {
      print('Error inserting admin: $e');
      throw ('There is an error while registering admin, Try again later.');
    } finally {
      await conn.close();
    }
  }

  Future<AdminRegistration?> getAdminByUsername(String username) async {
    final conn = await MySQLService.getConnection();
    try {
      final result = await conn.execute(
        'SELECT id, username, fullName, email, phoneNumber, password '
        'FROM admins WHERE username = :username LIMIT 1',
        {'username': username},
      );

      final row = result.rows.isNotEmpty ? result.rows.first : null;
      if (row != null) {
        return AdminRegistration(
          id: row.colByName('id'),
          username: row.colByName('username')!,
          fullName: row.colByName('fullName')!,
          email: row.colByName('email')!,
          phoneNumber: row.colByName('phoneNumber')!,
          password: row.colByName('password')!,
        );
      }
      return null;
    } finally {
      await conn.close();
    }
  }

  Future<void> updateAdmin(AdminRegistration admin) async {
    if (admin.id == null) throw Exception('Admin id is required');
    final conn = await MySQLService.getConnection();

    try {
      await conn.execute(
        'UPDATE admins SET username = :username, fullName = :fullName, '
        'email = :email, phoneNumber = :phone, password = :password WHERE id = :id',
        {
          'username': admin.username,
          'fullName': admin.fullName,
          'email': admin.email,
          'phone': admin.phoneNumber,
          'password': admin.password,
          'id': admin.id,
        },
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteAdmin(String id) async {
    final conn = await MySQLService.getConnection();

    try {
      await conn.execute('DELETE FROM admins WHERE id = :id', {'id': id});
    } finally {
      await conn.close();
    }
  }
}
