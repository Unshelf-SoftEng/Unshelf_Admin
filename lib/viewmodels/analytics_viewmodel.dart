// viewmodels/analytics_view_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_admin/models/seller_model.dart';
import 'package:unshelf_admin/models/order_model.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedTimeFrame = 'Daily';
  double totalRevenue = 0.0;
  int totalCompletedOrders = 0;
  List<Seller> sellersData = [];
  DateTime? startDate;
  DateTime? endDate;

  // Fetch analytics data based on time frame
  Future<void> fetchAnalyticsData() async {
    final now = DateTime.now();
    DateTime startDate;

    if (selectedTimeFrame == 'Daily') {
      startDate = DateTime(now.year, now.month, now.day); // Start of the day
    } else if (selectedTimeFrame == 'Monthly') {
      startDate = DateTime(now.year, now.month, 1); // Start of the month
    } else { // Yearly
      startDate = DateTime(now.year, 1, 1); // Start of the year
    }

    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('completedAt', isGreaterThanOrEqualTo: startDate)
        .where('completedAt', isLessThanOrEqualTo: now)
        .get();

    final sellersSnapshot = await _firestore
        .collection('users')
        .where('type', isEqualTo: 'seller')
        .get();

    // Map to store seller data
    Map<String, Seller> sellerMap = {
      for (var seller in sellersSnapshot.docs)
        seller.id: Seller(id: seller.id, name: seller['name']),
    };

    double overallRevenue = 0.0;
    int overallCompletedOrders = 0;

    // Process orders and update sellerMap
    for (var orderDoc in ordersSnapshot.docs) {
      final order = Orders.fromFirestore(orderDoc.data());
      final seller = sellerMap[order.sellerId];

      if (order.status == 'Completed') {
        overallCompletedOrders++;
        overallRevenue += order.totalPrice;
      }

      if (seller != null) {
        if (order.status == 'Completed') {
          seller.completedOrders++;
          seller.revenue += order.totalPrice;
        } else if (order.status == 'Ready') {
          seller.readyOrders++;
        } else if (order.status == 'Pending') {
          seller.pendingOrders++;
        }
      }
    }

    sellersData = sellerMap.values.toList();
    totalRevenue = overallRevenue;
    totalCompletedOrders = overallCompletedOrders;
    this.startDate = startDate;
    this.endDate = now;

    notifyListeners(); // Notify UI of data changes
  }

  void updateSelectedTimeFrame(String timeFrame) {
    selectedTimeFrame = timeFrame;
    fetchAnalyticsData();
  }
}
