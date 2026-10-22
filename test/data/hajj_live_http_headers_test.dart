import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/hajj_live_http.dart';
import 'package:muhasabah02/domain/hajj_online_assist.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test(
    'authorised synthetic POST sends gate and Access headers only',
    () async {
      final pending = server.first;
      final future = hajjLiveHttpPost(
        baseUrl: 'http://127.0.0.1:${server.port}',
        request: const HajjLookupRequest(season: '1448'),
        installationKey: 'synthetic-install',
        pilotGate: 'synthetic-gate',
        accessClientId: 'synthetic-access-id',
        accessClientSecret: 'synthetic-access-secret',
      );
      final incoming = await pending;
      expect(incoming.headers.value('X-Muhasabah-Pilot'), 'synthetic-gate');
      expect(
        incoming.headers.value('X-Muhasabah-Install'),
        'synthetic-install',
      );
      expect(
        incoming.headers.value('CF-Access-Client-Id'),
        'synthetic-access-id',
      );
      expect(
        incoming.headers.value('CF-Access-Client-Secret'),
        'synthetic-access-secret',
      );
      final body = await utf8.decoder.bind(incoming).join();
      expect(jsonDecode(body), {'season': '1448', 'pathwayIds': <dynamic>[]});
      incoming.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'channel': 'live',
            'sources': [
              {
                'verificationStatus': 'unverified',
                'uri': 'https://www.nusuk.sa/',
              },
            ],
          }),
        );
      await incoming.response.close();
      final json = await future;
      expect(json['channel'], 'live');
    },
  );

  test('unauthorised Worker 403 does not change local plans', () async {
    server.listen((request) async {
      request.response
        ..statusCode = 403
        ..write('{"error":"Live lookup is not enabled for this client."}');
      await request.response.close();
    });
    expect(
      () => hajjLiveHttpPost(
        baseUrl: 'http://127.0.0.1:${server.port}',
        request: const HajjLookupRequest(season: '1448'),
      ),
      throwsA(
        isA<HajjOnlineAssistException>().having(
          (error) => error.message,
          'message',
          contains('not enabled'),
        ),
      ),
    );
  });

  test('production HTTPS is required off localhost', () async {
    expect(
      () => hajjLiveHttpPost(
        baseUrl: 'http://example.workers.dev',
        request: const HajjLookupRequest(season: '1448'),
      ),
      throwsA(isA<HajjOnlineAssistException>()),
    );
  });
}
