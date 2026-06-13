import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/config/startup_diagnostics_policy.dart';
import 'core/providers/providers.dart';
import 'core/utils/app_diagnostics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await EnvConfig.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase with environment variables and better error handling
  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: true,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      // Configure to use custom 'plant_disease' schema
      postgrestOptions: const PostgrestClientOptions(
        schema: 'plant_disease',
      ),
    );

    debugPrint('🔗 Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
    debugPrint('🔍 Check your SUPABASE_URL and SUPABASE_ANON_KEY in .env file');
    debugPrint('🌐 Ensure you have internet connectivity');
  }

  // Print configuration status for debugging
  EnvConfig.printConfigStatus();

  // Native diagnostics touch camera/location APIs that are not part of the public web shell.
  if (shouldRunStartupDiagnostics(isWeb: kIsWeb)) {
    unawaited(AppDiagnostics.runDiagnostics());
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
      ],
      child: const PlantDiseaseApp(),
    ),
  );
}
