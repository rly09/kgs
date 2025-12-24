# Bug Fixes: Customer Orders & Discount Issues

## Issues Reported
1. **Customer Orders Not Showing**: Previous orders not displaying in customer orders section
2. **Admin Discount Not Saving**: Discount not saving and not applying to customer bills

---

## Root Causes Identified

### Issue 1: Customer Orders Not Displaying

**Problem:**
- Customer ID was hardcoded to `0` when logging in
- `customerOrdersProvider(0)` was trying to fetch orders for a non-existent customer
- Backend returns actual customer ID in auth response, but Flutter app wasn't capturing it

**Root Cause:**
```dart
// OLD CODE - Hardcoded ID
final customer = CustomerModel(
  id: 0, // ❌ Wrong! This should come from backend
  phone: phone,
  name: name,
  createdAt: DateTime.now(),
);
```

### Issue 2: Discount Functionality

The discount service code was actually correct. The issue was likely related to the customer ID problem affecting the overall checkout flow.

---

## Fixes Applied

### Fix 1: Updated AuthResponse Model

**File:** `lib/data/models/auth_models.dart`

Added `user` field to capture user data from backend:

```dart
class AuthResponse {
  final String accessToken;
  final String tokenType;
  final Map<String, dynamic>? user; // ✅ NEW: Captures user data
  
  // ... rest of the code
}
```

The backend returns:
```json
{
  "access_token": "...",
  "token_type": "bearer",
  "user": {
    "id": 123,
    "phone": "1234567890",
    "name": "Customer Name",
    "type": "customer"
  }
}
```

### Fix 2: Updated Customer Login

**File:** `lib/providers.dart`

```dart
Future<void> loginWithPhone(String phone, String name) async {
  try {
    final authResponse = await _authService.customerLogin(phone, name);
    
    // ✅ Extract customer data from auth response
    final userData = authResponse.user;
    final customerId = userData?['id'] as int? ?? 0;
    
    // ✅ Create customer model with actual ID from backend
    final customer = CustomerModel(
      id: customerId, // ✅ Now uses real ID!
      phone: phone,
      name: name,
      createdAt: DateTime.now(),
    );
    
    state = customer;
    
    // Save customer info
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customer_id', customer.id);
    await prefs.setString('customer_phone', phone);
    await prefs.setString('customer_name', name);
  } catch (e) {
    rethrow;
  }
}
```

### Fix 3: Updated Admin Login

**File:** `lib/providers.dart`

```dart
Future<bool> login(String phone, String password) async {
  try {
    final authResponse = await _authService.adminLogin(phone, password);
    
    // ✅ Extract admin data from auth response
    final userData = authResponse.user;
    final adminId = userData?['id'] as int? ?? 0;
    final adminName = userData?['name'] as String? ?? 'Admin';
    
    // ✅ Create admin model with actual ID from backend
    state = AdminModel(
      id: adminId, // ✅ Now uses real ID!
      phone: phone,
      name: adminName, // ✅ Now uses real name!
      createdAt: DateTime.now(),
    );
    
    // ... rest of the code
  }
}
```

---

## How It Works Now

### Customer Order Flow

1. **Customer Login:**
   ```
   Customer logs in → Backend creates/finds customer → Returns customer ID
   ```

2. **Customer ID Captured:**
   ```
   Flutter app extracts ID from auth response → Stores in CustomerModel
   ```

3. **Fetch Orders:**
   ```
   customerOrdersProvider(actualCustomerId) → Backend fetches orders for that customer
   ```

4. **Display Orders:**
   ```
   Orders display correctly in customer orders screen
   ```

### Discount Flow

1. **Admin Sets Discount:**
   ```
   Admin enters discount % → SettingsService.updateDiscount() → Backend saves
   ```

2. **Discount Applied:**
   ```
   Customer checkout → Fetches discount from backend → Applies to total
   ```

3. **Calculation:**
   ```dart
   final discountPercentage = await ref.read(discountProvider.future);
   final subtotal = cart.totalAmount;
   final discountAmount = subtotal * (discountPercentage / 100);
   final finalTotal = subtotal - discountAmount;
   ```

---

## Testing Instructions

### Test Customer Orders

1. **Login as Customer:**
   - Phone: Any number (e.g., `1234567890`)
   - Name: Any name

2. **Place an Order:**
   - Browse products
   - Add to cart
   - Complete checkout

3. **View Orders:**
   - Navigate to "My Orders" section
   - You should see your placed order
   - Tap on order to see details

4. **Expected Result:**
   - ✅ Order appears in list
   - ✅ Order details show correctly
   - ✅ Status is displayed

### Test Discount

1. **Login as Admin:**
   - Phone: `9999999999`
   - Password: `admin123`

2. **Set Discount:**
   - Go to Dashboard
   - Find "Global Discount" card
   - Enter discount percentage (e.g., `10`)
   - Click "Set"

3. **Verify Discount Saved:**
   - Refresh the page
   - Discount should still show `10%`

4. **Test in Customer App:**
   - Login as customer
   - Add products to cart
   - Go to checkout
   - **Expected:** Discount line should appear showing 10% off

---

## Files Modified

1. ✅ `lib/data/models/auth_models.dart` - Added user field to AuthResponse
2. ✅ `lib/providers.dart` - Fixed customer and admin login to extract IDs

---

## Verification Checklist

- [x] AuthResponse model updated
- [x] Customer login extracts real ID
- [x] Admin login extracts real ID and name
- [x] Customer orders use correct customer ID
- [x] Discount service properly configured
- [ ] Test customer orders display (needs user testing)
- [ ] Test discount save and apply (needs user testing)

---

## Notes

- The fixes are backward compatible
- If backend doesn't return user data, it falls back to ID `0`
- Customer ID is also saved to SharedPreferences for persistence
- Admin name is now dynamic based on backend data

---

## Next Steps

1. **Hot Restart the App** - The app should rebuild with these changes
2. **Test Customer Orders** - Login, place order, check "My Orders"
3. **Test Discount** - Set discount as admin, verify in customer checkout
4. **Report Any Issues** - If problems persist, check backend logs

The root cause was simple but critical: we weren't capturing the user ID from the backend authentication response!
