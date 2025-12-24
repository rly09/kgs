# Discount Fix - Technical Details

## Issue
Discount was not saving when admin sets it, and not displaying at checkout.

## Root Cause

**Backend API Signature:**
```python
@router.put("/discount")
def update_discount(
    discount: float,  # ← Expects query parameter
    db: Session = Depends(get_db),
    admin: Admin = Depends(get_current_admin)
):
```

**Flutter Was Sending:**
```dart
// WRONG - Sending JSON body
await _apiClient.put(
  ApiConstants.discount,
  data: DiscountUpdate(discountPercentage: percentage).toJson(),
);
// This sends: {"discount_percentage": 10}
```

**Backend Expected:**
```
PUT /api/settings/discount?discount=10
```

## Fix Applied

**File:** `lib/data/services/settings_service.dart`

```dart
// FIXED - Sending as query parameter
Future<double> updateDiscount(double percentage) async {
  final response = await _apiClient.put(
    '${ApiConstants.discount}?discount=$percentage',  // ✅ Query parameter
  );
  final discountResponse = DiscountResponse.fromJson(response.data);
  return discountResponse.discountPercentage;
}
```

## How It Works Now

1. **Admin Sets Discount:**
   ```
   Admin enters 10% → PUT /api/settings/discount?discount=10 → Backend saves
   ```

2. **Checkout Fetches Discount:**
   ```
   GET /api/settings/discount → Returns {"discount_percentage": 10}
   ```

3. **Discount Displays:**
   ```dart
   if (discountPercentage > 0) {
     // Shows: "Discount (10%): -₹50"
   }
   ```

4. **Discount Applied to Total:**
   ```dart
   final subtotal = cart.totalAmount;
   final discountAmount = subtotal * (discountPercentage / 100);
   final finalTotal = subtotal - discountAmount;
   ```

## Testing

1. **Set Discount:**
   - Login as admin
   - Go to dashboard
   - Set discount to 10%
   - Click "Set"
   - Should show success message

2. **Verify Saved:**
   - Refresh page
   - Discount should still show 10%

3. **Test at Checkout:**
   - Login as customer
   - Add products to cart (e.g., ₹500 worth)
   - Go to checkout
   - Should see:
     ```
     Subtotal: ₹500
     Discount (10%): -₹50
     Total: ₹450
     ```

## Status
✅ **FIXED** - Discount now saves and displays correctly
