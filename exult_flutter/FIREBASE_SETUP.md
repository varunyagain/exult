# Firebase Configuration Guide - Exult Book Lending

**Project ID:** `exult-web-prod-2`
**Platform:** Web only

---

## 📋 Overview

This guide walks you through configuring Firebase for your Flutter Web application step by step.

---

## ✅ Prerequisites

Before starting:

- [x] Flutter SDK installed (check: `flutter --version`)
- [x] Dart SDK installed (check: `dart --version`)
- [x] FlutterFire CLI installed (already done)
- [ ] Google account for Firebase
- [ ] Chrome browser installed

---

## 🚀 Step-by-Step Setup

### Step 1: Login to Firebase

Open terminal in the `exult_flutter` directory:

```bash
cd exult_flutter
dart pub global run flutterfire_cli:flutterfire login
```

**What happens:**
1. Terminal displays: "Opening browser for authentication..."
2. Browser opens to Google sign-in page
3. Sign in with your Google account
4. Grant FlutterFire CLI permissions
5. Browser shows: "Successfully authenticated!"
6. Close browser and return to terminal

**Success message:**
```
✔ Success! Logged in as your-email@gmail.com
```

**Troubleshooting:**
- If browser doesn't open: Copy the URL from terminal and paste in browser
- If login fails: Make sure you're using a valid Google account
- If permission denied: Try running terminal as administrator

---

### Step 2: Configure Firebase Project

Run the configuration command with the project ID:

```bash
dart pub global run flutterfire_cli:flutterfire configure --project=exult-web-prod-2
```

**Interactive Prompts:**

#### Prompt 1: Select Firebase Project
```
? Select a Firebase project to configure your Flutter application with:
  ❯ Create a new Firebase project
    [other-project-1] (other-project-1)
    [other-project-2] (other-project-2)
```

**Action:**
- Use **UP/DOWN arrows** to navigate
- Select **"Create a new Firebase project"**
- Press **ENTER**

#### Prompt 2: Enter Project ID
```
? Enter a project id for your new Firebase project (e.g. my-cool-project)
```

**Action:**
- Type: `exult-web-prod-2`
- Press **ENTER**

**Note:** If this ID is taken, try:
- `exult-web-prod-3`
- `exult-books-prod`
- `exult-lending-2025`

#### Prompt 3: Select Platforms
```
? Which platforms should your configuration support (use arrow keys & space to select)?
  ◯ android
  ◯ ios
  ◯ macos
  ◯ web
  ◯ windows
```

**Action:**
1. Press **DOWN ARROW** three times to reach `web`
2. Press **SPACEBAR** to select (◯ becomes ◉)
3. Press **ENTER** to confirm

**Your selection should show:**
```
  ◯ android
  ◯ ios
  ◯ macos
  ◉ web  ← Selected
  ◯ windows
```

#### Prompt 4: Confirmation
```
i Firebase app registered successfully!
✔ Firebase configuration file lib/firebase_options.dart generated successfully.
```

**Files created:**
- `lib/firebase_options.dart` - Firebase configuration for web
- `.firebaserc` - Project reference file

---

### Step 3: Verify Configuration Files

Check that files were created:

**Windows:**
```cmd
dir lib\firebase_options.dart
dir .firebaserc
```

**Expected output:**
```
lib\firebase_options.dart
.firebaserc
```

**Inspect firebase_options.dart:**
```bash
type lib\firebase_options.dart
```

You should see Firebase configuration with:
- `apiKey`
- `authDomain`
- `projectId: "exult-web-prod-2"`
- `storageBucket`
- `messagingSenderId`
- `appId`

---

### Step 4: Update main.dart

**Add Firebase Options Import:**

Open `lib/main.dart` and add this import after line 3:

```dart
import 'firebase_options.dart';
```

**Before:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/app.dart';
```

**After:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';  // ← ADD THIS LINE
import 'package:exult_flutter/app.dart';
```

**Verify Firebase Initialization:**

Check that lines 22-24 are uncommented (they should already be):

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

✅ This should already be done based on your modifications.

---

### Step 5: Enable Firebase Services in Console

Now configure your Firebase project in the web console.

#### 5.1: Open Firebase Console

Visit: https://console.firebase.google.com/project/exult-web-prod-2

(Or go to https://console.firebase.google.com and click on "exult-web-prod-2")

#### 5.2: Enable Authentication

1. Click **Authentication** in the left sidebar
2. Click **Get Started** button
3. Under **Sign-in method** tab:
   - Click **Email/Password**
   - Toggle **Enable** to ON
   - Leave **Email link** disabled
   - Click **Save**

**Verify:** You should see "Email/Password" with status "Enabled"

#### 5.3: Create Firestore Database

1. Click **Firestore Database** in the left sidebar
2. Click **Create database** button
3. **Secure rules for Cloud Firestore:**
   - Select **Start in test mode** (we'll add proper rules later)
   - Click **Next**
4. **Set Cloud Firestore location:**
   - For India: Select `asia-south1` (Mumbai)
   - For US: Select `us-central1`
   - Click **Enable**

**Wait:** Database creation takes 30-60 seconds

**Verify:** You should see "Cloud Firestore" with "Data" tab showing empty database

#### 5.4: Enable Firebase Storage

1. Click **Storage** in the left sidebar
2. Click **Get started** button
3. **Secure rules for Cloud Storage:**
   - Select **Start in test mode**
   - Click **Next**
4. **Set Cloud Storage location:**
   - Use the **same location** as Firestore (e.g., `asia-south1`)
   - Click **Done**

**Verify:** You should see "Storage" with "Files" tab showing empty bucket

---

### Step 6: Test the Application

Now run the app to verify Firebase is working:

```bash
flutter run -d chrome
```

**First Build:**
- Takes 2-5 minutes
- Compiles Dart to JavaScript
- Starts development server
- Opens Chrome

**Expected Output:**
```
Launching lib\main.dart on Chrome in debug mode...
Building application for the web...
...
✓ Built build\web
Chrome is being started in debug mode...
```

**Verify in Browser:**
1. App opens at `http://localhost:xxxxx`
2. You see "Exult" home page
3. No errors in browser console (F12)
4. "Sign In" button is visible

**Check Browser Console:**
- Press **F12** to open Developer Tools
- Click **Console** tab
- Should see no Firebase errors
- Might see: "Firebase initialized successfully"

---

### Step 7: Test Authentication Flow

Test the complete sign-up process:

#### 7.1: Create Test User

1. **In the app:**
   - Click **"Sign In"** button in top navigation
   - Click **"Sign Up"** link at bottom

2. **Fill the form:**
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Password: `Test123!`
   - Confirm Password: `Test123!`
   - Click **"Sign Up"**

3. **Expected behavior:**
   - Loading spinner appears briefly
   - Redirects to "Browse Books" page
   - Shows "Welcome, Test User!"

#### 7.2: Verify in Firebase Console

**Check Authentication:**
1. Go to Firebase Console → **Authentication** → **Users**
2. You should see 1 user:
   - Identifier: `test@example.com`
   - Provider: Email/Password
   - Created: (current timestamp)
   - Signed In: (current timestamp)

**Check Firestore:**
1. Go to Firebase Console → **Firestore Database** → **Data**
2. You should see:
   - Collection: `users`
   - Document: `[auto-generated-uid]`
   - Fields:
     - `uid`: (string)
     - `email`: "test@example.com"
     - `displayName`: "Test User"
     - `role`: "subscriber"
     - `createdAt`: (timestamp)
     - `isActive`: true

#### 7.3: Test Sign Out and Sign In

1. **Sign Out:**
   - Click logout icon in app
   - Should redirect to home page

2. **Sign In:**
   - Click "Sign In"
   - Enter email: `test@example.com`
   - Enter password: `Test123!`
   - Click "Sign In"
   - Should redirect to Browse Books

---

### Step 8: Deploy Security Rules

**Important:** Test mode allows anyone to read/write. Deploy proper security rules for production.

#### 8.1: Open Firestore Rules

1. Go to Firebase Console → **Firestore Database** → **Rules**
2. You'll see test mode rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if
          request.time < timestamp.date(YYYY, M, D);
    }
  }
}
```

#### 8.2: Replace with Production Rules

Click **Edit rules** and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId || isAdmin();
      allow delete: if isAdmin();
    }

    // Subscriptions collection
    match /subscriptions/{subId} {
      allow read: if isAuthenticated() &&
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create, update: if isAuthenticated() &&
                               (request.resource.data.userId == request.auth.uid || isAdmin());
      allow delete: if isAdmin();
    }

    // Books collection
    match /books/{bookId} {
      allow read: if true; // Anyone can browse books
      allow write: if isAdmin(); // Only admins can add/edit books
    }

    // Loans collection
    match /loans/{loanId} {
      allow read: if isAuthenticated() &&
                     (resource.data.borrowerId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated() &&
                       request.resource.data.borrowerId == request.auth.uid;
      allow update: if isAuthenticated() &&
                       (resource.data.borrowerId == request.auth.uid || isAdmin());
      allow delete: if isAdmin();
    }

    // Contact submissions
    match /contacts/{contactId} {
      allow create: if true; // Anyone can submit contact form
      allow read, update, delete: if isAdmin();
    }
  }
}
```

Click **Publish**

**Verify:** Rules should show "Last updated: Just now"

---

## ✅ Setup Checklist

Mark completed items:

### Configuration
- [ ] FlutterFire CLI installed
- [ ] Logged into Firebase
- [ ] Project created: `exult-web-prod-2`
- [ ] `firebase_options.dart` generated
- [ ] `main.dart` updated with import
- [ ] Firebase initialization uncommented

### Firebase Console
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore Database created
- [ ] Firebase Storage enabled
- [ ] Security rules deployed

### Testing
- [ ] App runs without errors
- [ ] Can create user account
- [ ] User appears in Authentication
- [ ] User document created in Firestore
- [ ] Can sign out and sign in

---

## 🆘 Troubleshooting Guide

### Issue: "firebase_options.dart not found"

**Symptoms:**
```
Error: FileSystemException: Cannot open file, path = 'lib/firebase_options.dart'
```

**Solutions:**
1. Run configure again:
   ```bash
   dart pub global run flutterfire_cli:flutterfire configure --project=exult-web-prod-2
   ```
2. Check you're in `exult_flutter` directory
3. Verify file exists: `dir lib\firebase_options.dart`

---

### Issue: "DefaultFirebaseOptions not defined"

**Symptoms:**
```
Error: Undefined name 'DefaultFirebaseOptions'
```

**Solution:**
Add import to `lib/main.dart`:
```dart
import 'firebase_options.dart';
```

---

### Issue: Firebase initialization fails

**Symptoms:**
```
[ERROR:flutter/runtime/dart_vm_initializer.cc] Unhandled Exception: [core/not-initialized]
```

**Solutions:**
1. Verify `firebase_options.dart` exists
2. Check import is added to `main.dart`
3. Ensure `Firebase.initializeApp()` is uncommented
4. Clear build cache: `flutter clean && flutter pub get`

---

### Issue: Authentication "permission-denied"

**Symptoms:**
- Sign up fails with permission error
- Error: "This operation is not allowed"

**Solutions:**
1. Go to Firebase Console → Authentication
2. Verify Email/Password provider is **Enabled**
3. Check toggle is ON (not just added but enabled)

---

### Issue: Firestore "permission-denied"

**Symptoms:**
- User document not created
- Error: "Missing or insufficient permissions"

**Solutions:**
1. Check Firestore rules are in test mode OR
2. Deploy proper security rules (see Step 8)
3. Verify user is authenticated before writing

---

### Issue: App builds but shows blank screen

**Symptoms:**
- Chrome opens but shows white screen
- No content visible

**Solutions:**
1. Check browser console (F12) for errors
2. Verify no JavaScript errors
3. Try hard refresh: Ctrl+Shift+R
4. Stop app and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

---

### Issue: "Project does not exist"

**Symptoms:**
```
Error: Project exult-web-prod-2 does not exist or you don't have access
```

**Solutions:**
1. Login again: `dart pub global run flutterfire_cli:flutterfire login`
2. Check project exists at: https://console.firebase.google.com
3. Try configure without --project flag and select project from list
4. Manually create project in Firebase Console first

---

## 🔗 Useful Links

- **Firebase Console:** https://console.firebase.google.com/project/exult-web-prod-2
- **Authentication Users:** https://console.firebase.google.com/project/exult-web-prod-2/authentication/users
- **Firestore Data:** https://console.firebase.google.com/project/exult-web-prod-2/firestore/data
- **Storage Files:** https://console.firebase.google.com/project/exult-web-prod-2/storage
- **Project Settings:** https://console.firebase.google.com/project/exult-web-prod-2/settings/general

---

## 📚 Additional Resources

- **FlutterFire Documentation:** https://firebase.flutter.dev/
- **Firebase Web Setup:** https://firebase.google.com/docs/web/setup
- **Firestore Security Rules:** https://firebase.google.com/docs/firestore/security/get-started
- **Flutter Web Docs:** https://docs.flutter.dev/platform-integration/web

---

## 🎯 Next Steps

After successful setup:

1. **Create Admin User** (manually in Firestore):
   - Edit your test user document
   - Change `role` from "subscriber" to "admin"

2. **Add Sample Books** (Phase 3):
   - Create books collection
   - Add 10-20 sample books
   - Test book browsing

3. **Continue Development** (Phases 5-6):
   - Static content pages
   - Subscription flow
   - Loan management
   - Admin dashboard

---

**Setup complete!** 🎉

You now have a fully configured Firebase backend for your Flutter Web application.
