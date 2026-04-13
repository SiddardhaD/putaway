# Put Away - Flutter Warehouse Management App

A professional Flutter application built with Clean Architecture, Riverpod state management, and modern best practices.

## Features

- **Clean Architecture**: Separation of concerns with Domain, Data, and Presentation layers
- **Riverpod**: Modern state management with type safety
- **Freezed**: Immutable data classes with code generation
- **Auto Route**: Type-safe navigation with deep linking support
- **Dio**: Powerful HTTP client for API calls
- **Multi-flavor**: Support for Development, Testing, and Production environments
- **Barcode Scanner**: Mobile scanner integration for warehouse operations
- **Material Design 3**: Modern, beautiful UI with custom theme

## Project Structure

```
lib/
├── app.dart                      # Main app configuration
├── main.dart                     # Default entry point
├── main_dev.dart                 # Development flavor entry
├── main_test.dart                # Testing flavor entry
├── main_prod.dart                # Production flavor entry
├── core/
│   ├── config/                   # App configuration
│   ├── constants/                # App constants, colors, strings
│   ├── di/                       # Dependency injection
│   ├── error/                    # Error handling
│   ├── network/                  # Network layer (Dio)
│   ├── router/                   # Auto Route configuration
│   ├── theme/                    # App theme
│   ├── utils/                    # Utilities (storage, helpers, validators)
│   └── widgets/                  # Reusable widgets
└── features/
    ├── auth/                     # Authentication feature
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── screens/
    │       ├── states/
    │       ├── viewmodels/
    │       └── widgets/
    ├── search/                   # Search feature
    └── records/                  # Records management feature
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd putaway
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running the App

#### Development Environment
```bash
flutter run --target lib/main_dev.dart --flavor dev
```

#### Testing Environment
```bash
flutter run --target lib/main_test.dart --flavor test
```

#### Production Environment
```bash
flutter run --target lib/main_prod.dart --flavor prod
```

#### Default (Development)
```bash
flutter run
```

## Code Generation

This project uses code generation for several features:

- **Freezed**: For immutable data classes
- **JSON Serializable**: For JSON serialization
- **Riverpod Generator**: For providers
- **Auto Route**: For routing
- **Injectable**: For dependency injection

### Generate Code

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Configuration

### Environment Configuration

Update the API base URLs in `lib/core/config/app_config.dart`:

```dart
static AppConfig development() {
  return AppConfig._(
    environment: Environment.dev,
    baseUrl: 'https://dev-api.putaway.com',  // Update this
    ...
  );
}
```

### API Endpoints

Update API endpoints in `lib/core/constants/app_constants.dart`:

```dart
static const String endpointLogin = '/auth/login';
static const String endpointSearchOrders = '/orders/search';
// ... add more endpoints
```

## Features Breakdown

### 1. Login Screen
- Organization selection
- Username and password authentication
- Remember me functionality
- Modern gradient design

### 2. Search Screen
- Organization selector
- Multiple order types (Purchase Order, Transfer Order, RMA, ASN, Receipt, Intransit Shipment)
- Barcode scanner integration
- Order number search

### 3. Records List Screen
- Display order records in a table
- Item code search
- Line number filtering
- Quick access to record details

### 4. Add Record Screen
- Subinventory input with scanner
- Locator input with scanner
- Quantity input
- Lot/Serial number entry

### 5. Update Record Screen
- Edit existing record details
- Validation for all fields
- Save and cancel actions

### 6. Submit Record Screen
- Review record summary
- Confirmation dialog
- Final submission

## State Management

This app uses Riverpod with the following pattern:

```
UI -> State -> ViewModel -> UseCase -> Repository -> Data Source
```

Example:
```dart
// State
const factory LoginState.loading() = _Loading;
const factory LoginState.success(UserEntity user) = _Success;
const factory LoginState.error(String message) = _Error;

// ViewModel
class LoginViewModel extends StateNotifier<LoginState> {
  Future<void> login(...) async {
    state = const LoginState.loading();
    // Call use case
  }
}

// Provider
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(ref.read(loginUseCaseProvider)),
);
```

## Testing

### Run Tests
```bash
flutter test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

## Building for Release

### Android
```bash
flutter build apk --target lib/main_prod.dart --flavor prod --release
flutter build appbundle --target lib/main_prod.dart --flavor prod --release
```

### iOS
```bash
flutter build ios --target lib/main_prod.dart --flavor prod --release
```

## Dependencies

### Core
- `flutter_riverpod`: State management
- `freezed`: Code generation for immutable classes
- `auto_route`: Type-safe navigation
- `dio`: HTTP client
- `get_it` & `injectable`: Dependency injection

### UI
- `google_fonts`: Custom fonts
- `mobile_scanner`: Barcode scanning
- `cached_network_image`: Image caching
- `flutter_svg`: SVG support

### Utilities
- `shared_preferences`: Local storage
- `flutter_secure_storage`: Secure storage
- `intl`: Internationalization
- `dartz`: Functional programming (Either)
- `logger`: Logging

## API Response Models

Expected API response format:

```json
{
  "success": true,
  "data": {
    "id": "123",
    "username": "john_doe",
    "email": "john@example.com",
    "token": "jwt_token_here"
  },
  "message": "Login successful"
}
```

For lists:

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "orderNumber": "UK555955",
      "orderType": "PURCHASE_ORDER"
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. **Build Runner Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Router Not Found**
   - Make sure to run code generation
   - Check that `@RoutePage()` annotation is present on screens

3. **Riverpod Provider Errors**
   - Ensure providers are properly defined
   - Check that providers are generated with build_runner

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## License

This project is private and confidential.

## Contact

For questions or support, contact the development team.
