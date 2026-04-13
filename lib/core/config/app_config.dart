enum Environment {
  dev,
  test,
  prod,
}

class AppConfig {
  final Environment environment;
  final String baseUrl;
  final String apiVersion;
  final bool enableLogging;
  final bool enablePrettyLogger;
  final String appName;
  final String appVersion;

  AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.apiVersion,
    required this.enableLogging,
    required this.enablePrettyLogger,
    required this.appName,
    required this.appVersion,
  });

  static late AppConfig _instance;

  static AppConfig get instance => _instance;

  static void initialize({
    required Environment environment,
    required String baseUrl,
    String apiVersion = 'v1',
    bool? enableLogging,
    bool? enablePrettyLogger,
    String appName = 'Put Away',
    String appVersion = '1.0.0',
  }) {
    _instance = AppConfig._(
      environment: environment,
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      enableLogging: enableLogging ?? (environment != Environment.prod),
      enablePrettyLogger: enablePrettyLogger ?? (environment == Environment.dev),
      appName: appName,
      appVersion: appVersion,
    );
  }

  static AppConfig development() {
    return AppConfig._(
      environment: Environment.dev,
      baseUrl: 'http://129.154.245.81:7070',
      apiVersion: 'jderest',
      enableLogging: true,
      enablePrettyLogger: true,
      appName: 'Put Away DEV',
      appVersion: '1.0.0-dev',
    );
  }

  static AppConfig testing() {
    return AppConfig._(
      environment: Environment.test,
      baseUrl: 'http://129.154.245.81:7070',
      apiVersion: 'jderest',
      enableLogging: true,
      enablePrettyLogger: true,
      appName: 'Put Away TEST',
      appVersion: '1.0.0-test',
    );
  }

  static AppConfig production() {
    return AppConfig._(
      environment: Environment.prod,
      baseUrl: 'http://129.154.245.81:7070',
      apiVersion: 'jderest',
      enableLogging: false,
      enablePrettyLogger: false,
      appName: 'Put Away',
      appVersion: '1.0.0',
    );
  }

  bool get isDevelopment => environment == Environment.dev;
  bool get isTesting => environment == Environment.test;
  bool get isProduction => environment == Environment.prod;

  String get fullBaseUrl => '$baseUrl/$apiVersion';
}
