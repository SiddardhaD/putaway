# 🔍 Login Navigation Debug Guide

## ✅ Changes Made

### 1. Added Comprehensive Logging

**ViewModel** (`login_viewmodel.dart`):
```dart
_logger.i('LoginViewModel: Starting login for user: $username');
_logger.i('LoginViewModel: Login successful - ${user.username}');
_logger.e('LoginViewModel: Login failed - ${failure.message}');
```

**Repository** (`auth_repository_impl.dart`):
```dart
_logger.i('AuthRepository: Calling remote data source for login');
_logger.i('AuthRepository: Login API successful, caching user data');
_logger.i('AuthRepository: User cached successfully');
_logger.d('AuthRepository: Converted to entity - id: ${userEntity.id}');
```

**Login Screen** (`login_screen.dart`):
```dart
_logger.i('LoginScreen: Form validated, calling login');
_logger.i('LoginScreen: State changed from $previous to $next');
_logger.i('LoginScreen: Login successful! User: ${user.username}');
_logger.i('LoginScreen: Navigating to search screen');
```

### 2. Fixed State Listener

Moved `ref.listen` from `initState` to `build` method (correct Riverpod pattern):

```dart
@override
Widget build(BuildContext context) {
  final loginState = ref.watch(loginViewModelProvider);
  
  // Listen to state changes here (in build method)
  ref.listen<LoginState>(
    loginViewModelProvider,
    (previous, next) {
      next.when(
        success: (user) {
          // Show SnackBar
          // Navigate to search
        },
        error: (message) {
          // Show error
        },
        ...
      );
    },
  );
  
  ...
}
```

---

## 📊 Expected Log Flow

When you login, you should see these logs in order:

```
1. LoginScreen: Form validated, calling login
2. LoginViewModel: Starting login for user: NBARANWAL
3. AuthRepository: Calling remote data source for login
4. [Dio logs - API request/response]
5. AuthRepository: Login API successful, caching user data
6. AuthRepository: User model - username: NBARANWAL, env: JPS920
7. AuthRepository: User cached successfully
8. AuthRepository: Converted to entity - id: 61006, username: NBARANWAL
9. LoginViewModel: Login successful - NBARANWAL
10. LoginScreen: State changed from loading to success
11. LoginScreen: Login successful! User: NBARANWAL
12. LoginScreen: Navigating to search screen
13. [Navigation happens]
```

---

## 🐛 Debugging Steps

### Step 1: Check Current Logs

After clicking login, look for these specific log entries:

✅ **If you see**: `LoginViewModel: Login successful - NBARANWAL`
- API call worked
- Check if state listener is triggered

✅ **If you see**: `LoginScreen: State changed from...`
- Listener is working
- Check navigation code

❌ **If you DON'T see**: Any LoginScreen logs
- State listener not working
- Try hot restart (not just hot reload)

### Step 2: Hot Restart the App

**Important**: Stop and restart the app completely:

```bash
# Press 'R' in terminal for hot restart
# Or stop and run again:
flutter run --target lib/main_dev.dart
```

### Step 3: Try Login Again

1. Enter credentials
2. Click login
3. Watch the logs carefully
4. Look for the log sequence above

---

## 🔧 Common Issues & Fixes

### Issue 1: Navigation Not Working

**Solution**: Changed from `const SearchRoute()` to `SearchRoute()` (no const)

```dart
// Before
context.router.replace(const SearchRoute());

// After  
context.router.replace(SearchRoute());
```

### Issue 2: State Listener Not Firing

**Solution**: Moved `ref.listen` from `initState` to `build` method

### Issue 3: JSON Parsing Error

**Solution**: Added detailed logging in repository to catch parsing errors

---

## 🚀 Test Now

1. **Stop the app** completely (not just hot reload)
2. **Run again**:
   ```bash
   flutter run --target lib/main_dev.dart
   ```
3. **Login** with:
   - Username: `NBARANWAL`
   - Password: `NBARANWAL`

4. **Watch logs** for the sequence I showed above

---

## 📝 What to Report

If navigation still doesn't work, copy and share these specific log lines:

1. `LoginViewModel: Login successful...` ✅ or ❌
2. `LoginScreen: State changed...` ✅ or ❌
3. `LoginScreen: Navigating to search screen` ✅ or ❌
4. Any error logs between these

---

## ✨ Files Updated

- ✅ `login_viewmodel.dart` - Added logging
- ✅ `auth_repository_impl.dart` - Added detailed logging
- ✅ `login_screen.dart` - Fixed listener placement, added logging
- ✅ `app_config.dart` - Fixed URL construction

---

**Next Step**: Stop the app, restart it, and try login again. The logs will tell us exactly what's happening! 🔍
