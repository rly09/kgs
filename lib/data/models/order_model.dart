class OrderItemModel {
  final int? id;
  final int? orderId;
  final int productId; // Required when creating, but can be null in DB after product deletion
  final String productName;
  final int quantity;
  final double priceAtOrder;
  
  OrderItemModel({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtOrder,
  });
  
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      productId: json['product_id'] as int? ?? 0, // Default to 0 if null (deleted product)
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      priceAtOrder: (json['price_at_order'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price_at_order': priceAtOrder,
    };
  }
}

class OrderModel {
  final int id;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final double totalAmount;
  final String paymentMode;
  final String? note;
  final String status;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.totalAmount,
    required this.paymentMode,
    this.note,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      deliveryAddress: json['delivery_address'] as String,
      deliveryLatitude: json['delivery_latitude'] as double?,
      deliveryLongitude: json['delivery_longitude'] as double?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMode: json['payment_mode'] as String,
      note: json['note'] as String?,
      status: json['status'] as String,
      items: (json['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      'note': note,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderCreate {
  final int customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final double totalAmount;
  final String paymentMode;
  final String? note;
  final List<OrderItemModel> items;
  
  OrderCreate({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.totalAmount,
    required this.paymentMode,
    this.note,
    required this.items,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      if (deliveryLatitude != null) 'delivery_latitude': deliveryLatitude,
      if (deliveryLongitude != null) 'delivery_longitude': deliveryLongitude,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      if (note != null) 'note': note,
      // items are inserted separately into order_items table
    };
  }
}

class OrderStatusUpdate {
  final String status;
  
  OrderStatusUpdate({required this.status});
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
