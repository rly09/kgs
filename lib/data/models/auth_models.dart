class AuthResponse {
  final String accessToken;
  final String tokenType;
  final UserData? user; // Changed from Map to UserData
  
  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: json['user'] != null ? UserData.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class AdminModel {
  final int id;
  final String email;
  final String name;
  final DateTime createdAt;
  
  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });
  
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CustomerModel {
  final int id;
  final String phone;
  final String name;
  final DateTime createdAt;
  
  CustomerModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.createdAt,
  });
  
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      phone: json['phone'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Generic user data for auth storage
class UserData {
  final int id;
  final String? email; // For admin
  final String? phone; // For customer
  final String name;
  final String type; // 'admin' or 'customer'
  
  UserData({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    required this.type,
  });
  
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'name': name,
      'type': type,
    };
  }
}


