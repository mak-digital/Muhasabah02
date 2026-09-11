import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/personal_response.dart';
import '../response/response_editor_screen.dart';

class AddResponseButton extends StatelessWidget {
  const AddResponseButton({
    super.key,
    required this.provenance,
    this.compact = false,
    this.filled = false,
  });

  final ResponseProvenance provenance;
  final bool compact;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final label = const Text(Copy.addAResponse);
    final icon = const Icon(Icons.edit_note_outlined);
    final button = compact
        ? TextButton.icon(
            onPressed: () => _open(context),
            icon: icon,
            label: label,
          )
        : filled
        ? FilledButton.icon(
            onPressed: () => _open(context),
            icon: icon,
            label: label,
          )
        : OutlinedButton.icon(
            onPressed: () => _open(context),
            icon: icon,
            label: label,
          );
    return Semantics(
      button: true,
      label: Copy.addAResponse,
      child: filled ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResponseEditorScreen(provenance: provenance),
      ),
    );
  }
}
