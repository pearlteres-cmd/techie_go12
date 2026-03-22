// lib/services/database_service.dart
// Legacy service - kept for backward compatibility
// New authentication uses ApiService instead
import '../models/user_model.dart';

class DatabaseService {
  // Mock database for demo purposes
  final List<UserModel> _users = [];

  // Demo users for testing
  final List<UserModel> _demoUsers = [
    UserModel(
      id: 'demo_admin_1',
      name: 'Admin User',
      email: 'admin@techiego.com',
      phone: '1234567890',
      userType: 'admin', // CHANGED: from 'role' to 'userType'
      status: 'active',
      skills: [], // ADDED: required empty list
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    ),
    UserModel(
      id: 'demo_tech_1',
      name: 'John Technician',
      email: 'tech@techiego.com',
      phone: '9876543210',
      userType: 'technician', // CHANGED: from 'role' to 'userType'
      status: 'available',
      skills: ['Hardware', 'Software', 'Networking'],
      experience: '5 years',
      rating: 4.5,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    ),
    UserModel(
      id: 'demo_user_1',
      name: 'Sarah Customer',
      email: 'user@techiego.com',
      phone: '5551234567',
      userType: 'user', // CHANGED: from 'role' to 'userType'
      status: 'active',
      skills: [], // ADDED: required empty list
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    ),
  ];

  DatabaseService() {
    // Initialize with demo users
    _users.addAll(_demoUsers);
  }

  // Get all demo users
  List<UserModel> getDemoUsers() {
    return _demoUsers;
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.firstWhere(
        (user) => user.id == userId,
      );
    } catch (e) {
      return null;
    }
  }

  // Create a new user
  Future<void> createUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final existingUser = await getUserByEmail(user.email);
    if (existingUser != null) {
      throw Exception('User with this email already exists');
    }
    _users.add(user);
  }

  // Update existing user
  Future<void> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      throw Exception('User not found');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users.removeWhere((user) => user.id == userId);
  }

  // Get all users by role/type
  Future<List<UserModel>> getUsersByType(String userType) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users.where((user) => user.userType == userType).toList();
  }

  // Get all technicians
  Future<List<UserModel>> getAllTechnicians() async {
    return getUsersByType('technician');
  }

  // Get all customers
  Future<List<UserModel>> getAllCustomers() async {
    return getUsersByType('user');
  }

  // Get all admins
  Future<List<UserModel>> getAllAdmins() async {
    return getUsersByType('admin');
  }

  // Get available technicians (with status 'available')
  Future<List<UserModel>> getAvailableTechnicians() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users
        .where((user) =>
            user.userType == 'technician' && user.status == 'available')
        .toList();
  }

  // Search users by name, email or phone
  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(lowercaseQuery) ||
          user.email.toLowerCase().contains(lowercaseQuery) ||
          user.phone.contains(query);
    }).toList();
  }

  // Authenticate user (for demo/fallback purposes - real auth uses ApiService)
  Future<UserModel?> authenticateUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Demo: accept any password for demo accounts
    try {
      final user = _users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index >= 0) {
      final updatedUser = _users[index].copyWith(status: status);
      _users[index] = updatedUser;
    }
  }

  // Update technician rating
  Future<void> updateTechnicianRating(String userId, double newRating) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index =
        _users.indexWhere((u) => u.id == userId && u.userType == 'technician');
    if (index >= 0) {
      final currentRating = _users[index].rating;
      final totalRatings = _users[index].totalRatings;

      // Calculate new average rating
      final updatedRating =
          ((currentRating * totalRatings) + newRating) / (totalRatings + 1);

      final updatedUser = _users[index].copyWith(
        rating: updatedRating,
        totalRatings: totalRatings + 1,
      );
      _users[index] = updatedUser;
    }
  }

  // Get user statistics
  Map<String, dynamic> getUserStats() {
    return {
      'total': _users.length,
      'admins': _users.where((u) => u.userType == 'admin').length,
      'technicians': _users.where((u) => u.userType == 'technician').length,
      'users': _users.where((u) => u.userType == 'user').length,
      'availableTechnicians': _users
          .where((u) => u.userType == 'technician' && u.status == 'available')
          .length,
    };
  }

  // Get top rated technicians
  Future<List<UserModel>> getTopRatedTechnicians({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users.where((u) => u.userType == 'technician').toList()
      ..sort((a, b) => b.rating.compareTo(a.rating))
      ..take(limit).toList();
  }

  // Clear all users (for testing)
  void clearAllUsers() {
    _users.clear();
    _users.addAll(_demoUsers);
  }
}
