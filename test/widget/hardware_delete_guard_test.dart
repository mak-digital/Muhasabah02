import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/presentation/shared/hardware_delete_guard.dart';

void main() {
  test('forward Delete is consumed so it cannot leave the app', () {
    final down = KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.delete,
      logicalKey: LogicalKeyboardKey.delete,
      timeStamp: Duration.zero,
    );
    expect(handleForwardDeleteKeyEvent(down), KeyEventResult.handled);
    expect(isForwardDeleteKey(LogicalKeyboardKey.backspace), isFalse);
  });

  testWidgets('forward Delete removes the next character in a search field', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'intention');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return HardwareDeleteGuard(child: child ?? const SizedBox.shrink());
        },
        home: Scaffold(
          body: TextField(
            key: const Key('search'),
            controller: controller,
            autofocus: true,
          ),
        ),
      ),
    );
    await tester.pump();
    controller.selection = const TextSelection.collapsed(offset: 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();
    expect(controller.text, 'ntention');
  });
}
