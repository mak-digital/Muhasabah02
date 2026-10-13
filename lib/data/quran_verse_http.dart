import 'dart:convert';
import 'dart:io';

import '../domain/quran_verse_fetch.dart';

Future<String> quranVerseHttpGet(Uri uri) async {
  final client = HttpClient();
  try {
    client.userAgent = 'PrivateMuhasabah/1.0';
    client.connectionTimeout = const Duration(seconds: 12);
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const QuranVerseFetchException();
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close(force: true);
  }
}
