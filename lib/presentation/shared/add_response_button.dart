import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/personal_response.dart';
import '../response/response_editor_screen.dart';

class AddResponseButton extends StatelessWidget {
  const AddResponseButton({
    super.key,
    required this.provenance,
    this.compact = false,
  });

  final ResponseProvenance provenance;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: Copy.addAResponse,
      child: compact
          ? TextButton.icon(
              onPressed: () => _open(context),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text(Copy.addAResponse),
            )
          : OutlinedButton.icon(
              onPressed: () => _open(context),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text(Copy.addAResponse),
            ),
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
