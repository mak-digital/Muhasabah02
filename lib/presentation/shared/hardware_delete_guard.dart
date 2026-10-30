import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isForwardDeleteKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.delete;
}

KeyEventResult handleForwardDeleteKeyEvent(KeyEvent event) {
  if (!isForwardDeleteKey(event.logicalKey)) {
    return KeyEventResult.ignored;
  }
  if (event is KeyDownEvent || event is KeyRepeatEvent) {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused != null) {
      Actions.maybeInvoke<DeleteCharacterIntent>(
        focused,
        const DeleteCharacterIntent(forward: true),
      );
    }
  }
  return KeyEventResult.handled;
}

/// Keeps host Delete inside the app so Android/Windows does not treat it as
/// Ctrl+Alt+Del, and applies forward-delete in the focused text field.
class HardwareDeleteGuard extends StatelessWidget {
  const HardwareDeleteGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) => handleForwardDeleteKeyEvent(event),
      child: child,
    );
  }
}
