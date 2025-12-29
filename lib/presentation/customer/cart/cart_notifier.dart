import 'package:flutter/foundation.dart';

/// Cart item model
class CartItem {
  final int productId;
  final String productName;
  final double price;
  final int maxStock;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.maxStock,
    this.quantity = 1,
  });

  double get total => price * quantity;
  
  bool get canIncrement => quantity < maxStock;
}

/// Cart state notifier
class CartNotifier extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.total);

  bool addItem(int productId, String productName, double price, int stock) {
    if (_items.containsKey(productId)) {
      // Check if we can add more
      if (_items[productId]!.quantity < stock) {
        _items[productId]!.quantity++;
        notifyListeners();
        return true;
      }
      return false; // Cannot add more, stock limit reached
    } else {
      if (stock > 0) {
        _items[productId] = CartItem(
          productId: productId,
          productName: productName,
          price: price,
          maxStock: stock,
        );
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  bool updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return true;
    } else {
      final item = _items[productId];
      if (item != null && quantity <= item.maxStock) {
        item.quantity = quantity;
        notifyListeners();
        return true;
      }
      return false; // Quantity exceeds stock
    }
  }

  void decrementQuantity(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity <= 1) {
        removeItem(productId);
      } else {
        _items[productId]!.quantity--;
        notifyListeners();
      }
    }
  }

  bool incrementQuantity(int productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity < item.maxStock) {
        item.quantity++;
        notifyListeners();
        return true;
      }
      return false; // Stock limit reached
    }
    return false;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
