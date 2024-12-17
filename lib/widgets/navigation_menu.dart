import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_admin/views/analytics_view.dart';
import 'package:unshelf_admin/views/approval_request_view.dart';
import 'package:unshelf_admin/views/home_view.dart';
import 'package:unshelf_admin/views/login_view.dart';
import 'package:unshelf_admin/views/register_view.dart';
import 'package:unshelf_admin/views/report_view.dart';
import 'package:unshelf_admin/views/usermanagement_view.dart';

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
              _navigateWithFade(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () {
              _navigateWithFade(context, '/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('Approval Requests'),
            onTap: () {
              _navigateWithFade(context, '/approval_requests');
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Reports'),
            onTap: () {
              _navigateWithFade(context, '/reports');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              _navigateWithFade(context, '/analytics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration_rounded),
            title: const Text('Register'),
            onTap: () {
              _navigateWithFade(context, '/register');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              bool? confirmLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true) {
                try {
                  await FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                  _navigateWithFade(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout failed. Please try again.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateWithFade(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _getRouteWidget(routeName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final fadeAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Widget _getRouteWidget(String routeName) {
    switch (routeName) {
      case '/home':
        return HomeView();
      case '/users':
        return UsersManagementView();
      case '/approval_requests':
        return ApprovalRequestsView();
      case '/reports':
        return ReportsView();
      case '/analytics':
        return AnalyticsView();
      case '/register':
        return RegisterView();
      case '/login':
        return LoginView();
      default:
        return HomeView(); // Default to home screen
    }
  }
}
