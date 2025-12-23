import 'package:drift/drift.dart';
import 'categories.dart';

/// Products table
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
