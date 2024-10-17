import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green.shade700,
            ),
            child: const Text(
              'Unshelf Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
                 Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () {
                 Navigator.pushReplacementNamed(context, '/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('Approval Requests'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/approval_requests');
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/reports');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/analytics');
            },
          ),
           ListTile(
            leading: const Icon(Icons.app_registration_rounded),
            title: const Text('Register'),
            onTap: () {
               Navigator.pushReplacementNamed(context, '/register');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // Show confirmation dialog
              bool? confirmLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false on cancel
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true on confirm
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              // If user confirms, log out
              if (confirmLogout == true) {
                try {
                  await FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged out successfully')),
                  );
                  // Navigate to the login screen or any other desired screen
                  Navigator.pushReplacementNamed(context, '/login'); // Adjust the route name as needed
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed. Please try again.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
