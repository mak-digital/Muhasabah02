import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/arabic_script.dart';

void main() {
  test('script size steps stay on the allowed list', () {
    expect(stepArabicScriptSize(26, 1), 32);
    expect(stepArabicScriptSize(26, -1), 22);
    expect(stepArabicScriptSize(18, -1), 18);
    expect(stepArabicScriptSize(40, 1), 40);
    expect(ArabicScriptFaceX.fromId('amiri'), ArabicScriptFace.amiri);
    expect(ArabicScriptFaceX.fromId('uthmani'), ArabicScriptFace.uthmani);
    expect(ArabicScriptFace.uthmani.family, 'AmiriQuran');
    expect(ArabicScriptFace.uthmani.label, 'Uthmani');
    expect(ArabicScriptFace.naskh.family, 'NotoNaskhArabic');
    expect(ArabicScriptFace.system.family, isNull);
  });
}
