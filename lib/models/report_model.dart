class Report {
  final String id;
  final String userId;
  final String message;
  final String status;
  final String userName;

  Report({
    required this.id,
    required this.userId,
    required this.message,
    required this.status,
    required this.userName,
  });

  // Create a Report instance from a Firestore document snapshot
  factory Report.fromFirestore(Map<String, dynamic> data, String id) {
    return Report(
      id: id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'Pending',
      userName: data['userName'] ?? 'Unknown',
    );
  }
}
