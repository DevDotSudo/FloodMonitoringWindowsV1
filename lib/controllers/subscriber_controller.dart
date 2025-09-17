import 'package:flood_monitoring/models/subscriber.dart';
import 'package:flood_monitoring/services/mysql_services/subscriber_service_sql.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriberController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SqlSubscriberService _subscriberService = SqlSubscriberService();
  List<Subscriber> display = [];
  String _searchQuery = ' ';

  Future<void> loadSubscribers() async {
    final subscribers = await _subscriberService.getAllSubscribers();
    display = subscribers;
    notifyListeners();
  }

  Future<List<Subscriber>> filteredSubscribers() async {
    List<Subscriber> subscribers = await _subscriberService.getAllSubscribers();
    notifyListeners();
    if (_searchQuery.isEmpty) {
      return subscribers;
    } else {
      return subscribers
          .where(
            (s) =>
                s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.phone.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addSubscriberFromFirestoreListener() async {
    _firestore.collection("SUBSCRIBERS").snapshots().listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added && doc.doc.data() != null) {
          final data = doc.doc.data()!;
          final subscriber = Subscriber.fromMap(data);
          _subscriberService.syncSubscriberFromFirebase(subscriber);
        }
      }
    });
    notifyListeners();
  }

  
  void startListenerAfterBuild() {
    Future.delayed(Duration.zero, () {
      addSubscriberFromFirestoreListener();
    });
    notifyListeners();
  }

  Future<void> addSubscriber(Subscriber newSubscriber) async {
    await _subscriberService.addSubscriber(newSubscriber);
    notifyListeners();
  }

  Future<int> get countTotalSubscribers async {
    return await _subscriberService.countSubscribers();
  }

  Future<void> deleteSubscriber(String id) async {
    await _subscriberService.deleteSubscriber(id);
  }

  Future<String> phoneNumbers() async {
    return await _subscriberService.getPhoneNumbers();
  }
}
