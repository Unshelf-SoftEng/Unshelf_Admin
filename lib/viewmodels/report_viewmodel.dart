import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_admin/models/report_model.dart';

class ReportsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of reports
  Stream<List<Report>> fetchPendingReports() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .asyncMap((snapshot) async {
      return Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        // Fetch the user's name
        final userDoc = await _firestore.collection('users').doc(data['userId']).get();
        String userName = userDoc.exists ? userDoc['name'] : 'Unknown';
        data['userName'] = userName;

        return Report.fromFirestore(data, doc.id);
      }).toList());
    });
  }

  // Resolve a report
  void resolveReport(String reportId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Resolution'),
          content: const Text('Are you sure you want to mark this report as resolved?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform the resolution action
                _firestore.collection('reports').doc(reportId).update({'status': 'Resolved'}).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report resolved')));
                  notifyListeners();
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );
  }


  // Delete a report
  void deleteReport(String reportId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete action
                _firestore.collection('reports').doc(reportId).delete().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report deleted')));
                  notifyListeners();
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
