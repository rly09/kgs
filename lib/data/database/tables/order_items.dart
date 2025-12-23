import 'package:drift/drift.dart';
import 'orders.dart';
import 'products.dart';

/// Order items table
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get priceAtOrder => real()();
}
