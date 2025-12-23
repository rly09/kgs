import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/admins.dart';
import 'tables/categories.dart';
import 'tables/products.dart';
import 'tables/customers.dart';
import 'tables/orders.dart';
import 'tables/order_items.dart';
import 'tables/settings.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Admins,
  Categories,
  Products,
  Customers,
  Orders,
  OrderItems,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedInitialData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Create settings table
          await m.createTable(settings);
          // Seed initial discount
          await into(settings).insert(
            SettingsCompanion.insert(
              key: 'discount_percentage',
              value: '0',
              updatedAt: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// Seed initial data on first launch
  Future<void> _seedInitialData() async {
    // Create default admin
    await into(admins).insert(
      AdminsCompanion.insert(
        phone: '9999999999',
        passwordHash: 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', // admin123
        name: 'Admin',
        createdAt: DateTime.now(),
      ),
    );

    // Create sample categories
    final groceriesId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Groceries',
        createdAt: DateTime.now(),
      ),
    );

    final snacksId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Snacks',
        createdAt: DateTime.now(),
      ),
    );

    final beveragesId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Beverages',
        createdAt: DateTime.now(),
      ),
    );

    final householdId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Household',
        createdAt: DateTime.now(),
      ),
    );

    // Create sample products
    final now = DateTime.now();
    
    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: groceriesId,
        name: 'Rice (1kg)',
        price: 60.0,
        stock: const Value(50),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: groceriesId,
        name: 'Wheat Flour (1kg)',
        price: 45.0,
        stock: const Value(40),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: snacksId,
        name: 'Potato Chips',
        price: 20.0,
        stock: const Value(100),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: snacksId,
        name: 'Biscuits',
        price: 15.0,
        stock: const Value(80),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: beveragesId,
        name: 'Soft Drink (500ml)',
        price: 40.0,
        stock: const Value(60),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: beveragesId,
        name: 'Mineral Water (1L)',
        price: 20.0,
        stock: const Value(100),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: householdId,
        name: 'Detergent Powder (500g)',
        price: 80.0,
        stock: const Value(30),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(products).insert(
      ProductsCompanion.insert(
        categoryId: householdId,
        name: 'Dish Soap',
        price: 35.0,
        stock: const Value(45),
        isAvailable: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Create initial discount setting
    await into(settings).insert(
      SettingsCompanion.insert(
        key: 'discount_percentage',
        value: '0',
        updatedAt: DateTime.now(),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kpg_shop.db'));
    return driftDatabase(name: file.path);
  });
}
