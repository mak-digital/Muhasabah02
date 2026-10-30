import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/quran_recitation.dart';

void main() {
  test('ayah counts cover the Book', () {
    expect(kQuranAyahCounts, hasLength(114));
    expect(kQuranAyahCounts.reduce((a, b) => a + b), 6236);
  });

  test('quran.com citation maps to 128 kbps recitation files', () {
    final uris = quranRecitationUris(Uri.parse('https://quran.com/2/255'));
    expect(uris, [
      Uri.parse('https://everyayah.com/data/Alafasy_128kbps/002255.mp3'),
    ]);
    final range = quranRecitationUris(Uri.parse('https://quran.com/2/284-286'));
    expect(range, hasLength(3));
    expect(range.first.path, endsWith('002284.mp3'));
    expect(range.last.path, endsWith('002286.mp3'));
    expect(
      quranRecitationUris(Uri.parse('https://sunnah.com/bukhari:614')),
      isEmpty,
    );
  });
}
