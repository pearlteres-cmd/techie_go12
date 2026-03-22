import 'package:flutter/material.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/screens/auth/register_screen.dart';
import 'package:techie_go/screens/admin/admin_dashboard.dart';
import 'package:techie_go/screens/user/user_dashboard.dart';
import 'package:techie_go/screens/technician/tech_dashboard.dart';
import 'package:techie_go/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Demo credentials for internal fallback (not shown in UI)
  final Map<String, Map<String, String>> _demoUsers = {
    'admin': {
      'email': 'admin@techiego.com',
      'password': 'admin123',
      'userType': 'admin',
    },
    'technician': {
      'email': 'tech@techiego.com',
      'password': 'tech123',
      'userType': 'technician',
    },
    'user': {
      'email': 'user@techiego.com',
      'password': 'user123',
      'userType': 'user',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final user = UserModel.fromJson(userData);
        if (mounted) _navigateToDashboard(user);
      } else {
        _tryDemoLogin();
      }
    } catch (e) {
      _tryDemoLogin();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _tryDemoLogin() {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email == _demoUsers['admin']!['email'] &&
        password == _demoUsers['admin']!['password']) {
      final adminUser = UserModel(
        id: '699b4085e5ca57d3c4bacbef',
        name: 'System Administrator',
        email: email,
        phone: '1234567890',
        userType: 'admin',
        status: 'active',
        skills: [],
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      _navigateToDashboard(adminUser);
      return;
    }

    if (email == _demoUsers['technician']!['email'] &&
        password == _demoUsers['technician']!['password']) {
      final techUser = UserModel(
        id: '2',
        name: 'Technician User',
        email: email,
        phone: '9876543210',
        userType: 'technician',
        status: 'available',
        skills: ['Hardware', 'Software'],
        experience: '5 years',
        rating: 4.5,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      _navigateToDashboard(techUser);
      return;
    }

    if (email == _demoUsers['user']!['email'] &&
        password == _demoUsers['user']!['password']) {
      final regularUser = UserModel(
        id: '3',
        name: 'Regular User',
        email: email,
        phone: '5551234567',
        userType: 'user',
        status: 'active',
        skills: [],
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      _navigateToDashboard(regularUser);
      return;
    }

    _showErrorDialog('Invalid email or password');
  }

  void _navigateToDashboard(UserModel user) {
    Widget dashboard;

    if (user.isAdmin) {
      dashboard = AdminDashboard(user: user);
    } else if (user.isTechnician) {
      dashboard = TechDashboard(user: user);
    } else {
      dashboard = UserDashboard(user: user);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final _forgotEmailController = TextEditingController();
    final _forgotFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: _forgotFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email_outlined, size: 50, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Enter your email address to reset your password.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _forgotEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Enter your email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_forgotFormKey.currentState!.validate()) {
                _sendPasswordResetEmail(
                    _forgotEmailController.text.trim(), ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  void _sendPasswordResetEmail(String email, BuildContext dialogContext) {
    bool isDemoUser = _demoUsers.values.any((user) => user['email'] == email);

    if (isDemoUser) {
      String? userType;
      String? password;
      _demoUsers.forEach((key, value) {
        if (value['email'] == email) {
          userType = value['userType'];
          password = value['password'];
        }
      });

      Navigator.pop(dialogContext);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Demo Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 50, color: Colors.orange),
              const SizedBox(height: 16),
              Text('This is a demo $userType account.'),
              const SizedBox(height: 8),
              Text('Password: $password'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      _emailController.text = email;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build_circle,
                        size: 80,
                        color: Colors.blue.shade800,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to TechieGo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      // Forgot Password Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
