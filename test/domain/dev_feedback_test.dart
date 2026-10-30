import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/dev_feedback.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

void main() {
  test('serials pad and export includes every domain in order', () {
    expect(formatFeedbackSerial(15), 'FB-00015');
    final text = formatDevFeedbackExport([
      DevFeedback(
        id: 'b',
        serial: 2,
        domain: MonitorDomain.quran,
        dateKey: '2026-10-08',
        body: 'Second\tnote',
        createdAt: DateTime(2026, 10, 8),
      ),
      DevFeedback(
        id: 'a',
        serial: 1,
        domain: MonitorDomain.salah,
        dateKey: '2026-10-07',
        body: 'First',
        createdAt: DateTime(2026, 10, 7),
      ),
    ]);
    expect(
      registerDeveloperNotes([
        DevFeedback(
          id: 'b',
          serial: 2,
          domain: MonitorDomain.quran,
          dateKey: '2026-10-08',
          body: 'Second',
          createdAt: DateTime(2026, 10, 8),
        ),
        DevFeedback(
          id: 'a',
          serial: 1,
          domain: MonitorDomain.salah,
          dateKey: '2026-10-07',
          body: 'First',
          createdAt: DateTime(2026, 10, 7),
        ),
      ]).map((note) => note.serial),
      [1, 2],
    );
    expect(
      DevFeedback(
        id: 'a',
        serial: 1,
        domain: MonitorDomain.salah,
        dateKey: '2026-10-07',
        body: 'First',
        createdAt: DateTime(2026, 10, 7),
      ).copyWith(body: 'Changed').body,
      'Changed',
    );
    expect(text.split('\n'), [
      'serial\tdomain\tdate\tappVersion\tnote',
      'FB-00001\tSalah\t2026-10-07\t$kAppVersionLabel\tFirst',
      'FB-00002\tQur’an\t2026-10-08\t$kAppVersionLabel\tSecond note',
    ]);
  });
}
