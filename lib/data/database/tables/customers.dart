import 'package:drift/drift.dart';

/// Customers table
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phone => text().nullable()();
  TextColumn get name => text().nullable()();
  BoolColumn get isGuest => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
