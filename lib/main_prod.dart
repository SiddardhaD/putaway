import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  final config = AppConfig.production();
  AppConfig.initialize(
    environment: config.environment,
    baseUrl: config.baseUrl,
    apiVersion: config.apiVersion,
    enableLogging: config.enableLogging,
    enablePrettyLogger: config.enablePrettyLogger,
    appName: config.appName,
    appVersion: config.appVersion,
  );

  await mainCommon(config);
}
