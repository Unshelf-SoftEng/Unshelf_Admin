import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_admin/models/approval_request_model.dart';

class ApprovalRequestsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedStatus = 'Pending'; // For filtering
  String searchQuery = ''; // For searching

  // Fetch the approval requests stream
  Stream<List<ApprovalRequest>> fetchRequests() {
    return _firestore.collection('approval_requests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ApprovalRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Approve a request
  void approveRequest(String requestId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Approval'),
          content: const Text('Approve the seller\'s application?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firestore.collection('approval_requests').doc(requestId).update({'status': 'Approved'});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request approved successfully!')),
                  );
                  Navigator.pop(context); // Close the dialog
                  notifyListeners();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error approving request: $error')),
                  );
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  // Reject a request
  void rejectRequest(String requestId, BuildContext context) {
    String rejectionReason = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Rejection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reject the seller\'s application?'),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reason for Rejection',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  rejectionReason = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (rejectionReason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason for rejection.')),
                  );
                  return;
                }

                try {
                  await _firestore.collection('approval_requests').doc(requestId).update({
                    'status': 'Rejected',
                    'rejectionReason': rejectionReason,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request rejected successfully!')),
                  );
                  Navigator.pop(context);
                  notifyListeners();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error rejecting request: $error')),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // View request details
  void viewDetails(ApprovalRequest request, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Name: ${request.name}'),
                Text('Email: ${request.email}'),
                Text('Status: ${request.status}'),
                Text('Additional Info: ${request.additionalInfo ?? 'N/A'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Filter and search logic
  List<ApprovalRequest> filterRequests(List<ApprovalRequest> requests) {
    return requests.where((request) => request.status == selectedStatus).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void updateSelectedStatus(String status) {
    selectedStatus = status;
    notifyListeners();
  }
}
