import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_admin/viewmodels/analytics_viewmodel.dart';
import 'package:unshelf_admin/viewmodels/approval_request_viewmodel.dart';
import 'package:unshelf_admin/viewmodels/report_viewmodel.dart';
import 'package:unshelf_admin/viewmodels/user_viewmodel.dart';
import 'package:unshelf_admin/views/analytics_view.dart';
import 'package:unshelf_admin/views/approval_request_view.dart';
import 'package:unshelf_admin/views/home_view.dart';
import 'package:unshelf_admin/views/login_view.dart';
import 'package:unshelf_admin/views/register_view.dart';
import 'package:unshelf_admin/views/report_view.dart';
import 'package:unshelf_admin/views/usermanagement_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC0BHSDm6UjGfPfbp1uI6CxOXOBnnWNLyI",
      authDomain: "unshelf-d4567.firebaseapp.com",
      projectId: "unshelf-d4567",
      storageBucket: "unshelf-d4567.appspot.com",
      messagingSenderId: "733152787617",
      appId: "1:733152787617:web:32e6108d8e6b56adf544e0",
      measurementId: "G-C1JE4LKJCE"
    ),
  );

   runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsersManagementViewModel()),
        ChangeNotifierProvider(create: (_) => ReportsViewModel()),
        ChangeNotifierProvider(create: (_) => ApprovalRequestsViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
      child: MyApp(),
    ),
   );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unshelf Admin',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF386641)),
        useMaterial3: true,
        textTheme: GoogleFonts.jostTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: const Color.fromARGB(255, 56, 102, 65)),
      ),
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
      routes: {
        '/home': (context) => HomeView(),   
        '/login': (context) => LoginView(),
        '/users': (context) => UsersManagementView(),
        '/approval_requests': (context) => ApprovalRequestsView(),
        '/register': (context) => RegisterView(),
        '/analytics': (context) => AnalyticsView(),
        '/reports': (context) => ReportsView(),
      },
    );
  }
}
