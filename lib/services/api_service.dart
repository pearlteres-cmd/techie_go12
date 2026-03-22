import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ============================================
  // ✅ PRIVATE HELPER
  // ============================================
  static Future<Map<String, dynamic>> _makeRequest({
    required String method,
    required String endpoint,
    String? token,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (requiresAuth && token != null)
        headers['Authorization'] = 'Bearer $token';

      print('📡 $method $endpoint');
      if (body != null) print('📦 Request body: $body');

      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri,
              headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri,
              headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'PATCH':
          response = await http.patch(uri,
              headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          return {'success': false, 'message': 'Invalid HTTP method'};
      }

      print('📡 Response status: ${response.statusCode}');
      if (response.body.trim().startsWith('<!DOCTYPE')) {
        return {
          'success': false,
          'message': 'Server returned HTML. Backend might not be running.',
          'statusCode': response.statusCode
        };
      }
      if (response.body.trim().isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300)
          return {'success': true, 'data': {}};
        return {
          'success': false,
          'message': 'Empty response with status ${response.statusCode}'
        };
      }

      final data = json.decode(response.body);
      print('📡 Response body: $data');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? data['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': data
        };
      }
    } catch (e) {
      print('❌ Request error ($endpoint): $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================
  // ✅ OTP GENERATOR
  // ============================================
  static String _generateOTP() =>
      (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

  // ============================================
  // ✅ MOCK DATA
  // ============================================
  static Future<Map<String, dynamic>> _getMockComplaints() async {
    return {
      'success': true,
      'data': [
        {
          '_id': '1',
          'title': 'Laptop not turning on',
          'description': 'My laptop suddenly stopped working',
          'complaintType': 'Hardware',
          'priority': 'High',
          'status': 'pending',
          'userName': 'John Doe',
          'userAddress': '123 Main St',
          'preferredDate': DateTime.now().toIso8601String(),
          'preferredTime': '10:00 AM',
          'preferredTimeSlot': 'Morning',
          'createdAt': DateTime.now().toIso8601String()
        },
        {
          '_id': '2',
          'title': 'Software installation issue',
          'description': 'Unable to install required software',
          'complaintType': 'Software',
          'priority': 'Medium',
          'status': 'assigned',
          'userName': 'John Doe',
          'userAddress': '123 Main St',
          'assignedTechnicianName': 'Mike Wilson',
          'preferredDate': DateTime.now().toIso8601String(),
          'preferredTime': '02:00 PM',
          'preferredTimeSlot': 'Afternoon',
          'createdAt': DateTime.now().toIso8601String()
        },
        {
          '_id': '3',
          'title': 'Network connectivity problem',
          'description': 'Internet keeps disconnecting',
          'complaintType': 'Network',
          'priority': 'Urgent',
          'status': 'in_progress',
          'userName': 'John Doe',
          'userAddress': '123 Main St',
          'assignedTechnicianName': 'Sarah Johnson',
          'preferredDate': DateTime.now().toIso8601String(),
          'preferredTime': '09:00 AM',
          'preferredTimeSlot': 'Morning',
          'createdAt': DateTime.now().toIso8601String()
        },
      ]
    };
  }

  static Future<Map<String, dynamic>> _getMockTechnicians() async {
    return {
      'success': true,
      'data': [
        {
          '_id': '1',
          'name': 'John Smith',
          'email': 'john.smith@example.com',
          'phone': '9876543210',
          'userType': 'technician',
          'skills': ['Hardware Expert', 'Network Expert'],
          'status': 'available',
          'rating': 4.8
        },
        {
          '_id': '2',
          'name': 'Sarah Johnson',
          'email': 'sarah.j@example.com',
          'phone': '9876543211',
          'userType': 'technician',
          'skills': ['Software Expert', 'Mobile Expert'],
          'status': 'available',
          'rating': 4.9
        },
        {
          '_id': '3',
          'name': 'Mike Wilson',
          'email': 'mike.w@example.com',
          'phone': '9876543212',
          'userType': 'technician',
          'skills': ['Data Recovery', 'Hardware Expert'],
          'status': 'available',
          'rating': 4.7
        },
      ]
    };
  }

  // ============================================
  // ✅ AUTH
  // ============================================
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final result = await _makeRequest(
          method: 'POST',
          endpoint: '/auth/register',
          requiresAuth: false,
          body: {
            'name': name,
            'email': email,
            'phone': phone,
            'password': password,
            'userType': 'user'
          });
      if (result['success']) {
        final data = result['data'];
        final userData = data['user'] ?? data;
        final user = UserModel.fromJson(userData);
        await _saveUserData(data['token'], user);
        await notifyAdminNewUser(user);
        return {'success': true, 'data': data};
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _makeRequest(
          method: 'POST',
          endpoint: '/auth/login',
          requiresAuth: false,
          body: {'email': email, 'password': password});
      if (result['success']) {
        final data = result['data'];
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(data['user'] ?? {});
        if (email == 'admin@techiego.com' && password == 'admin123')
          userData['userType'] = 'admin';
        else if (email == 'tech@techiego.com' && password == 'tech123')
          userData['userType'] = 'technician';
        else if (email == 'user@techiego.com' && password == 'user123')
          userData['userType'] = 'user';
        final user = UserModel.fromJson(userData);
        await _saveUserData(data['token'], user);
        return {
          'success': true,
          'data': {'token': data['token'], 'user': user.toJson()}
        };
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final result =
        await _makeRequest(method: 'GET', endpoint: '/auth/me', token: token);
    if (result['success']) {
      final data = result['data'];
      final userData = data['user'] ?? data;
      return {'success': true, 'user': UserModel.fromJson(userData)};
    }
    return result;
  }

  // ============================================
  // ✅ DASHBOARD
  // ============================================
  static Future<Map<String, dynamic>> getAdminDashboard(String token) =>
      _makeRequest(method: 'GET', endpoint: '/admin/stats', token: token);
  static Future<Map<String, dynamic>> getTechnicianDashboard(
      String token) async {
    final result = await _makeRequest(
        method: 'GET', endpoint: '/technician/dashboard', token: token);
    if (result['success']) return result;
    return {
      'success': true,
      'data': {
        'assignedCount': 3,
        'availableCount': 5,
        'workingCount': 2,
        'completedCount': 10,
        'totalEarnings': 2500.00,
        'rating': 4.5
      }
    };
  }

  static Future<Map<String, dynamic>> getUserDashboard(String token) =>
      _makeRequest(method: 'GET', endpoint: '/tasks/user/me', token: token);

  // ============================================
  // ✅ USER/TECHNICIAN
  // ============================================
  static Future<Map<String, dynamic>> getTechnicians(String token) async {
    try {
      List<String> endpoints = [
        '/technicians',
        '/users?userType=technician',
        '/auth/users?userType=technician',
        '/admin/technicians'
      ];
      for (String endpoint in endpoints) {
        try {
          final result = await _makeRequest(
              method: 'GET', endpoint: endpoint, token: token);
          if (result['success']) {
            final data = result['data'];
            List<dynamic> technicians = [];
            if (data['data'] != null && data['data'] is List)
              technicians = data['data'];
            else if (data['users'] != null && data['users'] is List)
              technicians = data['users'];
            else if (data is List)
              technicians = data;
            else if (data['data'] != null && data['data'] is Map)
              technicians = [data['data']];
            else
              technicians = [data];
            technicians = technicians
                .where((user) =>
                    (user['userType']?.toString().toLowerCase() ?? '') ==
                    'technician')
                .toList();
            return {'success': true, 'data': technicians};
          }
        } catch (_) {
          continue;
        }
      }
      return _getMockTechnicians();
    } catch (_) {
      return _getMockTechnicians();
    }
  }

  static Future<Map<String, dynamic>> getUsers(String token) async {
    try {
      final result =
          await _makeRequest(method: 'GET', endpoint: '/users', token: token);
      if (result['success']) {
        final data = result['data'];
        List<dynamic> users = [];
        if (data['data'] != null && data['data'] is List)
          users = data['data'];
        else if (data is List)
          users = data;
        else
          users = [data];
        return {'success': true, 'data': users, 'counts': data['counts'] ?? {}};
      }
      return result;
    } catch (_) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getCustomers(String token) =>
      _makeRequest(
          method: 'GET', endpoint: '/users?userType=user', token: token);
  static Future<Map<String, dynamic>> getUserById(
      String token, String userId) async {
    final result = await _makeRequest(
        method: 'GET', endpoint: '/users/$userId', token: token);
    if (result['success']) {
      final data = result['data'];
      final userData = data['data'] ?? data;
      return {'success': true, 'user': UserModel.fromJson(userData)};
    }
    return result;
  }

  // ============================================
  // ✅ TASKS
  // ============================================
  static Future<Map<String, dynamic>> createTask({
    required String token,
    required String title,
    required String description,
    required double amount,
    String? category,
    String? priority,
    String? address,
    DateTime? scheduledDate,
    String? userId,
  }) async {
    Map<String, dynamic> body = {
      'title': title,
      'description': description,
      'amount': amount,
      'category': category ?? 'general',
      'priority': priority ?? 'medium',
      if (address != null) 'address': address,
      if (scheduledDate != null)
        'scheduledDate': scheduledDate.toIso8601String(),
      if (userId != null) 'userId': userId,
    };
    return await _makeRequest(
        method: 'POST', endpoint: '/tasks', token: token, body: body);
  }

  static Future<Map<String, dynamic>> getUserTasks(String token) =>
      _makeRequest(method: 'GET', endpoint: '/tasks/user/me', token: token);
  static Future<Map<String, dynamic>> getAllTasks(String token) =>
      _makeRequest(method: 'GET', endpoint: '/tasks/all', token: token);
  static Future<Map<String, dynamic>> updateTaskStatus({
    required String token,
    required String taskId,
    required String status,
    String? otp,
  }) async {
    return await _makeRequest(
        method: 'PUT',
        endpoint: '/tasks/$taskId/status',
        token: token,
        body: {'status': status, if (otp != null) 'otp': otp});
  }

  static Future<Map<String, dynamic>> assignTechnician({
    required String token,
    required String taskId,
    required String technicianId,
  }) async {
    return await _makeRequest(
        method: 'PUT',
        endpoint: '/tasks/$taskId/assign',
        token: token,
        body: {'technicianId': technicianId});
  }

  static Future<Map<String, dynamic>> getAvailableTasks(String token) async {
    final result = await _makeRequest(
        method: 'GET', endpoint: '/tasks/available', token: token);
    return result['success'] ? result : {'success': true, 'data': []};
  }

  // ============================================
  // ✅ COMPLAINTS
  // ============================================
  static Future<Map<String, dynamic>> registerComplaint({
    required String token,
    required String title,
    required String description,
    required String complaintType,
    String? peripheralType,
    required String priority,
    required String address,
    String? landmark,
    required DateTime preferredDate,
    required String preferredTime,
    required String preferredTimeSlot,
    Map<String, dynamic>? location,
    double? amount,
  }) async {
    try {
      String otp = _generateOTP();
      Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'complaintType': complaintType,
        'priority': priority,
        'userAddress': address,
        'userLandmark': landmark,
        'preferredDate': preferredDate.toIso8601String(),
        'preferredTime': preferredTime,
        'preferredTimeSlot': preferredTimeSlot,
        'location': location,
        'otp': otp,
        if (amount != null) 'amount': amount,
        if (peripheralType != null && peripheralType.isNotEmpty)
          'peripheralType': peripheralType,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(requestBody),
      );
      if (response.body.trim().isEmpty) {
        if (response.statusCode == 201 || response.statusCode == 200)
          return {
            'success': true,
            'data': {'otp': otp},
            'message': 'Complaint registered successfully'
          };
        return {
          'success': false,
          'message': 'Empty response with status ${response.statusCode}'
        };
      }
      final data = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? data,
          'otp': otp,
          'message': data['message'] ?? 'Complaint registered successfully'
        };
      }
      return {
        'success': false,
        'message':
            data['error'] ?? data['message'] ?? 'Failed to register complaint'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserComplaints(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/complaints/user/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      if (response.body.trim().isEmpty)
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': []
        };
      if (response.body.trim().startsWith('<!DOCTYPE'))
        return _getMockComplaints();
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> complaints = [];
        if (data['data'] != null && data['data'] is List)
          complaints = data['data'];
        else if (data is List)
          complaints = data;
        else if (data['complaints'] != null && data['complaints'] is List)
          complaints = data['complaints'];
        else if (data['results'] != null && data['results'] is List)
          complaints = data['results'];
        return {
          'success': true,
          'data': complaints,
          'count': complaints.length
        };
      }
      if (response.statusCode == 401 || response.statusCode == 403)
        return _getMockComplaints();
      String errorMessage =
          data['error'] ?? data['message'] ?? 'Failed to load complaints';
      return {'success': false, 'message': errorMessage, 'data': []};
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        return _getMockComplaints();
      }
      return {
        'success': false,
        'message': 'Error loading complaints: $e',
        'data': []
      };
    }
  }

  static Future<Map<String, dynamic>> getAllComplaints(String token) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/complaints/admin/all'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {'success': true, 'data': data['data'] ?? []};
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load complaints'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getPendingComplaints(String token) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/complaints/admin/pending'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {'success': true, 'data': data['data'] ?? []};
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load pending complaints'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getTechnicianComplaints(
      String token) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/complaints/technician/me'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {'success': true, 'data': data['data'] ?? []};
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load complaints'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getAvailableTechnicians(
      String token) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/complaints/available-technicians'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      if (response.body.trim().isEmpty)
        return {'success': false, 'message': 'Empty response'};
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'data': data['data'] ?? [],
          'count': data['count'] ?? 0
        };
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load technicians'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> adminAssignTechnician({
    required String token,
    required String complaintId,
    required String technicianId,
    required String technicianName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$complaintId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(
            {'technicianId': technicianId, 'technicianName': technicianName}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        await createNotification(
            token: token,
            type: 'task_assigned',
            message: 'New complaint assigned to you',
            userId: technicianId,
            data: {'complaintId': complaintId});
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Complaint assigned successfully'
        };
      }
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to assign complaint'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> assignComplaint({
    required String token,
    required String complaintId,
    required String technicianId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$complaintId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'technicianId': technicianId}),
      );
      if (response.body.trim().isEmpty)
        return {'success': false, 'message': 'Empty response'};
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Complaint assigned successfully'
        };
      return {
        'success': false,
        'message':
            data['error'] ?? data['message'] ?? 'Failed to assign complaint'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateComplaintStatus({
    required String token,
    required String complaintId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$complaintId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body:
            json.encode({'status': status, if (notes != null) 'notes': notes}),
      );
      if (response.body.trim().isEmpty)
        return {'success': false, 'message': 'Empty response'};
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Status updated successfully'
        };
      return {
        'success': false,
        'message': data['error'] ?? data['message'] ?? 'Failed to update status'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateComplaintDetails({
    required String token,
    required String complaintId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$complaintId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(updates),
      );
      if (response.body.trim().isEmpty) {
        return {'success': false, 'message': 'Empty response'};
      }
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Complaint updated successfully'
        };
      }
      return {
        'success': false,
        'message':
            data['error'] ?? data['message'] ?? 'Failed to update complaint'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelComplaint({
    required String token,
    required String complaintId,
    required String reason,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$complaintId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'reason': reason}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Complaint cancelled successfully'
        };
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to cancel complaint'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> provideFeedback({
    required String token,
    required String complaintId,
    required double rating,
    String? feedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints/$complaintId/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'rating': rating, 'customerFeedback': feedback}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201)
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Feedback submitted successfully'
        };
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to submit feedback'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  // ============================================
  // ✅ VERIFY OTP
  // ============================================
  static Future<Map<String, dynamic>> verifyOTP({
    required String token,
    required String complaintId,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints/$complaintId/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'otp': otp}),
      );
      if (response.body.trim().isEmpty)
        return {'success': false, 'message': 'Empty response'};
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully'
        };
      return {
        'success': false,
        'message': data['error'] ?? data['message'] ?? 'OTP verification failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================
  // ✅ NOTIFICATIONS
  // ============================================
  static Future<Map<String, dynamic>> createNotification({
    required String token,
    required String type,
    required String message,
    String? userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'type': type,
          'message': message,
          'userId': userId,
          if (data != null) 'data': data
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 201)
        return {
          'success': true,
          'data': responseData['data'] ?? responseData,
          'message': responseData['message'] ?? 'Notification created'
        };
      return {
        'success': false,
        'message': responseData['error'] ?? 'Failed to create notification'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getNotifications(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      if (response.body.trim().isEmpty)
        return {'success': false, 'message': 'Empty response'};
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'data': data['data'] ?? [],
          'unreadCount': data['unreadCount'] ?? 0
        };
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load notifications'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead({
    required String token,
    required String notificationId,
  }) async {
    try {
      final response = await http.put(
          Uri.parse('$baseUrl/notifications/$notificationId/read'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      if (response.statusCode == 200) return {'success': true};
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
      String token) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/notifications/read/all'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (response.statusCode == 200) return {'success': true};
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<void> notifyAdminNewUser(UserModel user) async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/notifications/admin'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode({
            'type': 'new_user',
            'userId': user.id,
            'userName': user.name,
            'userEmail': user.email,
            'message': 'New user registered: ${user.name}'
          }),
        );
      }
    } catch (e) {}
  }

  // ============================================
  // ✅ SUPPORT MESSAGES
  // ============================================
  static Future<Map<String, dynamic>> sendSupportMessage(
          {required String token, required String message}) =>
      _makeRequest(
          method: 'POST',
          endpoint: '/support/messages',
          token: token,
          body: {'message': message});
  static Future<Map<String, dynamic>> getMySupportMessages(String token) =>
      _makeRequest(
          method: 'GET', endpoint: '/support/messages/my', token: token);
  static Future<Map<String, dynamic>> getAllSupportMessages(String token) =>
      _makeRequest(method: 'GET', endpoint: '/support/messages', token: token);
  static Future<Map<String, dynamic>> markSupportMessageAsRead(
          {required String token, required String messageId}) =>
      _makeRequest(
          method: 'PUT',
          endpoint: '/support/messages/$messageId/read',
          token: token);
  static Future<Map<String, dynamic>> replyToSupportMessage(
          {required String token,
          required String messageId,
          required String reply}) =>
      _makeRequest(
          method: 'POST',
          endpoint: '/support/messages/$messageId/reply',
          token: token,
          body: {'reply': reply});

  // ============================================
  // ✅ EMPLOYEE MANAGEMENT
  // ============================================
  static Future<Map<String, dynamic>> registerEmployee({
    required String token,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    List<String>? expertise,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
          if (expertise != null) 'expertise': expertise
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 201)
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Employee registered successfully'
        };
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to register employee'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getAllEmployees(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/employees'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> employees = [];
        if (data['data'] != null && data['data'] is List)
          employees = data['data'];
        else if (data is List) employees = data;
        return {'success': true, 'data': employees, 'count': employees.length};
      }
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load employees'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getAllTechnicians(String token) async {
    try {
      final result = await getAllEmployees(token);
      if (result['success']) {
        final allEmployees = result['data'];
        final technicians = allEmployees.where((emp) {
          final userType = emp['userType']?.toString().toLowerCase() ??
              emp['role']?.toString().toLowerCase() ??
              '';
          return userType == 'technician';
        }).toList();
        return {
          'success': true,
          'data': technicians,
          'count': technicians.length
        };
      }
      return result;
    } catch (e) {
      return _getMockTechnicians();
    }
  }

  static Future<Map<String, dynamic>> getTechnicianById(
      String token, String technicianId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/employees/$technicianId'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {'success': true, 'data': data['data'] ?? data};
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to load technician'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> updateTechnician({
    required String token,
    required String technicianId,
    required String name,
    required String email,
    required String phone,
    String? status,
    List<String>? skills,
    String? experience,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/employees/$technicianId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'status': status,
          'skills': skills ?? [],
          'experience': experience
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': 'Technician updated successfully'
        };
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to update technician'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> deleteTechnician(
      String token, String technicianId) async {
    try {
      final response = await http.delete(
          Uri.parse('$baseUrl/admin/employees/$technicianId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      final data = json.decode(response.body);
      if (response.statusCode == 200)
        return {'success': true, 'message': 'Technician deleted successfully'};
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to delete technician'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  // ============================================
  // ✅ PAYMENT METHODS (UPDATED to use complaintId)
  // ============================================
  static Future<Map<String, dynamic>> createPaymentOrder({
    required String token,
    required String complaintId, // changed from taskId
  }) async {
    return await _makeRequest(
      method: 'POST',
      endpoint: '/payments/create-order',
      token: token,
      body: {'complaintId': complaintId},
    );
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String token,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    return await _makeRequest(
      method: 'POST',
      endpoint: '/payments/verify',
      token: token,
      body: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
  }

  static Future<Map<String, dynamic>> getUserPayments(String token) async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/payments/my',
      token: token,
    );
  }

  static Future<Map<String, dynamic>> getAllPayments(String token) async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/payments',
      token: token,
    );
  }

  // ============================================
  // ✅ UTILITY
  // ============================================
  static Future<Map<String, dynamic>> createAdmin() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/setup/create-admin'));
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201)
        return {'success': true, 'data': data};
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to create admin'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/test'));
      if (response.statusCode == 200)
        return {'success': true, 'message': 'Connected to backend'};
      return {
        'success': false,
        'message': 'Backend returned status ${response.statusCode}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend'};
    }
  }

  // ============================================
  // ✅ LOCAL STORAGE
  // ============================================
  static Future<void> _saveUserData(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(user.toJson()));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) return UserModel.fromJson(json.decode(userString));
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
