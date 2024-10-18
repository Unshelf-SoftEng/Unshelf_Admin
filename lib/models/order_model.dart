import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  final String id;
  final String sellerId;
  final double totalPrice;
  final String status;
  final DateTime completedAt;

  Orders({
    required this.id,
    required this.sellerId,
    required this.totalPrice,
    required this.status,
    required this.completedAt,
  });

  factory Orders.fromFirestore(Map<String, dynamic> data) {
    return Orders(
      id: data['id'],
      sellerId: data['sellerId'],
      totalPrice: data['totalPrice'],
      status: data['status'],
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }
}
