/// Represents a user in the system.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String userType; // e.g., 'user', 'technician', 'admin'
  final String role; // derived from userType
  final String status; // e.g., 'active', 'inactive', 'busy', 'available'
  final List<String>? skills;
  final String? experience;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.userType,
    required this.status,
    this.skills,
    this.experience,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    required this.lastActive,
  }) : role = userType; // role mirrors userType

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userType = json['userType'] ?? json['role'] ?? 'user';

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      userType: userType.toString().toLowerCase(),
      status: json['status'] ?? 'active',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'].map((skill) => skill.toString()))
          : [],
      experience: json['experience'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'userType': userType,
      'status': status,
      'skills': skills,
      'experience': experience,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  // Helper getters
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  String get statusText {
    switch (status) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'inactive':
        return 'Inactive';
      case 'active':
        return 'Active';
      default:
        return status;
    }
  }

  bool get isTechnician => userType == 'technician';
  bool get isAdmin => userType == 'admin';
  bool get isCustomer => userType == 'user';

  String get skillsString {
    if (skills == null || skills!.isEmpty) return 'No skills listed';
    return skills!.join(', ');
  }

  String get formattedJoinDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get lastActiveTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? userType,
    String? status,
    List<String>? skills,
    String? experience,
    double? rating,
    int? totalRatings,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, type: $userType, status: $status)';
  }
}

/// Represents a chat message, containing a reference to the sender (full UserModel).
class MessageModel {
  final String id;
  final UserModel sender; // full user object – ensure your API sends it
  final String content;
  final bool read;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.read,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      // If 'sender' is missing, an empty UserModel is created with defaults.
      // Adjust if your API sometimes omits the sender object.
      sender: UserModel.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender.toJson(),
      'content': content,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, sender: ${sender.name}, content: $content, read: $read)';
  }
}
