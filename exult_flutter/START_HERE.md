# 🎯 START HERE - Firebase Setup for Exult

**Target Project ID:** `exult-web-prod-2` (will be created during setup)

---

## ⚡ Quick Setup (2 Commands)

### Step 1: Run This Command

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

**IMPORTANT:** NO `--project` flag! Let it create the project interactively.

**When prompted:**
1. Select: **"Create a new Firebase project"**
2. Enter ID: `exult-web-prod-2` (or try `exult-web-prod-3` if taken)
3. Select platform: **web** (DOWN arrow, SPACEBAR, ENTER)

---

### Step 2: Add Import to main.dart

Open `lib/main.dart` and add this after line 3:

```dart
import 'firebase_options.dart';
```

---

### Step 3: Enable Firebase Services

Visit: **https://console.firebase.google.com**

Find your project, then enable:
1. **Authentication** → Email/Password
2. **Firestore Database** → Test mode → `asia-south1`
3. **Firebase Storage** → Test mode → Same location

---

### Step 4: Run the App

```bash
flutter run -d chrome
```

Done! ✅

---

## 🎬 Alternative: Use Interactive Script

```cmd
setup_firebase.bat
```

Then press:
- **1** → Login
- **2** → Configure (creates project)
- **4** → Shows import instructions
- **5** → Run app

---

## ❌ Error You Just Got (FIXED)

**Error:** `Firebase project id "exult-web-prod-2" could not be found`

**Why:** The command was trying to USE an existing project instead of CREATING a new one.

**Fix:** Run the command WITHOUT `--project` flag:

✅ **CORRECT:**
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

❌ **WRONG (what you tried):**
```bash
dart pub global run flutterfire_cli:flutterfire configure --project=exult-web-prod-2
```

---

## 📂 After Configuration Succeeds

You'll have these new files:
- `lib/firebase_options.dart` ← Firebase config
- `.firebaserc` ← Your project ID

Check your project ID:
```bash
type .firebaserc
```

---

## ✅ Success Checklist

- [ ] `firebase_options.dart` created
- [ ] Import added to `main.dart`
- [ ] Auth enabled in Firebase Console
- [ ] Firestore created
- [ ] Storage enabled
- [ ] App runs without errors

---

## 🔗 Quick Links

- **Firebase Console:** https://console.firebase.google.com
- **Full Guide:** See `QUICK_START.md` or `FIREBASE_SETUP.md`

---

**Run this command now:**

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

Then select "Create a new Firebase project" when prompted! 🚀
