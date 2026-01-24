# Exult Book Lending Platform - Flutter Web

A Flutter Web application for the Exult book lending platform, built with Firebase backend and Material UI design.

## Project Structure

```
exult_flutter/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # MaterialApp configuration
│   │
│   ├── core/                        # Core utilities and constants
│   │   ├── constants/
│   │   │   ├── app_constants.dart   # Subscription tiers, pricing
│   │   │   ├── route_constants.dart # Route names
│   │   │   └── firebase_constants.dart # Collection names
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Material theme
│   │   └── utils/
│   │       └── validators.dart      # Form validation
│   │
│   ├── domain/                      # Business logic layer
│   │   ├── models/                  # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── book_model.dart
│   │   │   ├── subscription_model.dart
│   │   │   ├── loan_model.dart
│   │   │   └── contact_model.dart
│   │   └── repositories/            # Repository interfaces
│   │       ├── auth_repository.dart
│   │       └── user_repository.dart
│   │
│   ├── data/                        # Data layer
│   │   └── repositories/            # Firebase implementations
│   │       ├── firebase_auth_repository.dart
│   │       └── firebase_user_repository.dart
│   │
│   ├── presentation/                # UI layer
│   │   ├── providers/               # Riverpod providers
│   │   │   └── auth_provider.dart
│   │   ├── screens/                 # Screen widgets
│   │   │   ├── auth/
│   │   │   │   ├── sign_in_screen.dart
│   │   │   │   └── sign_up_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── books/
│   │   │   │   └── browse_books_screen.dart
│   │   │   ├── profile/
│   │   │   │   └── profile_screen.dart
│   │   │   └── loans/
│   │   │       └── my_loans_screen.dart
│   │   └── navigation/
│   │       └── app_router.dart      # Go_router configuration
│   │
│   └── config/
│       └── firebase_config.dart
│
└── assets/
    └── images/
        └── exult-logo.svg
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.1.5)
- Dart SDK (>=3.1.5)
- Firebase CLI
- A Firebase project (create one at https://console.firebase.google.com)

### Installation

1. **Install dependencies:**
   ```bash
   cd exult_flutter
   flutter pub get
   ```

2. **Configure Firebase:**

   a. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

   b. Login to Firebase:
   ```bash
   firebase login
   ```

   c. Configure your Flutter app:
   ```bash
   flutterfire configure
   ```

   d. Select your Firebase project (or create a new one)

   e. Select platforms (Web)

   This will generate `lib/firebase_options.dart` with your configuration.

3. **Enable Firebase services in the Firebase Console:**

   - Authentication (Email/Password provider)
   - Firestore Database
   - Firebase Storage

4. **Update main.dart:**

   Uncomment the Firebase initialization code in `lib/main.dart`:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

5. **Deploy Firestore security rules:**

   Copy the security rules from the plan document to Firebase Console:
   - Go to Firestore Database → Rules
   - Paste the rules and publish

### Running the Application

#### Development Mode (Web)
```bash
flutter run -d chrome
```

#### Build for Production
```bash
flutter build web --release
```

The build output will be in `build/web/` directory.

### Deployment

#### Firebase Hosting

1. Initialize Firebase Hosting:
   ```bash
   firebase init hosting
   ```

2. Select `build/web` as the public directory

3. Configure as a single-page app: Yes

4. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

## Project Status

### Completed Features

✅ Phase 1: Project Setup & Authentication
- [x] Flutter project structure
- [x] Firebase configuration
- [x] Domain models (User, Book, Loan, Subscription, Contact)
- [x] Constants and theme
- [x] Auth repository interfaces and implementations
- [x] Riverpod providers for auth state
- [x] Sign in and sign up screens
- [x] Go_router with auth guards
- [x] Main app structure

### Remaining Features (TODO)

⬜ Phase 2: Static Content Pages
- [ ] Pricing screen with subscription tiers
- [ ] How It Works screen
- [ ] Contact Us screen with form submission

⬜ Phase 3: Book Browsing
- [ ] Book repository and providers
- [ ] Book browsing screen with grid layout
- [ ] Book detail screen
- [ ] Book card widgets

⬜ Phase 4: Subscription Flow
- [ ] Subscription repository and providers
- [ ] Subscribe screen
- [ ] Mock payment service
- [ ] Payment integration

⬜ Phase 5: Loan Management
- [ ] Loan repository and providers
- [ ] Borrow flow (request, approve, checkout)
- [ ] Return flow
- [ ] My Loans screen with active/past loans

⬜ Phase 6: Admin Dashboard
- [ ] Admin dashboard screen
- [ ] Manage books screen (CRUD operations)
- [ ] View users and loans
- [ ] Admin-only routes and guards

## Key Technologies

- **Flutter**: Cross-platform UI framework
- **Firebase**: Backend services
  - Authentication
  - Firestore (database)
  - Storage (images)
- **Riverpod**: State management
- **Go_router**: Navigation and routing
- **Material UI**: Design system

## Configuration

### Subscription Tiers (INR)

| Tier | Monthly | Annual | Max Books |
|------|---------|--------|-----------|
| One Book | ₹99 | ₹999 | 1 |
| Three Books | ₹199 | ₹1,999 | 3 |
| Five Books | ₹299 | ₹2,999 | 5 |

### Constants

All configurable values are in:
- `lib/core/constants/app_constants.dart` - App-wide constants
- `lib/core/constants/firebase_constants.dart` - Firebase collection names
- `lib/core/constants/route_constants.dart` - Route paths

### Theme

Brand colors and styling are defined in:
- `lib/core/theme/app_theme.dart`
- Primary: #4F46E5 (Indigo)
- Secondary: #10B981 (Green)
- Background: #F7F9FC (Light gray-blue)

## Development Guidelines

### Adding a New Screen

1. Create screen widget in `lib/presentation/screens/[feature]/`
2. Add route in `lib/presentation/navigation/app_router.dart`
3. Add route constant in `lib/core/constants/route_constants.dart`
4. Update navigation guards if needed

### Adding a New Model

1. Create model in `lib/domain/models/`
2. Add Firestore serialization (`toJson`/`fromJson`)
3. Add collection name to `firebase_constants.dart`

### Adding a New Repository

1. Create interface in `lib/domain/repositories/`
2. Create Firebase implementation in `lib/data/repositories/`
3. Create Riverpod provider in `lib/presentation/providers/`

## Testing

### Manual Testing Checklist

- [ ] User can sign up with email/password
- [ ] User can sign in
- [ ] User can sign out
- [ ] Auth state persists on refresh
- [ ] Protected routes redirect to sign in
- [ ] Authenticated users can't access sign in/sign up

### Unit Tests (Future)

Run tests with:
```bash
flutter test
```

## Troubleshooting

### Firebase Initialization Error

If you see Firebase initialization errors:
1. Ensure `flutterfire configure` was run successfully
2. Check that `firebase_options.dart` exists
3. Verify Firebase initialization is uncommented in `main.dart`

### Build Errors

If you encounter build errors:
```bash
flutter clean
flutter pub get
flutter build web
```

### CORS Issues

For Firebase Storage CORS issues in web:
1. Create `cors.json`:
   ```json
   [
     {
       "origin": ["*"],
       "method": ["GET"],
       "maxAgeSeconds": 3600
     }
   ]
   ```
2. Apply to bucket:
   ```bash
   gsutil cors set cors.json gs://your-bucket-name.appspot.com
   ```

## Contributing

When contributing to this project:
1. Follow the existing folder structure
2. Use meaningful commit messages
3. Add comments for complex logic
4. Update this README if adding new features

## License

Proprietary - Exult Book Lending Platform

## Contact

For questions or support, contact: hello@exultbooks.in
