# Quick Reference Guide - Put Away App

## Project Overview

Professional Flutter warehouse management application built with:
- **Architecture**: Clean Architecture (Domain → Data → Presentation)
- **State Management**: Riverpod + ViewModels + States
- **Code Generation**: Freezed, Auto Route, JSON Serializable
- **Navigation**: Auto Route (supports deep linking)
- **API Client**: Dio with interceptors
- **Flavors**: Dev, Test, Production

## Data Flow

```
UI Screen
    ↓
State (Freezed)
    ↓
ViewModel (Riverpod StateNotifier)
    ↓
UseCase (Business Logic)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Remote/Local)
    ↓
Service/API (Dio)
```

## Common Commands

### Development

```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Run development
flutter run

# Run specific flavor
flutter run --target lib/main_dev.dart --flavor dev
flutter run --target lib/main_test.dart --flavor test
flutter run --target lib/main_prod.dart --flavor prod
```

### Clean & Rebuild

```bash
# Full clean
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build Release

```bash
# Android APK
flutter build apk --target lib/main_prod.dart --flavor prod --release

# Android App Bundle
flutter build appbundle --target lib/main_prod.dart --flavor prod --release

# iOS
flutter build ios --target lib/main_prod.dart --flavor prod --release
```

## Project Structure

```
lib/
├── app.dart                          # Main app widget
├── main_dev.dart                     # Dev entry point
├── main_test.dart                    # Test entry point
├── main_prod.dart                    # Prod entry point
│
├── core/
│   ├── config/
│   │   └── app_config.dart           # Environment configs
│   ├── constants/
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_strings.dart          # String constants
│   │   └── app_constants.dart        # App constants
│   ├── di/
│   │   └── injection_container.dart  # Dependency injection
│   ├── error/
│   │   ├── failures.dart             # Failure classes
│   │   └── exceptions.dart           # Exception classes
│   ├── network/
│   │   ├── dio_client.dart           # Dio configuration
│   │   └── interceptors/             # Auth, Error interceptors
│   ├── router/
│   │   └── app_router.dart           # Auto Route config
│   ├── theme/
│   │   └── app_theme.dart            # Material theme
│   ├── utils/
│   │   ├── storage/                  # Secure & local storage
│   │   └── helpers/                  # Validators, date utils
│   └── widgets/                      # Reusable widgets
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/          # Remote & Local data sources
    │   │   ├── models/               # JSON models (Freezed)
    │   │   └── repositories/         # Repository implementations
    │   ├── domain/
    │   │   ├── entities/             # Business entities
    │   │   ├── repositories/         # Repository interfaces
    │   │   └── usecases/             # Business logic
    │   └── presentation/
    │       ├── screens/              # UI screens
    │       ├── states/               # Freezed states
    │       ├── viewmodels/           # Riverpod ViewModels
    │       └── widgets/              # Feature widgets
    ├── search/
    └── records/
```

## Screens Overview

### 1. Login Screen (`/login`)
- Organization code input
- Username & password fields
- Remember me checkbox
- Beautiful gradient background
- Navigation: → Search Screen

### 2. Search Screen (`/search`)
- Organization selector
- Radio button order types:
  - Purchase Order
  - Transfer Order
  - RMA
  - ASN
  - Receipt
  - Intransit Shipment
- Order number input with barcode scanner
- Navigation: → Records List Screen

### 3. Records List Screen (`/records`)
- Order details header (Order #)
- Item code search
- Line number filter
- Data table with columns:
  - Line, Sch. No, Receipt, Item, More
- Navigation: → Add Record Screen

### 4. Add Record Screen (`/records/add`)
- Subinventory input (with scanner)
- Locator input (with scanner)
- Quantity input (with scanner/clear)
- Add Lot/Serial button
- Navigation: → Records List Screen

### 5. Update Record Screen (`/records/:id/update`)
- Record info display
- Editable fields: Subinventory, Locator, Quantity, Lot Number
- Save & Cancel buttons
- Navigation: ← Records List Screen

### 6. Submit Record Screen (`/records/:id/submit`)
- Summary view with icons
- All record details
- Info banner
- Submit button with confirmation dialog
- Navigation: → Search Screen (after submit)

## State Management Pattern

### States (Freezed)

```dart
@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success(UserEntity user) = _Success;
  const factory LoginState.error(String message) = _Error;
}
```

### ViewModels (Riverpod)

```dart
class LoginViewModel extends StateNotifier<LoginState> {
  final LoginUseCase loginUseCase;

  LoginViewModel(this.loginUseCase) : super(const LoginState.initial());

  Future<void> login({...}) async {
    state = const LoginState.loading();
    final result = await loginUseCase(...);
    result.fold(
      (failure) => state = LoginState.error(failure.message),
      (user) => state = LoginState.success(user),
    );
  }
}
```

### UI (Screens)

```dart
@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    
    return state.when(
      initial: () => _buildForm(),
      loading: () => LoadingWidget(),
      success: (user) => _navigateToHome(),
      error: (message) => ErrorWidget(message: message),
    );
  }
}
```

## API Integration

### Configure Base URLs

Edit `lib/core/config/app_config.dart`:

```dart
static AppConfig development() {
  return AppConfig._(
    baseUrl: 'https://your-dev-api.com',  // ← Update
    ...
  );
}
```

### Define Endpoints

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String endpointLogin = '/auth/login';
static const String endpointSearchOrders = '/orders/search';
// Add more endpoints...
```

### Expected API Response Format

```json
{
  "success": true,
  "data": {
    "id": "123",
    "username": "john_doe",
    "email": "john@example.com",
    "token": "jwt_token_here"
  },
  "message": "Success message"
}
```

For arrays:

```json
{
  "success": true,
  "data": [
    {"id": "1", "name": "Item 1"},
    {"id": "2", "name": "Item 2"}
  ]
}
```

## Adding a New Feature

### Step 1: Create Domain Layer

```dart
// 1. Entity (lib/features/feature_name/domain/entities/)
class FeatureEntity extends Equatable { ... }

// 2. Repository Interface (lib/features/feature_name/domain/repositories/)
abstract class FeatureRepository { ... }

// 3. UseCase (lib/features/feature_name/domain/usecases/)
class GetFeatureUseCase {
  final FeatureRepository repository;
  Future<Either<Failure, FeatureEntity>> call() { ... }
}
```

### Step 2: Create Data Layer

```dart
// 1. Model (lib/features/feature_name/data/models/)
@freezed
class FeatureModel with _$FeatureModel {
  factory FeatureModel.fromJson(Map<String, dynamic> json);
  FeatureEntity toEntity();
}

// 2. Data Source (lib/features/feature_name/data/datasources/)
abstract class FeatureRemoteDataSource { ... }
class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource { ... }

// 3. Repository Implementation
class FeatureRepositoryImpl implements FeatureRepository { ... }
```

### Step 3: Create Presentation Layer

```dart
// 1. State (lib/features/feature_name/presentation/states/)
@freezed
class FeatureState with _$FeatureState { ... }

// 2. ViewModel (lib/features/feature_name/presentation/viewmodels/)
class FeatureViewModel extends StateNotifier<FeatureState> { ... }

// 3. Screen (lib/features/feature_name/presentation/screens/)
@RoutePage()
class FeatureScreen extends ConsumerWidget { ... }
```

### Step 4: Register Route

Edit `lib/core/router/app_router.dart`:

```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    ...
    AutoRoute(page: FeatureRoute.page, path: '/feature'),
  ];
}
```

### Step 5: Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Widgets Library

### Custom Widgets

- `CustomTextField`: Styled text input with label, validation
- `CustomButton`: Primary button with loading state
- `CustomOutlinedButton`: Secondary outlined button
- `LoadingWidget`: Circular progress with optional message
- `ErrorWidget`: Error display with retry button
- `EmptyWidget`: Empty state with icon and message
- `BarcodeScannerWidget`: Mobile scanner integration

### Usage Examples

```dart
// Text Field
CustomTextField(
  label: 'Username',
  hint: 'Enter username',
  controller: _usernameController,
  validator: Validators.validateUsername,
  prefixIcon: Icon(Icons.person),
)

// Button
CustomButton(
  text: 'Login',
  onPressed: _handleLogin,
  isLoading: isLoading,
)

// Barcode Scanner
final code = await showBarcodeScanner(
  context,
  title: 'Scan Barcode',
);
```

## Theming

### Colors

Located in `lib/core/constants/app_colors.dart`:

- Primary: `#1976D2` (Blue)
- Secondary: `#2196F3` (Light Blue)
- Background: `#F5F7FA` (Light Gray)
- Error: `#D32F2F` (Red)
- Success: `#388E3C` (Green)

### Typography

Uses Google Fonts (Inter family) configured in `app_theme.dart`.

## Storage

### Secure Storage (Tokens, Sensitive Data)

```dart
final secureStorage = SecureStorageService();
await secureStorage.write('key', 'value');
final value = await secureStorage.read('key');
```

### Local Storage (Preferences)

```dart
final localStorage = LocalStorageService();
await localStorage.setString('key', 'value');
final value = localStorage.getString('key');
```

## Error Handling

### Failures (Domain Layer)

```dart
Either<Failure, Result> result = await useCase();
result.fold(
  (failure) => handleError(failure.message),
  (data) => handleSuccess(data),
);
```

### Exceptions (Data Layer)

```dart
try {
  final response = await dioClient.get('/endpoint');
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message));
} on NetworkException catch (e) {
  return Left(NetworkFailure(message: e.message));
}
```

## Testing

### Unit Tests

```dart
test('should return UserEntity on successful login', () async {
  // Arrange
  when(mockRepository.login(...)).thenAnswer((_) async => Right(user));
  
  // Act
  final result = await useCase(...);
  
  // Assert
  expect(result, Right(user));
});
```

### Widget Tests

```dart
testWidgets('should display login form', (tester) async {
  await tester.pumpWidget(ProviderScope(child: LoginScreen()));
  expect(find.text('Login'), findsOneWidget);
});
```

## Troubleshooting

### Issue: Build Runner Conflicts

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Router Not Found

- Ensure `@RoutePage()` annotation on screens
- Run code generation
- Check import statements

### Issue: Provider Not Found

- Check provider is defined
- Ensure proper import
- Verify ProviderScope wraps MaterialApp

### Issue: Model Serialization Error

- Check JSON field names match model
- Verify `fromJson` and `toJson` are generated
- Run build_runner

## Performance Tips

1. Use `const` constructors where possible
2. Implement `keys` for stateful widgets in lists
3. Use `ListView.builder` for long lists
4. Cache network images with `CachedNetworkImage`
5. Minimize widget rebuilds with `select` in Riverpod

## Security Best Practices

1. Store tokens in `SecureStorage`
2. Never commit API keys or secrets
3. Use HTTPS for all API calls
4. Validate all user inputs
5. Sanitize data before display

## Next Steps

1. Update API base URLs in config
2. Implement actual API integration
3. Add unit tests
4. Add widget tests
5. Configure CI/CD
6. Set up analytics
7. Add crash reporting

## Support

For questions or issues:
1. Check this documentation
2. Review the code comments
3. Check Flutter/Riverpod documentation
4. Contact the development team

---

**Last Updated**: 2026-04-11
**Version**: 1.0.0
