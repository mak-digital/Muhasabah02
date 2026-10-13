import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../application/reflection_source_launch.dart';
import '../../domain/copy.dart';
import '../../domain/quran_recitation.dart';
import '../../domain/hadith_ref.dart';
import '../../domain/quran_verse_ref.dart';
import '../../domain/reflection_source.dart';
import 'bring_hadith_sheet.dart';
import 'bring_quran_verse_sheet.dart';

typedef CitationPageBuilder =
    Widget Function({
      required List<ReflectionSourcePage> pages,
      required String title,
    });

typedef CitationShare = Future<void> Function(String title, Uri uri);

/// In-app citation page. Tests override this so they never construct a WebView.
final citationPageBuilderProvider = Provider<CitationPageBuilder>((ref) {
  return ({required pages, required title}) =>
      CitationReaderScreen(pages: pages, title: title);
});

final citationShareProvider = Provider<CitationShare>((ref) {
  return (title, uri) => SharePlus.instance.share(
    ShareParams(text: '$title\n$uri', subject: title),
  );
});

/// Public citation pages with our Close and Share chrome.
///
/// Several sources (Qur’an and/or hadith) each load as their own page.
/// Qur’an recitation plays from a public audio file in this app so the sound
/// stays clear. The WebView is for reading. Records are not sent.
class CitationReaderScreen extends ConsumerStatefulWidget {
  const CitationReaderScreen({
    super.key,
    required this.pages,
    required this.title,
  });

  final List<ReflectionSourcePage> pages;
  final String title;

  @override
  ConsumerState<CitationReaderScreen> createState() =>
      _CitationReaderScreenState();
}

const _kCitationChromeUa =
    'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

const _kStopCitationMediaJs = '''
(function() {
  document.querySelectorAll('audio, video').forEach(function(el) {
    try { el.pause(); el.currentTime = 0; el.removeAttribute('src'); el.load(); } catch (e) {}
  });
  try { if (window.speechSynthesis) window.speechSynthesis.cancel(); } catch (e) {}
  try { if (navigator.mediaSession) navigator.mediaSession.playbackState = 'paused'; } catch (e) {}
})();
''';

const _kImproveCitationAudioJs = '''
(function() {
  function bump(el) {
    try {
      el.preload = 'auto';
      el.defaultPlaybackRate = 1;
      el.playbackRate = 1;
      if (typeof el.src === 'string' && el.src.indexOf('64kbps') !== -1) {
        el.src = el.src.replace('64kbps', '128kbps');
        el.load();
      }
    } catch (e) {}
  }
  document.querySelectorAll('audio, video').forEach(bump);
  if (!window.__muhasabahAudioObs) {
    window.__muhasabahAudioObs = new MutationObserver(function() {
      document.querySelectorAll('audio, video').forEach(bump);
    });
    window.__muhasabahAudioObs.observe(document.documentElement, {
      subtree: true,
      childList: true
    });
  }
})();
''';

class _CitationReaderScreenState extends ConsumerState<CitationReaderScreen> {
  late final WebViewController _controller;
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerSub;
  var _loading = true;
  var _loadingAudio = false;
  var _playing = false;
  var _closed = false;
  var _popping = false;
  var _index = 0;

  ReflectionSourcePage get _current => widget.pages[_index];

  bool get _hasPager => widget.pages.length > 1;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
  }

  @override
  void dispose() {
    unawaited(_playerSub?.cancel());
    unawaited(_player?.dispose());
    unawaited(_stopPlayback());
    super.dispose();
  }

  List<Uri> get _recitationUris => quranRecitationUris(_current.uri);

  Future<void> _stopPlayback() async {
    if (_closed) return;
    _closed = true;
    await _stopNativeRecitation();
    try {
      await _controller
          .runJavaScript(_kStopCitationMediaJs)
          .timeout(const Duration(milliseconds: 400));
    } catch (_) {}
    try {
      await _controller
          .loadRequest(Uri.parse('about:blank'))
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {}
  }

  Future<void> _stopNativeRecitation() async {
    try {
      await _player?.stop();
    } catch (_) {}
    if (mounted && _playing) setState(() => _playing = false);
  }

  Future<void> _improvePageAudio() async {
    try {
      await _controller
          .runJavaScript(_kImproveCitationAudioJs)
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {}
  }

  Future<void> _pausePageMedia() async {
    try {
      await _controller
          .runJavaScript(_kStopCitationMediaJs)
          .timeout(const Duration(milliseconds: 400));
    } catch (_) {}
  }

  Future<void> _close() async {
    if (_popping) return;
    _popping = true;
    await _stopPlayback();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _goTo(int index) async {
    if (index < 0 || index >= widget.pages.length || index == _index) return;
    await _stopNativeRecitation();
    await _pausePageMedia();
    if (!mounted || _closed) return;
    setState(() {
      _index = index;
      _loading = true;
    });
    try {
      await _controller.loadRequest(widget.pages[index].uri);
    } catch (_) {
      if (mounted && !_closed) setState(() => _loading = false);
    }
  }

  WebViewController _buildController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        request.grant();
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted && !_closed) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted && !_closed) setState(() => _loading = false);
            unawaited(_improvePageAudio());
          },
          onWebResourceError: (_) {
            if (mounted && !_closed) setState(() => _loading = false);
          },
        ),
      )
      ..setUserAgent(_kCitationChromeUa)
      ..loadRequest(widget.pages.first.uri);

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      unawaited(platform.setMediaPlaybackRequiresUserGesture(false));
      unawaited(
        platform.setMixedContentMode(MixedContentMode.compatibilityMode),
      );
    }
    return controller;
  }

  void _ensurePlayer() {
    if (_player != null) return;
    final player = AudioPlayer();
    _player = player;
    _playerSub = player.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing =
          state.playing && state.processingState != ProcessingState.completed;
      if (_playing != playing) setState(() => _playing = playing);
    });
  }

  Future<void> _toggleRecitation() async {
    final uris = _recitationUris;
    if (uris.isEmpty) return;
    _ensurePlayer();
    final player = _player!;
    if (_playing) {
      await player.pause();
      return;
    }
    setState(() => _loadingAudio = true);
    await _pausePageMedia();
    try {
      await player.setAudioSource(
        ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: [for (final uri in uris) AudioSource.uri(uri)],
        ),
      );
      await player.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _loadingAudio = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Copy.recitationCouldNotStart)),
      );
      return;
    }
    if (mounted) setState(() => _loadingAudio = false);
  }

  Future<void> _openInBrowser() async {
    final opened = await launchReflectionUri(
      _current.uri,
      ref.read(reflectionUrlLaunchProvider),
    );
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Copy.reflectionSourceCouldNotOpen)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _hasPager ? _current.label : widget.title;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _close();
      },
      child: Scaffold(
        key: const Key('citation-reader'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('citation-close'),
            tooltip: Copy.citationClose,
            icon: const Icon(Icons.close),
            onPressed: _close,
          ),
          title: Text(pageTitle),
          actions: [
            IconButton(
              key: const Key('citation-share'),
              tooltip: Copy.shareCitation,
              icon: const Icon(Icons.share_outlined),
              onPressed: () =>
                  ref.read(citationShareProvider)(_current.label, _current.uri),
            ),
            PopupMenuButton<String>(
              key: const Key('citation-more'),
              onSelected: (value) {
                if (value == 'browser') unawaited(_openInBrowser());
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'browser',
                  child: Text(Copy.openCitationInBrowser),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(child: WebViewWidget(controller: _controller)),
            if (_recitationUris.isNotEmpty) _recitationBar(),
            if (parseQuranComUri(_current.uri)?.range != null) _bringQuranBar(),
            if (parseSunnahComUri(_current.uri)?.ref != null) _bringHadithBar(),
            if (_hasPager) _pager(),
          ],
        ),
      ),
    );
  }

  Widget _recitationBar() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Row(
          children: [
            IconButton(
              key: const Key('citation-play-recitation'),
              tooltip: _playing ? Copy.pauseRecitation : Copy.playRecitation,
              onPressed: _loadingAudio ? null : () => unawaited(_toggleRecitation()),
              icon: _loadingAudio
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    ),
            ),
            Expanded(
              child: Text(
                Copy.recitationBarNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bringQuranBar() {
    final range = parseQuranComUri(_current.uri)?.range;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const Key('citation-bring-quran'),
          onPressed: range == null
              ? null
              : () => showBringQuranVerseSheet(
                    context,
                    initial: range.verseKey,
                  ),
          child: const Text(Copy.bringThisVerseIntoLearn),
        ),
      ),
    );
  }

  Widget _bringHadithBar() {
    final hadith = parseSunnahComUri(_current.uri)?.ref;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const Key('citation-bring-hadith'),
          onPressed: hadith == null
              ? null
              : () => showBringHadithSheet(
                    context,
                    initial: hadith.hadithKey,
                  ),
          child: const Text(Copy.bringThisHadithIntoLearn),
        ),
      ),
    );
  }

  Widget _pager() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Row(
          children: [
            IconButton(
              key: const Key('citation-prev-page'),
              tooltip: Copy.previousCitationPage,
              onPressed: _index == 0 ? null : () => unawaited(_goTo(_index - 1)),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                Copy.citationPageIndex(_index + 1, widget.pages.length),
                key: const Key('citation-page-index'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              key: const Key('citation-next-page'),
              tooltip: Copy.nextCitationPage,
              onPressed: _index >= widget.pages.length - 1
                  ? null
                  : () => unawaited(_goTo(_index + 1)),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
