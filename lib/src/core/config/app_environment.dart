import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

/// Centralized environment configuration abstraction for production hardening.
class AppEnvironment {
  const AppEnvironment._();

  static const Environment current = kReleaseMode
      ? Environment.production
      : Environment.development;

  static bool get isProduction => current == Environment.production;
  static bool get isDevelopment => current == Environment.development;

  static bool get enableSeedTools => isDevelopment;
  static bool get enableDebugBanners => isDevelopment;
  static bool get enableVerboseLogging => isDevelopment;
}
