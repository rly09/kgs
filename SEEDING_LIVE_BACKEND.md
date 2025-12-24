# Seeding the Live Backend Database on Render

## Problem
The live backend at `https://kgs-backend-ej2z.onrender.com` doesn't have any data yet, so admin login fails with "Invalid credentials".

## Solution Options

### Option 1: Run Seed Script via Render Shell (Recommended)

1. Go to your Render dashboard: https://dashboard.render.com
2. Navigate to your `kgs-backend` service
3. Click on the "Shell" tab
4. Run the following command:
   ```bash
   python -m app.seed
   ```

This will create:
- Default admin: Phone `9999999999`, Password `admin123`
- 5 categories (Groceries, Snacks, Beverages, Household, Personal Care)
- 18 sample products
- Default settings (discount: 0%)

### Option 2: Add Seed Command to Render Build

Update your `render.yaml` or build command in Render dashboard:

**Build Command:**
```bash
pip install -r requirements.txt && python -m app.seed
```

**Start Command:**
```bash
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

### Option 3: Create Admin via API Endpoint (If Available)

If you have an endpoint to create admin users, you can use it. Otherwise, you'll need to add one temporarily.

### Option 4: Manual Database Access

If Render provides database access:
1. Connect to your database
2. Run SQL to create admin user with hashed password

---

## Quick Test After Seeding

Once seeded, test the admin login:

**Credentials:**
- Phone: `9999999999`
- Password: `admin123`

**Test via API:**
```bash
curl -X POST "https://kgs-backend-ej2z.onrender.com/api/auth/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"phone": "9999999999", "password": "admin123"}'
```

You should get a response with an `access_token`.

---

## Verification

After seeding, verify the data:

1. **Check categories:**
   ```
   https://kgs-backend-ej2z.onrender.com/api/categories
   ```
   Should return 5 categories

2. **Check products:**
   ```
   https://kgs-backend-ej2z.onrender.com/api/products
   ```
   Should return 18 products

3. **Test admin login in the app:**
   - Open the Flutter app
   - Select "Admin Login"
   - Phone: `9999999999`
   - Password: `admin123`
   - Should successfully login

---

## Important Notes

- The seed script only runs if the database is empty (checks for existing admin)
- If you need to re-seed, you'll need to clear the database first
- The password is hashed using bcrypt before storing
- All timestamps use UTC

---

## Alternative: Use Local Backend for Testing

If you can't seed the live backend immediately, you can temporarily switch back to local backend:

1. Edit `lib/data/api/api_constants.dart`
2. Change:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
   // OR
   static const String baseUrl = 'http://localhost:8000'; // For other platforms
   ```
3. Make sure your local backend is running
4. Hot restart the app

Then switch back to live backend URL when ready.
