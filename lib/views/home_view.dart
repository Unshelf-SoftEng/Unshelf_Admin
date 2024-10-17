import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_admin/widgets/dashboard_card.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // These variables will hold the fetched data
  int totalUsers = 0;
  int totalAdmins = 0;
  int pendingRequests = 0;
  double totalRevenue = 0.0;
  int supportTickets = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch total users
      var usersSnapshot = await _firestore.collection('users').get();
      totalUsers = usersSnapshot.docs.length;

      // Fetch total admins
      var adminsSnapshot = await _firestore
          .collection('users')
          .where('type', isEqualTo: 'admin')
          .get();
      totalAdmins = adminsSnapshot.docs.length;

      // Fetch pending requests
      var requestsSnapshot = await _firestore
          .collection('approval_requests')
          .where('status', isEqualTo: 'Pending')
          .get();
      pendingRequests = requestsSnapshot.docs.length;

      // Fetch total revenue
      var ordersSnapshot = await _firestore.collection('orders').get();
      totalRevenue = ordersSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['totalPrice'] ?? 0.0);
      });

      // Fetch support tickets (assuming you have a 'support_tickets' collection)
      var ticketsSnapshot = await _firestore.collection('reports').where('status', isEqualTo: 'Pending').get();
      supportTickets = ticketsSnapshot.docs.length;

      // Update the UI
      setState(() {});
    } catch (e) {
      // Handle any errors
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add your logout functionality here
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationMenu(),
          
          // Main Content
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Admin',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('Here’s an overview of the current system status.'),
                  const SizedBox(height: 20),

                  // Dashboard Cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        DashboardCard(
                          icon: Icons.people,
                          label: 'Total Users',
                          value: totalUsers.toString(),
                          color: Colors.blue.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.admin_panel_settings,
                          label: 'Admins',
                          value: totalAdmins.toString(),
                          color: Colors.teal.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.approval,
                          label: 'Pending Requests',
                          value: pendingRequests.toString(),
                          color: Colors.orange.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.monetization_on,
                          label: 'Revenue',
                          value: '\₱${totalRevenue.toStringAsFixed(2)}',
                          color: Colors.green.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.analytics,
                          label: 'Analytics',
                          value: '',
                          color: Colors.purple.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.support_agent,
                          label: 'Support Tickets',
                          value: supportTickets.toString(),
                          color: Colors.red.shade700,
                        ),
                      ],
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
  