import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/hajj_live_http.dart';
import 'package:muhasabah02/domain/hajj_online_assist.dart';

/// Hits a locally running `wrangler dev` (default http://127.0.0.1:8787).
/// Skips when the Worker is not running so `flutter test` stays offline-safe.
void main() {
  final baseUrl =
      Platform.environment['HAJJ_WORKER_URL'] ?? 'http://127.0.0.1:8787';

  Future<bool> workerUp() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse(baseUrl).resolve('/health'),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 2),
      );
      await response.drain<void>();
      client.close(force: true);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  test(
    'Flutter client talks to local Worker with allowlist and quotas',
    () async {
      if (!await workerUp()) {
        markTestSkipped('wrangler dev is not running');
        return;
      }
      final client = HttpClient();
      try {
        final bad = await client.postUrl(
          Uri.parse(baseUrl).resolve('/v1/hajj/sources'),
        );
        bad.headers.contentType = ContentType.json;
        bad.write('{"url":"https://evil.example","season":"1448"}');
        final badResponse = await bad.close().timeout(
          const Duration(seconds: 5),
        );
        expect(badResponse.statusCode, 400);
        await badResponse.drain<void>();
      } finally {
        client.close(force: true);
      }

      final ok = await hajjLiveHttpPost(
        baseUrl: baseUrl,
        request: const HajjLookupRequest(season: '1448'),
        installationKey: 'flutter-it',
      );
      expect(ok['channel'], 'live');
      expect(ok['sources'], isA<List>());
      final sources = ok['sources'] as List;
      expect(sources, isNotEmpty);
      expect(
        sources.every(
          (item) => (item as Map)['verificationStatus'] == 'unverified',
        ),
        isTrue,
      );
    },
  );
}
