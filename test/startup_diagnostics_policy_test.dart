import 'package:flutter_test/flutter_test.dart';
import 'package:plant_ai_disease_flutter/core/config/startup_diagnostics_policy.dart';

void main() {
  test('skips startup diagnostics on web', () {
    expect(shouldRunStartupDiagnostics(isWeb: true), isFalse);
  });

  test('keeps startup diagnostics enabled off web', () {
    expect(shouldRunStartupDiagnostics(isWeb: false), isTrue);
  });
}
