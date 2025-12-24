class CategoryModel {
  final int id;
  final String name;
  final DateTime createdAt;
  
  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CategoryCreate {
  final String name;
  
  CategoryCreate({required this.name});
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
