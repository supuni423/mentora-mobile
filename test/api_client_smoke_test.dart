import 'package:flutter_test/flutter_test.dart';
import 'package:mentora_test/services/api_client.dart';

// Hits the live backend, not a mock — requires the Mentora backend running
// locally on the configured AppConfig.baseUrl.
void main() {
  test('ApiClient reaches the live backend health check', () async {
    final client = ApiClient();
    final res = await client.get('/health');
    expect(res, isA<Map>());
    expect(res['status'], 'OK');
  });
}
