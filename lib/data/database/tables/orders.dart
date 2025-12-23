import 'package:drift/drift.dart';
import 'customers.dart';

/// Orders table
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text()();
  TextColumn get deliveryAddress => text()();
  TextColumn get note => text().nullable()();
  TextColumn get paymentMode => text()(); // 'COD' or 'ONLINE'
  TextColumn get paymentProofPath => text().nullable()();
  TextColumn get status => text()(); // 'PENDING', 'ACCEPTED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'
  RealColumn get totalAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
