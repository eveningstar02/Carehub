import 'package:carehub_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runs without Supabase until .env is configured', () {
    expect(AppConfig.hasSupabase, isFalse);
  });
}
