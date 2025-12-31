import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Blinkit-style quantity counter widget
class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int maxQuantity;

  const QuantityCounter({
    Key? key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.maxQuantity = 99,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDecrement,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          // Quantity display
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Increment button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: quantity < maxQuantity ? onIncrement : null,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.add,
                  color: quantity < maxQuantity ? Colors.white : Colors.white54,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
