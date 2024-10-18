class ApprovalRequest {
  final String id;
  final String name;
  final String email;
  final String status;
  final String? additionalInfo;

  ApprovalRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.additionalInfo,
  });

  factory ApprovalRequest.fromMap(Map<String, dynamic> data, String id) {
    return ApprovalRequest(
      id: id,
      name: data['name'],
      email: data['email'],
      status: data['status'],
      additionalInfo: data['additionalInfo'],
    );
  }
}
