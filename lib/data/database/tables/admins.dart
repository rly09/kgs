import 'package:drift/drift.dart';

/// Admin table for authentication
class Admins extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phone => text().withLength(min: 10, max: 10).unique()();
  TextColumn get passwordHash => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}
