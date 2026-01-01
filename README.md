# KGS Shop - Customer App

Customer-facing mobile application for KGS Shop.

## Features
- Browse products by category
- Search and filter
- Shopping cart
- GPS location picker for delivery
- Secure checkout
- Order tracking
- Order history

## Setup

### Prerequisites
- Flutter SDK 3.5.4+
- Android Studio / VS Code
- Supabase account

### Installation
1. Clone repository
2. Copy `.env.example` to `.env`
3. Add Supabase credentials
4. Run `flutter pub get`
5. Run `flutter run`

### Environment Variables
Create `.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Project Structure
```
lib/
├── main.dart
├── presentation/customer/
├── data/
└── core/
```

## Build
```bash
flutter build apk --release
```

## Related
- Admin app: `d:\kpg\kgs-admin\`
- Shared database: Supabase
