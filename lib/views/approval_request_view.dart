import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class ApprovalRequestsView extends StatefulWidget {
  @override
  _ApprovalRequestsViewState createState() => _ApprovalRequestsViewState();
}

class _ApprovalRequestsViewState extends State<ApprovalRequestsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedStatus = 'Pending'; // For filtering
  String searchQuery = ''; // For searching

  Stream<List<Map<String, dynamic>>> _fetchRequests() {
    return _firestore.collection('approval_requests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _filterRequests(List<Map<String, dynamic>> requests) {
    return requests.where((request) => request['status'] == selectedStatus).toList();
  }

  void _approveRequest(String requestId) {
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
                // Logic to approve the request
                try {
                  await _firestore.collection('approval_requests').doc(requestId).update({'status': 'Approved'});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request approved successfully!')),
                  );
                  Navigator.pop(context); // Close the dialog after approval
                } catch (error) {
                  // Handle any errors that occur during the update
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

  void _rejectRequest(String requestId) {
  // Variable to hold the rejection reason
  String rejectionReason = '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Request Rejection'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Allow the dialog to adjust its size
          children: [
            const Text('Reject the seller\'s application?'),
            const SizedBox(height: 16.0), // Add some spacing
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for Rejection',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                rejectionReason = value; // Capture the rejection reason
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Logic to reject the request with the reason
              if (rejectionReason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason for rejection.')),
                );
                return; // Do not proceed if the reason is empty
              }

              try {
                await _firestore.collection('approval_requests').doc(requestId).update({
                  'status': 'Rejected',
                  'rejectionReason': rejectionReason, // Store the rejection reason
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request rejected successfully!')),
                );
                Navigator.pop(context); // Close the dialog after rejection
              } catch (error) {
                // Handle any errors that occur during the update
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

  void _viewDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Name: ${request['name']}'),
                Text('Email: ${request['email']}'),
                Text('Status: ${request['status']}'),
                // Add more fields as necessary
                Text('Additional Info: ${request['additionalInfo'] ?? 'N/A'}'), // Example of an additional field
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
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
        title: const Text('Approval Requests'),
      ),
      body: Row(
        children: [
          NavigationMenu(), // Include the navigation menu here
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter by Status:'),
                      DropdownButton<String>(
                        value: selectedStatus,
                        items: ['Pending', 'Approved', 'Rejected']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _fetchRequests(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error loading requests'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No requests found'));
                        }

                        final requests = _filterRequests(snapshot.data!)
                            .where((request) => request['name'].toLowerCase().contains(searchQuery.toLowerCase()))
                            .toList();

                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(request['name']),
                                subtitle: Text(request['email']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () => _approveRequest(request['id']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () => _rejectRequest(request['id']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info),
                                      onPressed: () => _viewDetails(request), // View details
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
