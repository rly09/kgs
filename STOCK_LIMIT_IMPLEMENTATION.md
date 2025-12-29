# Stock Limit Implementation

## Overview
Implemented stock validation to prevent users from adding more items to their cart than are available in inventory. The system now enforces stock limits across all cart operations.

## Changes Made

### 1. Cart Notifier (`lib/presentation/customer/cart/cart_notifier.dart`)

#### CartItem Model Updates
- Added `maxStock` field to track the maximum available stock for each product
- Added `canIncrement` getter to check if quantity can be increased
- Stock information is now stored with each cart item

#### Method Updates
- **`addItem()`**: Now requires `stock` parameter and returns `bool`
  - Validates against stock before adding/incrementing
  - Returns `true` if successful, `false` if stock limit reached
  
- **`incrementQuantity()`**: Now returns `bool`
  - Checks if current quantity is less than max stock
  - Returns `false` when stock limit is reached
  
- **`updateQuantity()`**: Now returns `bool`
  - Validates new quantity against max stock
  - Returns `false` if quantity exceeds available stock

- **`decrementQuantity()`**: Unchanged behavior
  - Removes item when quantity reaches 0

### 2. Customer Home Screen (`lib/presentation/customer/home/customer_home_screen.dart`)

#### Floating Add Button
- Updated to pass `widget.product.stock` when calling `cart.addItem()`
- Added success validation and user feedback
- Shows snackbar notification when stock limit is reached
- Message: "Stock limit reached for {product name}"

### 3. Cart Screen (`lib/presentation/customer/cart/cart_screen.dart`)

#### Cart Item Display
- Added stock information display below price: "Stock: {maxStock}"
- Shows available stock for each item in cart

#### Quantity Controls
- Increment button now checks `item.canIncrement` before enabling
- Shows visual disabled state when at max stock
- Displays snackbar when trying to exceed stock limit
- Message: "Maximum stock ({maxStock}) reached for {product name}"

#### Quantity Button Widget
- Added `isDisabled` parameter (default: `false`)
- Disabled state shows:
  - Reduced opacity border
  - Grayed out icon color
  - No tap interaction

## User Experience

### Adding Items from Product Grid
1. User clicks floating green plus button on product card
2. If stock available: Item added to cart successfully
3. If stock limit reached: Red snackbar appears with error message

### Managing Cart Quantities
1. User can see available stock for each item
2. Increment button (+) is disabled when quantity equals max stock
3. Decrement button (-) always enabled, removes item at quantity 1
4. Attempting to exceed stock shows helpful error message

### Visual Feedback
- ✅ Green floating button for available items
- ❌ Red button when item already in cart (for removal)
- 🔒 Disabled increment button with reduced opacity at max stock
- 📊 Stock count displayed in cart for transparency

## Benefits
1. **Prevents Overselling**: Users cannot add more items than available
2. **Clear Communication**: Stock limits shown and explained to users
3. **Better UX**: Visual cues (disabled buttons) prevent confusion
4. **Data Integrity**: Cart quantities always valid against inventory
5. **Transparent**: Users can see available stock in cart view
