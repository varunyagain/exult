# 🚀 Quick Start - Firebase Setup for Exult

**Target Project ID:** `exult-web-prod-2` (will be created during setup)

---

## ⚡ Method 1: Interactive Script (Easiest!)

```cmd
cd exult_flutter
setup_firebase.bat
```

Then follow the menu:
- Press **1** → Login to Firebase
- Press **2** → Configure Firebase (creates new project)
- Press **4** → Update main.dart
- Press **5** → Run the app

---

## 📋 Method 2: Manual Commands

### Step 1: Login to Firebase

```bash
dart pub global run flutterfire_cli:flutterfire login
```

**What happens:**
- Browser opens
- Sign in with Google
- Grant permissions
- Close browser, return to terminal

---

### Step 2: Configure Firebase (WITHOUT --project flag)

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

**THIS IS THE KEY COMMAND** - No `--project` flag! Let it create the project interactively.

**Interactive prompts:**

1️⃣ **Select a Firebase project:**
```
? Select a Firebase project to configure your Flutter application with:
  ❯ Create a new Firebase project
    [existing-project-1] (if you have any)
    [existing-project-2]
```
- Use **arrow keys** to select **"Create a new Firebase project"**
- Press **ENTER**

2️⃣ **Enter project ID:**
```
? Enter a project id for your new Firebase project (e.g. my-cool-project)
```
- Type: `exult-web-prod-2`
- Press **ENTER**
- **If this ID is already taken globally**, try:
  - `exult-web-prod-3`
  - `exult-books-2025`
  - `exult-lending-prod`

3️⃣ **Select platforms:**
```
? Which platforms should your configuration support?
  ◯ android
  ◯ ios
  ◯ macos
  ◯ web
  ◯ windows
```
- Press **DOWN ARROW** three times to reach `web`
- Press **SPACEBAR** to select (shows ◉)
- Press **ENTER** to confirm

**Success message:**
```
i Firebase app registered successfully!
✔ Firebase configuration file lib/firebase_options.dart generated successfully.
```

---

### Step 3: Add Import to main.dart

Open `lib/main.dart` and add this import after line 3:

```dart
import 'firebase_options.dart';
```

Your imports should look like:
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';  // ← ADD THIS LINE
import 'package:exult_flutter/app.dart';
```

**Note:** Firebase.initializeApp is already uncommented (lines 22-24) ✅

---

### Step 4: Find Your Project ID

After configuration, check what project ID was created:

```bash
type .firebaserc
```

You'll see something like:
```json
{
  "projects": {
    "default": "exult-web-prod-2"
  }
}
```

This is your actual project ID - use it for the Firebase Console URL below.

---

### Step 5: Enable Firebase Services

1. **Open Firebase Console:**
   ```
   https://console.firebase.google.com
   ```

2. **Find your project** - Look for the project ID from `.firebaserc` (e.g., `exult-web-prod-2`)

3. **Enable Authentication:**
   - Click **Authentication** in sidebar
   - Click **Get Started**
   - Click **Email/Password** provider
   - Toggle **Enable** to ON
   - Click **Save**

4. **Create Firestore Database:**
   - Click **Firestore Database** in sidebar
   - Click **Create database**
   - Select **Start in test mode**
   - Choose location: `asia-south1` (Mumbai) or `us-central1`
   - Click **Enable**

5. **Enable Storage:**
   - Click **Storage** in sidebar
   - Click **Get Started**
   - Select **Start in test mode**
   - Use same location as Firestore
   - Click **Done**

---

### Step 6: Run the App

```bash
flutter run -d chrome
```

**First run takes 2-3 minutes to build!**

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `lib/firebase_options.dart` exists
- [ ] `.firebaserc` exists (contains your project ID)
- [ ] `lib/main.dart` has `import 'firebase_options.dart';`
- [ ] Firebase.initializeApp is uncommented
- [ ] Authentication enabled in Firebase Console
- [ ] Firestore Database created
- [ ] Firebase Storage enabled
- [ ] App runs without Firebase errors

---

## 🎯 Test the Auth Flow

Once the app is running:

1. **Navigate to Sign Up:**
   - Click "Sign In" button
   - Click "Sign Up" link

2. **Create Account:**
   - Enter name: `Test User`
   - Enter email: `test@example.com`
   - Enter password: `Test123!`
   - Click "Sign Up"

3. **Verify in Firebase:**
   - Go to Firebase Console → Your Project → Authentication → Users
   - You should see `test@example.com`

4. **Check Firestore:**
   - Go to Firestore Database → Data
   - You should see `users` collection with your user

---

## 🆘 Troubleshooting

### Error: "Firebase project id could not be found"

**This means:** You used `--project=exult-web-prod-2` but the project doesn't exist yet.

**Fix:** Run WITHOUT the `--project` flag:
```bash
dart pub global run flutterfire_cli:flutterfire configure
```
Then select "Create a new Firebase project" when prompted.

---

### Error: "firebase_options.dart not found"

**Fix:** Run configure command:
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

---

### Error: "DefaultFirebaseOptions not defined"

**Fix:** Add import to main.dart:
```dart
import 'firebase_options.dart';
```

---

### Error: "Project ID already exists"

**This means:** Someone else already used `exult-web-prod-2` globally.

**Fix:** Try a different ID:
- `exult-web-prod-3`
- `exult-books-2025`
- `your-name-exult` (replace your-name)

---

### Browser doesn't open for login

**Fix:** Copy the URL from terminal and paste in browser manually.

---

### "Permission denied" in Firestore

**Fix:**
1. Go to Firestore → Rules
2. Make sure you selected "Start in test mode"
3. Rules should allow read/write initially

---

## 📂 Files Created After Setup

```
exult_flutter/
├── lib/
│   ├── firebase_options.dart  ← Generated config
│   └── main.dart              ← Updated with import
├── .firebaserc                ← Project reference
└── firebase.json              ← Optional hosting config
```

---

## 🔗 Quick Links

After configuration, your Firebase Console will be at:

**https://console.firebase.google.com**

Then find your project (use the ID from `.firebaserc`)

Direct sections:
- Authentication: `/authentication/users`
- Firestore: `/firestore/data`
- Storage: `/storage`

---

## 📞 Next Steps After Setup

Once everything works:
1. ✅ Deploy security rules (see FIREBASE_SETUP.md Step 8)
2. ✅ Create admin user (change role in Firestore)
3. ✅ Add sample books
4. 🚀 Continue building features

---

## 🎬 Ready to Start?

**Run this now:**
```cmd
setup_firebase.bat
```

Or run manually:
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

**Remember:** NO `--project` flag! Let it create the project interactively.
