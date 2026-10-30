import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/app_language.dart';
import 'package:muhasabah02/domain/bangla_copy.dart';
import 'package:muhasabah02/domain/copy.dart';

void main() {
  test('Bangla draft covers the review lines and leaves English unchanged', () {
    expect(localizedUi(AppLanguage.english, Copy.appName), Copy.appName);
    expect(localizedUi(AppLanguage.bangla, Copy.appName), 'প্রাইভেট মুহাসাবা');
    expect(
      localizedUi(AppLanguage.bangla, 'Not translated yet'),
      'Not translated yet',
    );
    expect(kBanglaByEnglish[Copy.faqPurpose], isNotNull);
    expect(kBanglaByEnglish[Copy.languageReviewNote], isNotNull);
    for (final entry in kBanglaByEnglish.entries) {
      expect(entry.key.trim(), isNotEmpty);
      expect(entry.value.trim(), isNotEmpty);
      expect(entry.value, isNot(entry.key));
    }
  });
}
