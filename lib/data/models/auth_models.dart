class AuthResponse {
  final String accessToken;
  final String tokenType;
  final Map<String, dynamic>? user; // User data from backend
  
  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      if (user != null) 'user': user,
    };
  }
}

class AdminModel {
  final int id;
  final String phone;
  final String name;
  final DateTime createdAt;
  
  AdminModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.createdAt,
  });
  
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
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
