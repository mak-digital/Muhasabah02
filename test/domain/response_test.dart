import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/personal_response.dart';

void main() {
  test('empty and whitespace responses are rejected', () {
    expect(validateResponseText('   \n'), ResponseTextError.empty);
    expect(validateResponseText(''), ResponseTextError.empty);
  });

  test('CRLF is normalized to LF without unicode massaging', () {
    expect(normalizeResponseText('a\r\nb\rc'), 'a\nb\nc');
  });

  test('arabic and bangla text is accepted', () {
    const text = 'الحمد لله\nধন্যবাদ';
    expect(validateResponseText(text), isNull);
  });

  test('overlong text is rejected by scalar count', () {
    final huge = String.fromCharCodes(List.filled(10001, 0x61));
    expect(validateResponseText(huge), ResponseTextError.tooLong);
  });

  test('provenance json does not persist journal-like keys', () {
    const provenance = ResponseProvenance(
      originType: ProvenanceOrigin.recordedContext,
      domain: 'quran',
      subject: 'meaning',
      dateKey: '2026-09-01',
      factorId: 'routine',
      evidenceId: 'abc',
      labelSnapshot: 'Meaning on 2026-09-01',
    );
    final json = provenance.toJson();
    expect(json.keys, isNot(contains('freeText')));
    expect(json.keys, isNot(contains('route')));
    expect(json.keys, isNot(contains('journal')));
    expect(json.values.join(), isNot(contains('caused')));
  });

  test('note codes restart each local day from 01', () {
    final first = PersonalResponse(
      id: 'a',
      text: 'one',
      createdAt: DateTime(2026, 10, 21, 8),
    );
    final second = PersonalResponse(
      id: 'b',
      text: 'two',
      createdAt: DateTime(2026, 10, 21, 9),
    );
    final nextDay = PersonalResponse(
      id: 'c',
      text: 'three',
      createdAt: DateTime(2026, 10, 22, 7),
    );
    final assigned = assignMissingNoteCodes([first, second, nextDay]);
    expect(assigned.map((item) => item.noteCode), [
      '261021-01',
      '261021-02',
      '261022-01',
    ]);
    expect(noteDomainLabel(first), kNoteGeneralDomain);
  });

  test('note domain label uses the related short name', () {
    final item = PersonalResponse(
      id: 'q',
      text: 'keep',
      createdAt: DateTime(2026, 10, 21),
      provenance: const ResponseProvenance(
        originType: ProvenanceOrigin.quranPonder,
        domain: 'quran',
        labelSnapshot: 'Qur’an PONDER (90 days)',
      ),
    );
    expect(noteDomainLabel(item), 'Qur’an');
    expect(noteSourceLabel(item), 'Qur’an PONDER (90 days)');
  });

  test('unknown provenance origin still keeps the response', () {
    final record = PersonalResponse.fromJson({
      'schemaVersion': 1,
      'id': 'abc123',
      'text': 'keep this',
      'createdAt': '2026-09-01T00:00:00.000',
      'provenance': {
        'originType': 'futureOrigin',
        'labelSnapshot': 'Recorded evidence',
      },
    });
    expect(record.text, 'keep this');
    expect(record.provenance, isNotNull);
  });
}
