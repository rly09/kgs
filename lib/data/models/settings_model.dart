class SettingsModel {
  final int id;
  final String key;
  final String value;
  final DateTime updatedAt;
  
  SettingsModel({
    required this.id,
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] as int,
      key: json['key'] as String,
      value: json['value'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DiscountResponse {
  final double discountPercentage;
  
  DiscountResponse({required this.discountPercentage});
  
  factory DiscountResponse.fromJson(Map<String, dynamic> json) {
    return DiscountResponse(
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
    );
  }
}

class DiscountUpdate {
  final double discountPercentage;
  
  DiscountUpdate({required this.discountPercentage});
  
  Map<String, dynamic> toJson() {
    return {
      'discount_percentage': discountPercentage,
    };
  }
}
