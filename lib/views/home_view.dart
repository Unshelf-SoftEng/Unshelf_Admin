import 'package:flutter/material.dart';
import 'package:unshelf_admin/widgets/dashboard_card.dart';
import 'package:unshelf_admin/widgets/navigation_menu.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
                          value: '1,250',
                          color: Colors.blue.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.approval,
                          label: 'Pending Requests',
                          value: '3,560',
                          color: Colors.orange.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.analytics,
                          label: 'Analytics',
                          value: '47',
                          color: Colors.green.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.admin_panel_settings,
                          label: 'Admins',
                          value: '2,930',
                          color: Colors.teal.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.monetization_on,
                          label: 'Revenue',
                          value: '\$23,760',
                          color: Colors.purple.shade700,
                        ),
                        DashboardCard(
                          icon: Icons.support_agent,
                          label: 'Support Tickets',
                          value: '12',
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