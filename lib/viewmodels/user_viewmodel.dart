import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_admin/models/user_model.dart';

class UsersManagementViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedRole = 'All';
  String searchQuery = '';

  Stream<List<UserModel>> fetchUsers() {
  return _firestore.collection('users').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  });
}



  List<UserModel> filterUsers(List<UserModel> users) {
    return users.where((user) {
      bool matchesRole = selectedRole == 'All' || user.type == selectedRole;
      bool matchesSearch = user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void updateSelectedRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  Future<void> deleteUser(String userId, BuildContext context) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted successfully.')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting user: $error')));
    }
  }

  Future<void> banUser(String userId, bool isBanned, BuildContext context) async {
    try {
      await _firestore.collection('users').doc(userId).update({'isBanned': isBanned});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBanned ? 'User banned successfully.' : 'User unbanned successfully.')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating user status: $error')));
    }
  }
}
