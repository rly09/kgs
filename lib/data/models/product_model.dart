class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final int stock;
  final bool isAvailable;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.stock,
    required this.isAvailable,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      isAvailable: json['is_available'] as bool,
      imagePath: json['image_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'stock': stock,
      'is_available': isAvailable,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ProductCreate {
  final int categoryId;
  final String name;
  final double price;
  final int stock;
  final bool isAvailable;
  final String? imagePath;
  
  ProductCreate({
    required this.categoryId,
    required this.name,
    required this.price,
    required this.stock,
    this.isAvailable = true,
    this.imagePath,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'price': price,
      'stock': stock,
      'is_available': isAvailable,
      'image_path': imagePath,
    };
  }
}

class ProductUpdate {
  final String? name;
  final double? price;
  final int? stock;
  final bool? isAvailable;
  final String? imagePath;
  
  ProductUpdate({
    this.name,
    this.price,
    this.stock,
    this.isAvailable,
    this.imagePath,
  });
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (price != null) data['price'] = price;
    if (stock != null) data['stock'] = stock;
    if (isAvailable != null) data['is_available'] = isAvailable;
    if (imagePath != null) data['image_path'] = imagePath;
    return data;
  }
}
