const kQuranAyahCounts = <int>[
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
  111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
  54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
  49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
  28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30,
  20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4,
  5, 6,
];

class QuranPassage {
  const QuranPassage({
    required this.surah,
    required this.start,
    required this.end,
  });

  final int surah;
  final int start;
  final int end;

  int get length => end - start + 1;
}

bool isQuranCitationHost(Uri uri) {
  final host = uri.host.toLowerCase();
  return host == 'quran.com' || host == 'www.quran.com';
}

QuranPassage? quranPassageFromUri(Uri uri) {
  if (!isQuranCitationHost(uri)) return null;
  final segs = [
    for (final segment in uri.pathSegments)
      if (segment.isNotEmpty) segment,
  ];
  var i = 0;
  if (segs.isNotEmpty &&
      RegExp(r'^[a-z]{2}(?:-[a-z]{2})?$', caseSensitive: false)
          .hasMatch(segs.first)) {
    i = 1;
  }
  if (i >= segs.length) return null;
  final surah = int.tryParse(segs[i]);
  if (surah == null || surah < 1 || surah > kQuranAyahCounts.length) {
    return null;
  }
  final maxAyah = kQuranAyahCounts[surah - 1];
  var start = 1;
  var end = 1;
  if (i + 1 < segs.length) {
    final match = RegExp(r'^(\d+)(?:-(\d+))?$').firstMatch(segs[i + 1]);
    if (match == null) return null;
    start = int.parse(match.group(1)!);
    end = int.parse(match.group(2) ?? match.group(1)!);
  } else {
    final verse = uri.queryParameters['startingVerse'];
    start = int.tryParse(verse ?? '') ?? 1;
    end = start;
  }
  if (start < 1 || end < start || end > maxAyah) return null;
  return QuranPassage(surah: surah, start: start, end: end);
}

String _pad3(int value) => value.toString().padLeft(3, '0');

Uri quranAyahAudioUri(int surah, int ayah) {
  return Uri.https(
    'everyayah.com',
    '/data/Alafasy_128kbps/${_pad3(surah)}${_pad3(ayah)}.mp3',
  );
}

List<Uri> quranRecitationUris(Uri citation) {
  final passage = quranPassageFromUri(citation);
  if (passage == null) return const [];
  return [
    for (var ayah = passage.start; ayah <= passage.end; ayah++)
      quranAyahAudioUri(passage.surah, ayah),
  ];
}
