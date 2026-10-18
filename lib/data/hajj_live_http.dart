import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/hajj_online_assist.dart';

const kHajjLiveGate = String.fromEnvironment('HAJJ_LIVE_GATE');

/// One attempt. No automatic retries or background polling.
Future<Map<String, Object?>> hajjLiveHttpPost({
  required String baseUrl,
  required HajjLookupRequest request,
  int maxAttempts = 1,
  String? installationKey,
  String? pilotGate,
}) async {
  if (maxAttempts != 1) {
    throw HajjOnlineAssistException('Live lookup does not retry.');
  }
  final uri = Uri.parse(baseUrl).resolve('/v1/hajj/sources');
  if (uri.scheme != 'https' && !_isLocalWorkerHost(uri.host)) {
    throw HajjOnlineAssistException('Live lookup requires HTTPS.');
  }
  final client = HttpClient();
  try {
    client.userAgent = 'PrivateMuhasabah/1.0 HajjSources';
    client.connectionTimeout = const Duration(seconds: 8);
    final httpRequest = await client.postUrl(uri);
    httpRequest.headers.contentType = ContentType.json;
    final install = (installationKey ?? '').trim();
    if (install.isNotEmpty) {
      httpRequest.headers.set('X-Muhasabah-Install', install);
    }
    final gate = (pilotGate ?? kHajjLiveGate).trim();
    if (gate.isNotEmpty) {
      httpRequest.headers.set('X-Muhasabah-Pilot', gate);
    }
    httpRequest.write(jsonEncode(request.toPayload()));
    final response = await httpRequest.close().timeout(
      const Duration(seconds: 10),
    );
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) {
      throw HajjOnlineAssistException(_safeError(response.statusCode, text));
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      throw HajjOnlineAssistException(
        'Live lookup returned an unreadable body.',
      );
    }
    return Map<String, Object?>.from(decoded);
  } on HajjOnlineAssistException {
    rethrow;
  } catch (_) {
    throw HajjOnlineAssistException('Live official lookup is unavailable.');
  } finally {
    client.close(force: true);
  }
}

bool _isLocalWorkerHost(String host) {
  return host == '127.0.0.1' ||
      host == 'localhost' ||
      host == '::1' ||
      host == '10.0.2.2';
}

String _safeError(int status, String body) {
  if (status == 429) {
    if (body.contains('personal limit')) {
      return 'Live lookup has reached today’s personal limit. Offline planning is unchanged.';
    }
    if (body.contains('shared limit') || body.contains('Free-plan')) {
      return 'Live lookup has reached today’s shared limit. Offline planning is unchanged.';
    }
    return 'Live lookup is temporarily limited. Offline planning is unchanged.';
  }
  if (status == 403) {
    return 'Live lookup is not enabled for this client. Offline planning is unchanged.';
  }
  if (status == 400 || status == 422) {
    return 'Live lookup rejected the request.';
  }
  if (status == 1027) {
    return 'The Free-plan Worker limit was reached. Offline planning is unchanged.';
  }
  return 'Live official lookup is unavailable. Offline planning is unchanged.';
}
