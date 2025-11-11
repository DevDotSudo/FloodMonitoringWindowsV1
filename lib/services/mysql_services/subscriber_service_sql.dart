import 'package:flood_monitoring/dao/mysql/sql_subscribers_dao.dart';
import 'package:flood_monitoring/models/subscriber.dart';
import 'package:flood_monitoring/services/firestore_services/subscriber_service_firestore.dart';
import 'package:flood_monitoring/utils/encrypt_util.dart';

class SqlSubscriberService {
  final SqlSubscribersDAO _subscribersDao = SqlSubscribersDAO();

  Future<void> syncSubscriberFromFirebase(Subscriber subscriber) async {
    if (subscriber.id.isEmpty &&
        subscriber.name.isEmpty &&
        subscriber.age.isEmpty &&
        subscriber.gender.isEmpty &&
        subscriber.address.isEmpty &&
        subscriber.phone.isEmpty) {
      return;
    }

    final mappedSubscriber = Subscriber(
      id: subscriber.id,
      name: subscriber.name,
      age: subscriber.age,
      gender: subscriber.gender,
      address: subscriber.address,
      phone: subscriber.phone,
      registeredDate: subscriber.registeredDate,
      viaSMS: subscriber.viaSMS,
      viaApp: subscriber.viaApp,
    );
    await _subscribersDao.insertToMySQL(mappedSubscriber);
  }

  Future<void> addSubscriber(Subscriber subscriber) async {
    final encryptedSubscriber = Subscriber(
      id: subscriber.id,
      name: Encryption.encryptText(subscriber.name),
      age: Encryption.encryptText(subscriber.age),
      gender: Encryption.encryptText(subscriber.gender),
      phone: Encryption.encryptText(subscriber.phone),
      address: Encryption.encryptText(subscriber.address),
      registeredDate: subscriber.registeredDate,
      viaSMS: subscriber.viaSMS,
      viaApp: subscriber.viaApp,
    );
    await _subscribersDao.addSubscriber(encryptedSubscriber);
  }

  Future<void> deleteSubscriber(String id) async {
    await _subscribersDao.deleteSubscriber(id);
    await SubscriberService().deleteSubscriber(id);
  }

  Future<int> countSubscribers() async {
    return await _subscribersDao.countSubscribers();
  }

  Future<List<Subscriber>> getAllSubscribers() async {
    final list = await _subscribersDao.fetchSubscribers();

    if (list.isEmpty) {
      return [];
    }

    List<Subscriber> subscribers = list
        .map(
          (data) => Subscriber.fromMap({
            'id': data['id'] ?? '',
            'fullName': Encryption.decryptText(data['fullName'] ?? ''),
            'age': Encryption.decryptText(data['age'] ?? ''),
            'gender': Encryption.decryptText(data['gender'] ?? ''),
            'address': Encryption.decryptText(data['address'] ?? ''),
            'phoneNumber': Encryption.decryptText(data['phoneNumber'] ?? ''),
            'registeredDate': data['registeredDate'] ?? '',
            'viaSMS': data['viaSMS'],
            'viaApp': data['viaApp'],
          }),
        )
        .toList();
    return subscribers;
  }

  Future<String> getPhoneNumbers() async {
    try {
      List<String> encryptedNumbers = await _subscribersDao.fetchPhoneNumbers();

      List<String> decryptedNumbers = encryptedNumbers.map((e) {
        String decrypted = Encryption.decryptText(e);
        if (decrypted.startsWith('0')) {
          decrypted = '63${decrypted.substring(1)}';
        } else if (decrypted.startsWith('+')) {
          decrypted = '63${decrypted.substring(1)}';
        }
        return decrypted;
      }).toList();

      return decryptedNumbers.join(',');
    } catch (e) {
      print("Error: $e");
      return '';
    }
  }

  Future<String> getAppSubscriberPhoneNumbers() async {
    final numbers = await _subscribersDao.fetchAppSubscriberPhoneNumbers();
    return numbers.join(',');
  }

  Future<String> getSmsOnlySubscriberPhoneNumbers() async {
    try {
      List<String> encryptedNumbers = await _subscribersDao.fetchPhoneNumbers();

      List<String> decryptedNumbers = encryptedNumbers.map((e) {
        String decrypted = Encryption.decryptText(e);
        if (decrypted.startsWith('0')) {
          decrypted = '63${decrypted.substring(1)}';
        }

        else if (decrypted.startsWith('+')) {
          decrypted = '63${decrypted.substring(1)}';
        }
        return decrypted;
      }).toList();

      return decryptedNumbers.join(',');
    } catch (e) {
      print("Error: $e");
      return '';
    }
  }
}
