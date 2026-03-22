import 'package:flutter/material.dart';
import 'package:techie_go/screens/auth/login_screen.dart';
import 'package:techie_go/screens/admin/admin_dashboard.dart' as admin_screens;
import 'package:techie_go/screens/technician/tech_dashboard.dart';
import 'package:techie_go/screens/user/user_dashboard.dart';
import 'package:techie_go/services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechieGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate loading

    final isLoggedIn = await ApiService.isLoggedIn();
    final user = await ApiService.getCurrentUser();

    if (mounted) {
      if (isLoggedIn && user != null) {
        // Navigate to appropriate dashboard based on user role
        Widget dashboard;
        
        // Use the role directly from user object
        if (user.isAdmin) {
          dashboard = admin_screens.AdminDashboard(user: user);
        } else if (user.isTechnician) {
          dashboard = TechDashboard(user: user);
        } else {
          dashboard = UserDashboard(user: user);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => dashboard),
        );
      } else {
        // Navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.purple.shade800],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_circle,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'TechieGo',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}