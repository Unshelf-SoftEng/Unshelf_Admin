import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class ReportsView extends StatefulWidget {
  @override
  _ReportsViewState createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch only pending reports along with user details
  Stream<List<Map<String, dynamic>>> _fetchReports() {
    return _firestore.collection('reports')
      .where('status', isEqualTo: 'Pending') // Filter for only Pending reports
      .snapshots()
      .asyncMap((snapshot) async {
        final reports = await Future.wait(snapshot.docs.map((doc) async {
          final reportData = {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id // Include document ID
          };

          // Fetch user details
          final userDoc = await _firestore.collection('users').doc(reportData['userId']).get();
          if (userDoc.exists) {
            reportData['userName'] = userDoc['name']; // Add user's name
          } else {
            reportData['userName'] = 'Unknown'; // Handle case where user doesn't exist
          }

          return reportData;
        }));
        return reports;
      });
  }

  void _resolveReport(String reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Resolution'),
          content: const Text('The issue is resolved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('reports').doc(reportId).update({'status': 'Resolved'});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User report successfully resolved.')),
                );
                Navigator.pop(context);
              },
              child: const Text('Resolved'),
            ),
          ],
        );
      },
    );
  }

  void _deleteReport(String reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Delete user report.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('reports').doc(reportId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User report deleted successfully.')),
                );
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showReportMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Message'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports'),
      ),
      body: Row(
        children: [
          NavigationMenu(), // Sidebar for navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fetchReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading reports'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No pending reports found'));
                  }

                  final reports = snapshot.data!;

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(report['userName']),
                          subtitle: Text('Status: ${report['status']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () => _showReportMessage(report['message']),
                                tooltip: 'View Report Message',
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () => _resolveReport(report['id']),
                                tooltip: 'Resolve Report',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteReport(report['id']),
                                tooltip: 'Delete Report',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
