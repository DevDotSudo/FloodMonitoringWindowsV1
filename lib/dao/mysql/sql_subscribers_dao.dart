import 'package:flood_monitoring/dao/mysql_connection.dart';
import 'package:flood_monitoring/models/subscriber.dart';

class SqlSubscribersDAO {
  Future<void> insertToMySQL(Subscriber subscriberData) async {
    final conn = await MySQLService.getConnection();

    try {
      await conn.execute(
        'INSERT INTO subscribers (id, fullName, age, gender, phoneNumber, address, registeredDate, viaSMS, viaApp) '
        'VALUES (:id, :fullName, :age, :gender, :phoneNumber, :address, :registeredDate, :viaSMS, :viaApp) '
        'ON DUPLICATE KEY UPDATE '
        'fullName = VALUES(fullName), age = VALUES(age), gender = VALUES(gender), '
        'phoneNumber = VALUES(phoneNumber), address = VALUES(address), registeredDate = VALUES(registeredDate), '
        'viaSMS = VALUES(viaSMS), viaApp = VALUES(viaApp)',
        {
          'id': subscriberData.id,
          'fullName': subscriberData.name,
          'age': subscriberData.age,
          'gender': subscriberData.gender,
          'phoneNumber': subscriberData.phone,
          'address': subscriberData.address,
          'registeredDate': subscriberData.registeredDate,
          'viaSMS': subscriberData.viaSMS,
          'viaApp': subscriberData.viaApp,
        },
      );
    } catch (e) {
      print('Error inserting or updating subscriber: $e');
      throw Exception(
        'There is an error while registering subscriber. Try again later.',
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> addSubscriber(Subscriber subscriberData) async {
    final conn = await MySQLService.getConnection();
    try {
      await conn.execute(
        'INSERT INTO subscribers (id, fullName, age, gender, phoneNumber, address, registeredDate, viaSMS, viaApp) VALUES (:id, :fullName, :age, :gender, :phoneNumber, :address, :registeredDate, :viaSMS, :viaApp)',
        {
          'id': subscriberData.id,
          'fullName': subscriberData.name,
          'age': subscriberData.age,
          'gender': subscriberData.gender,
          'phoneNumber': subscriberData.phone,
          'address': subscriberData.address,
          'registeredDate': subscriberData.registeredDate,
          'viaSMS': 'Yes',
          'viaApp': 'No'
        },
      );
    } catch (e) {
      print('Error inserting subscriber: $e');
      throw ('There is an error while registering subscriber, Try again later.');
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteSubscriber(String id) async {
    final conn = await MySQLService.getConnection();

    try {
      await conn.execute('DELETE FROM subscribers WHERE id = :id', {'id': id});
    } catch (e) {
      print('Error deleting subscriber: $e');
    } finally {
      await conn.close();
    }
  }

  Future<int> countSubscribers() async {
    final conn = await MySQLService.getConnection();
    try {
      final result = await conn.execute('SELECT * FROM subscribers');
      int count = result.rows.length;
      return count;
    } catch (e) {
      print('Error counting subscribers: $e');
    } finally {
      await conn.close();
    }
    return 0;
  }

  Future<List<Map<String, String?>>> fetchSubscribers() async {
    final conn = await MySQLService.getConnection();
    try {
      final result = await conn.execute('SELECT * FROM subscribers');

      List<Map<String, String?>> subscribers = result.rows.map((row) {
        return {
          'id': row.colByName('id')?.toString(),
          'fullName': row.colByName('fullName')?.toString(),
          'age': row.colByName('age')?.toString(),
          'gender': row.colByName('gender')?.toString(),
          'address': row.colByName('address')?.toString(),
          'phoneNumber': row.colByName('phoneNumber')?.toString(),
          'registeredDate': row.colByName('registeredDate')?.toString(),
        };
      }).toList();
      return subscribers;
    } catch (e) {
      print('Error fetching subscribers : $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<List<String>> fetchPhoneNumbers() async {
    final conn = await MySQLService.getConnection();
    final results = await conn.execute(
      "SELECT phoneNumber FROM subscribers WHERE viaSMS = 'Yes';",
    );
    List<String> numbers = [];
    for (final row in results.rows) {
      numbers.add(row.colByName("phoneNumber")!);
    }
    await conn.close();
    return numbers;
  }
}
