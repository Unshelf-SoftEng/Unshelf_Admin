import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class UsersManagementView extends StatefulWidget {
  UsersManagementView({Key? key}) : super(key: key);

  @override
  _UsersManagementViewState createState() => _UsersManagementViewState();
}

class _UsersManagementViewState extends State<UsersManagementView> {
  String selectedRole = 'All';
  String searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _fetchUsers() {
  return _firestore.collection('users').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList());
  }


  List<Map<String, dynamic>> _filterUsers(List<Map<String, dynamic>> users) {
    // Filter users by role and search query
    return users.where((user) {
      bool matchesRole = selectedRole == 'All' || user['type'] == selectedRole;
      bool matchesSearch = user['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();
  }


  // Actions (stub implementations)
  void _viewUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("User Details - ${user['name']}"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user['profilePictureUrl'] ?? ''),
                radius: 40,
              ),
              const SizedBox(height: 10),
              Text('Full Name: ${user['name']}'),
              Text('Email: ${user['email']}'),
              Text('Role: ${user['type']}'),
              Text('Last Login: ${user['lastLogin'] ?? 'N/A'}'),
              // Add more details as needed
            ],
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

  // void _editUser(Map<String, dynamic> user) {
  //   // Logic to edit user details (e.g., show a form for editing)
  // }

  void _deleteUser(String userId) {
  // Show confirmation dialog before deleting
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              //Perform the deletion
              _firestore.collection('users').doc(userId).delete().then((_) {
                Navigator.pop(context); // Close the dialog after deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully.')),
                );
              }).catchError((error) {
                Navigator.pop(context); // Close the dialog if there is an error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting user: $error')),
                );
              });
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

  void _banUser(String userId, bool isBanned) {
  // Show confirmation dialog before banning/unbanning
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: isBanned ? const Text('Confirm Ban') : const Text('Confirm Unban'),
        content: Text(isBanned
            ? 'Are you sure you want to unban this user?'
            : 'Are you sure you want to ban this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update user ban status
              _firestore.collection('users').doc(userId).update({'isBanned': isBanned}).then((_) {
                Navigator.pop(context); // Close the dialog after updating
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isBanned ? 'User banned successfully.' : 'User unbanned successfully.')),
                );
              }).catchError((error) {
                Navigator.pop(context); // Close the dialog if there is an error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating user status: $error')),
                );
              });
            },
            child: Text(isBanned ? 'Ban' : 'Unban'),
          ),
        ],
      );
    },
  );
}

  // void _resetPassword(String email) {
  //   // Logic to trigger password reset email using Firebase Auth
  //   //FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      //drawer: NavigationMenu(), // Your navigation menu

      body: Row(
        children: [
          // Navigation Menu
          NavigationMenu(), // Keep the navigation menu here for layout

          // Main Content
          Expanded(
            flex: 4, // Adjust flex based on your layout needs
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value; // Update the search query
                          });
                        },
                    ),
                    const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter by Role:'),
                      DropdownButton<String>(
                        value: selectedRole,
                        items: ['All', 'admin', 'buyer', 'seller']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _fetchUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error loading users'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No users found'));
                        }

                        final users = _filterUsers(snapshot.data!);
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(user['name'][0]),
                                ),
                                title: Text(user['name']),
                                subtitle: Text(user['email']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () => _viewUser(user),
                                    ),
                                    // IconButton(
                                    //   icon: const Icon(Icons.edit),
                                    //   onPressed: () => _editUser(user),
                                    // ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteUser(user['docId']),
                                    ),
                                    IconButton(
                                      icon: Icon(user['isBanned'] == true
                                          ? Icons.lock
                                          : Icons.lock_open),
                                      onPressed: () =>
                                          _banUser(user['docId'], !user['isBanned']),
                                    ),
                                    // IconButton(
                                    //   icon: const Icon(Icons.refresh),
                                    //   onPressed: () => _resetPassword(user['email']),
                                    // ),
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