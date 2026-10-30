import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('Qur’an citations open a verse page', () {
    expect(
      reflectionSourceUris('Qur’an 2:183').single.toString(),
      'https://quran.com/2/183',
    );
    expect(
      reflectionSourceUris('Qur’an 23:1–2').single.toString(),
      'https://quran.com/23/1-2',
    );
  });

  test('hadith citations prefer the first named collection', () {
    expect(
      reflectionSourceUris('Ṣaḥīḥ al-Bukhārī 527; Ṣaḥīḥ Muslim 85')
          .map((uri) => uri.toString())
          .toList(),
      ['https://sunnah.com/bukhari:527', 'https://sunnah.com/muslim:85'],
    );
    expect(
      reflectionSourceUris('Jāmiʿ al-Tirmidhī 2910').single.toString(),
      'https://sunnah.com/tirmidhi:2910',
    );
    expect(
      reflectionSourceUris('al-Adab al-Mufrad 112').single.toString(),
      'https://sunnah.com/adab:112',
    );
  });

  test('mixed Qur’an and hadith citations keep both pages', () {
    expect(
      reflectionSourceUris('Qur’an 2:255; Sunan an-Nasāʾī 7280')
          .map((uri) => uri.toString())
          .toList(),
      ['https://quran.com/2/255', 'https://sunnah.com/nasai:7280'],
    );
    expect(
      reflectionSourceUris('Ṣaḥīḥ al-Bukhārī 2311; Qur’an 2:255')
          .map((uri) => uri.toString())
          .toList(),
      ['https://sunnah.com/bukhari:2311', 'https://quran.com/2/255'],
    );
  });

  test('unknown collections are skipped', () {
    expect(reflectionSourceUris('Mustadrak al-Ḥākim 7846'), isEmpty);
  });

  test('each source part keeps its own page label', () {
    final pages = reflectionSourcePages('Qur’an 2:255; Sunan an-Nasāʾī 7280');
    expect(pages, hasLength(2));
    expect(pages.first.label, 'Qur’an 2:255');
    expect(pages.last.label, 'Sunan an-Nasāʾī 7280');
    expect(pages.first.uri.toString(), 'https://quran.com/2/255');
    expect(pages.last.uri.toString(), 'https://sunnah.com/nasai:7280');
  });
}
