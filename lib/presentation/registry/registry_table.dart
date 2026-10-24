import 'package:flutter/material.dart';

class RegistrySelectBox extends StatelessWidget {
  const RegistrySelectBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Align(
        alignment: Alignment.topCenter,
        child: Checkbox(
          value: value,
          tristate: value == null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class RegistryWashButton extends StatelessWidget {
  const RegistryWashButton({
    super.key,
    required this.label,
    required this.wash,
    required this.onPressed,
  });

  final String label;
  final Color wash;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: wash,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}

class RegistryWashButtonRow extends StatelessWidget {
  const RegistryWashButtonRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

class RegistryTableFrame extends StatelessWidget {
  const RegistryTableFrame({
    super.key,
    required this.wash,
    required this.child,
  });

  final Color wash;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: wash, width: 1.5),
      ),
      child: child,
    );
  }
}

class RegistryPageBody extends StatelessWidget {
  const RegistryPageBody({
    super.key,
    required this.top,
    this.table,
    this.empty,
    this.bottom,
  });

  final List<Widget> top;
  final Widget? table;
  final Widget? empty;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...top,
          const SizedBox(height: 12),
          Expanded(child: table ?? empty ?? const SizedBox.shrink()),
          ?bottom,
        ],
      ),
    );
  }
}

class RegistryStickyTable extends StatelessWidget {
  const RegistryStickyTable({
    super.key,
    required this.wash,
    required this.header,
    required this.itemCount,
    required this.itemBuilder,
  });

  final Color wash;
  final Widget header;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return RegistryTableFrame(
      wash: wash,
      child: Column(
        children: [
          header,
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: wash.withValues(alpha: 0.9),
              ),
              itemBuilder: itemBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
