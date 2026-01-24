@echo off
REM Firebase Setup Script for Exult Flutter App
REM Project ID: exult-web-prod-2 (will be created during setup)

echo ==========================================
echo Firebase Setup for Exult Book Lending
echo Target Project ID: exult-web-prod-2
echo ==========================================
echo.

:MENU
echo Select an option:
echo.
echo 1. Login to Firebase
echo 2. Configure Firebase (Create Project)
echo 3. Check Configuration Status
echo 4. Update main.dart (add import)
echo 5. Run Flutter App
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto LOGIN
if "%choice%"=="2" goto CONFIGURE
if "%choice%"=="3" goto CHECK
if "%choice%"=="4" goto UPDATE_MAIN
if "%choice%"=="5" goto RUN
if "%choice%"=="6" goto END
echo Invalid choice. Please try again.
echo.
goto MENU

:LOGIN
echo.
echo ==========================================
echo Step 1: Login to Firebase
echo ==========================================
echo.
echo This will open your browser to sign in with Google.
echo.
pause
dart pub global run flutterfire_cli:flutterfire login
echo.
if %errorlevel% equ 0 (
    echo [SUCCESS] Logged in successfully!
) else (
    echo [ERROR] Login failed. Please try again.
)
echo.
echo Press any key to return to menu...
pause > nul
cls
goto MENU

:CONFIGURE
echo.
echo ==========================================
echo Step 2: Configure Firebase
echo ==========================================
echo.
echo INTERACTIVE PROMPTS YOU'LL SEE:
echo.
echo 1. "Select a Firebase project:"
echo    - Choose: Create a new Firebase project
echo    - Press ENTER
echo.
echo 2. "Enter a project id:"
echo    - Type: exult-web-prod-2
echo    - (Or use a different name if taken)
echo    - Press ENTER
echo.
echo 3. "Which platforms?"
echo    - Use DOWN ARROW to navigate to "web"
echo    - Press SPACEBAR to select (checkmark appears)
echo    - Press ENTER to confirm
echo.
echo Ready to start? Press any key...
pause > nul
echo.
echo Running configuration...
echo.
dart pub global run flutterfire_cli:flutterfire configure
echo.
if exist lib\firebase_options.dart (
    echo.
    echo ==========================================
    echo [SUCCESS] Configuration Complete!
    echo ==========================================
    echo.
    echo Files created:
    echo - lib\firebase_options.dart
    echo - .firebaserc
    echo.
    echo NEXT STEPS:
    echo 1. Run option 4 to update main.dart
    echo 2. Go to Firebase Console
    echo 3. Enable Authentication (Email/Password)
    echo 4. Create Firestore Database (test mode)
    echo 5. Enable Firebase Storage (test mode)
    echo 6. Run option 5 to test the app
    echo.
    echo Firebase Console will be at:
    echo https://console.firebase.google.com
    echo Look for your project (check .firebaserc for project ID)
    echo.
) else (
    echo.
    echo [WARNING] firebase_options.dart not found
    echo Configuration may have failed.
    echo Please try running option 2 again.
    echo.
)
echo Press any key to return to menu...
pause > nul
cls
goto MENU

:CHECK
echo.
echo ==========================================
echo Configuration Status Check
echo ==========================================
echo.
echo Checking required files...
echo.
if exist lib\firebase_options.dart (
    echo [OK] lib\firebase_options.dart exists
    echo      Firebase configuration is ready
) else (
    echo [MISSING] lib\firebase_options.dart not found
    echo           Run option 2 to configure Firebase
)
echo.
if exist .firebaserc (
    echo [OK] .firebaserc exists
    echo.
    echo Project ID from .firebaserc:
    type .firebaserc
) else (
    echo [MISSING] .firebaserc not found
)
echo.
findstr /C:"import 'firebase_options.dart'" lib\main.dart >nul
if %errorlevel% equ 0 (
    echo [OK] main.dart has firebase_options.dart import
) else (
    echo [MISSING] main.dart needs firebase_options.dart import
    echo           Run option 4 to fix this
)
echo.
findstr /C:"Firebase.initializeApp" lib\main.dart >nul
if %errorlevel% equ 0 (
    echo [OK] main.dart has Firebase.initializeApp
) else (
    echo [MISSING] main.dart needs Firebase.initializeApp uncommented
)
echo.
echo ==========================================
echo Firebase Console Checklist
echo ==========================================
echo.
echo Visit: https://console.firebase.google.com
echo (Find your project - check .firebaserc for exact ID)
echo.
echo Required services to enable:
echo [ ] Authentication - Email/Password provider
echo [ ] Firestore Database - Start in test mode
echo [ ] Firebase Storage - Start in test mode
echo.
echo Press any key to return to menu...
pause > nul
cls
goto MENU

:UPDATE_MAIN
echo.
echo ==========================================
echo Step 4: Update main.dart
echo ==========================================
echo.
if not exist lib\firebase_options.dart (
    echo [ERROR] firebase_options.dart not found!
    echo Please run option 2 to configure Firebase first.
    echo.
    pause
    cls
    goto MENU
)
echo Checking main.dart for required import...
echo.
findstr /C:"import 'firebase_options.dart'" lib\main.dart >nul
if %errorlevel% equ 0 (
    echo [OK] Import already exists in main.dart
) else (
    echo [INFO] You need to add this import to main.dart
    echo.
    echo Open lib\main.dart and add after line 3:
    echo import 'firebase_options.dart';
    echo.
    echo It should look like:
    echo   import 'package:flutter/material.dart';
    echo   import 'package:firebase_core/firebase_core.dart';
    echo   import 'package:flutter_riverpod/flutter_riverpod.dart';
    echo   import 'firebase_options.dart';  // ADD THIS
    echo   import 'package:exult_flutter/app.dart';
)
echo.
echo Firebase.initializeApp is already uncommented (lines 22-24)
echo.
echo [INFO] After adding the import, come back and run option 5
echo.
echo Press any key to return to menu...
pause > nul
cls
goto MENU

:RUN
echo.
echo ==========================================
echo Step 5: Run Flutter App
echo ==========================================
echo.
if not exist lib\firebase_options.dart (
    echo [ERROR] firebase_options.dart not found!
    echo Please run option 2 to configure Firebase first.
    echo.
    pause
    cls
    goto MENU
)
echo Pre-flight checks...
echo.
findstr /C:"import 'firebase_options.dart'" lib\main.dart >nul
if %errorlevel% equ 0 (
    echo [OK] main.dart has import
) else (
    echo [WARNING] main.dart missing import!
    echo           You must add: import 'firebase_options.dart';
    echo           to lib\main.dart before running the app
    echo.
    echo Press any key to continue anyway (will likely fail)...
    pause
)
echo.
echo Starting Flutter app in Chrome...
echo This may take a few minutes on first run...
echo.
flutter run -d chrome
echo.
pause
cls
goto MENU

:END
echo.
echo ==========================================
echo Setup Complete
echo ==========================================
echo.
echo For detailed instructions, see:
echo - START_HERE.md
echo - QUICK_START.md
echo - FIREBASE_SETUP.md
echo.
echo Firebase Console: https://console.firebase.google.com
echo.
exit /b
