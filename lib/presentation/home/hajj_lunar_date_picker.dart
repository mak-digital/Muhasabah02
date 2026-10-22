import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/hajj_pathway.dart';
import '../../domain/hajj_planning_windows.dart';
import '../../domain/weekly_calendar.dart';

enum HajjLunarPickerKind { ritesStart, ritesEnd, regOpen, regClose, package }

Future<String?> showHajjLunarDatePicker({
  required BuildContext context,
  required HajjLunarPickerKind kind,
  required int hijriYear,
  HajjPathwayFamily? pathway,
  String? currentKey,
  int firstDayOfWeekIndex = 0,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return HajjLunarDatePickerSheet(
        kind: kind,
        hijriYear: hijriYear,
        pathway: pathway,
        currentKey: currentKey,
        firstDayOfWeekIndex: firstDayOfWeekIndex,
      );
    },
  );
}

class HajjLunarDatePickerSheet extends StatefulWidget {
  const HajjLunarDatePickerSheet({
    super.key,
    required this.kind,
    required this.hijriYear,
    this.pathway,
    this.currentKey,
    this.firstDayOfWeekIndex = 0,
  });

  final HajjLunarPickerKind kind;
  final int hijriYear;
  final HajjPathwayFamily? pathway;
  final String? currentKey;
  final int firstDayOfWeekIndex;

  @override
  State<HajjLunarDatePickerSheet> createState() =>
      _HajjLunarDatePickerSheetState();
}

class _HajjLunarDatePickerSheetState extends State<HajjLunarDatePickerSheet> {
  late int _year;
  late int _month;

  HajjLunarSpan? get _shade {
    if (widget.kind == HajjLunarPickerKind.ritesStart ||
        widget.kind == HajjLunarPickerKind.ritesEnd) {
      return hajjRitesPlanningWindow(widget.hijriYear);
    }
    if (widget.pathway == null) return null;
    return hajjRegistrationEstimate(
      family: widget.pathway!,
      hijriYear: widget.hijriYear,
    ).typicalWindow;
  }

  HajjLunarDay? get _suggested {
    if (widget.kind == HajjLunarPickerKind.ritesStart) {
      return hajjRitesPlanningWindow(widget.hijriYear).start;
    }
    if (widget.kind == HajjLunarPickerKind.ritesEnd) {
      return hajjRitesPlanningWindow(widget.hijriYear).end;
    }
    if (widget.pathway == null) return null;
    final estimate = hajjRegistrationEstimate(
      family: widget.pathway!,
      hijriYear: widget.hijriYear,
    );
    return switch (widget.kind) {
      HajjLunarPickerKind.regOpen => estimate.suggestedOpen,
      HajjLunarPickerKind.regClose => estimate.suggestedClose,
      HajjLunarPickerKind.package => estimate.suggestedPackageDeadline,
      HajjLunarPickerKind.ritesStart || HajjLunarPickerKind.ritesEnd => null,
    };
  }

  @override
  void initState() {
    super.initState();
    final stored = _dayFromStoredKey(widget.currentKey);
    final rites =
        widget.kind == HajjLunarPickerKind.ritesStart ||
        widget.kind == HajjLunarPickerKind.ritesEnd;
    final focus =
        (rites ? _suggested : stored ?? _suggested) ??
        hajjRitesPlanningWindow(widget.hijriYear).start;
    _year = focus.hijri.year;
    _month = focus.hijri.month;
  }

  HajjLunarDay? _dayFromStoredKey(String? key) {
    final raw = key?.trim() ?? '';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return null;
    try {
      final gregorian = parseDateKey(raw);
      return HajjLunarDay(gregorian: gregorian, hijri: hijriParts(gregorian));
    } catch (_) {
      return null;
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      var month = _month + delta;
      var year = _year;
      if (month < 1) {
        month = 12;
        year -= 1;
      } else if (month > 12) {
        month = 1;
        year += 1;
      }
      _month = month;
      _year = year;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shade = _shade;
    final suggested = _suggested;
    final first = gregorianFromHijri(_year, _month, 1);
    final length = hijriMonthLength(_year, _month);
    final gridStart = startOfWeek(
      first,
      firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
    );
    final cells = <DateTime>[
      for (var i = 0; i < 42; i++)
        DateTime(gridStart.year, gridStart.month, gridStart.day + i),
    ];
    final weekdayLabels = [
      for (var i = 0; i < 7; i++)
        ['S', 'M', 'T', 'W', 'T', 'F', 'S'][(widget.firstDayOfWeekIndex + i) %
            7],
    ];
    final last = gregorianFromHijri(_year, _month, length);
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: media.padding.bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_title, style: theme.textTheme.titleMedium),
              Text(kHajjPlanningEstimateNote, style: theme.textTheme.bodySmall),
              if (widget.kind != HajjLunarPickerKind.ritesStart &&
                  widget.kind != HajjLunarPickerKind.ritesEnd &&
                  widget.pathway == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Choose a planning pathway on the plan sheet to shade a typical window.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    key: const Key('hajj-lunar-prev'),
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${hijriMonthName(_month)} $_year',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    key: const Key('hajj-lunar-next'),
                    onPressed: () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Text(
                '${formatDayMonthYear(first, DisplayCalendar.gregorian)} – ${formatDayMonthYear(last, DisplayCalendar.gregorian)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final label in weekdayLabels)
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
              for (var row = 0; row < 6; row++)
                Row(
                  children: [
                    for (var col = 0; col < 7; col++)
                      Expanded(child: _cell(cells[row * 7 + col], shade)),
                  ],
                ),
              if (suggested != null)
                TextButton(
                  key: const Key('hajj-lunar-use-typical'),
                  onPressed: () =>
                      Navigator.pop(context, suggested.dateKeyValue),
                  child: Text(_typicalLabel(suggested)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title {
    return switch (widget.kind) {
      HajjLunarPickerKind.ritesStart => 'Expected Hajj period start',
      HajjLunarPickerKind.ritesEnd => 'Expected Hajj period end',
      HajjLunarPickerKind.regOpen => 'Registration opening (planning)',
      HajjLunarPickerKind.regClose => 'Registration closing (planning)',
      HajjLunarPickerKind.package => 'Package booking (planning)',
    };
  }

  String _typicalLabel(HajjLunarDay day) {
    if (widget.kind == HajjLunarPickerKind.ritesStart) {
      return 'Use 8 Dhul-Hijjah (${formatGregorianAndHijri(day.gregorian)})';
    }
    if (widget.kind == HajjLunarPickerKind.ritesEnd) {
      return 'Use 13 Dhul-Hijjah (${formatGregorianAndHijri(day.gregorian)})';
    }
    return 'Use typical estimate (${formatGregorianAndHijri(day.gregorian)})';
  }

  Widget _cell(DateTime day, HajjLunarSpan? shade) {
    final hijri = hijriParts(day);
    final inMonth = hijri.year == _year && hijri.month == _month;
    final key = dateKey(day);
    final shaded = shade?.contains(day) ?? false;
    final selected = widget.currentKey == key;
    final wash = Theme.of(context).brightness == Brightness.dark
        ? MuhasabahColors.hajjWashDark
        : MuhasabahColors.hajjWash;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: !inMonth
            ? Colors.transparent
            : selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
            : shaded
            ? wash
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: shaded && inMonth
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: 0.35),
                )
              : BorderSide.none,
        ),
        child: InkWell(
          key: inMonth ? Key('hajj-lunar-day-$key') : null,
          onTap: inMonth ? () => Navigator.pop(context, key) : null,
          child: SizedBox(
            height: 52,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hijri.day}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      height: 1.0,
                      color: inMonth ? null : Theme.of(context).disabledColor,
                    ),
                  ),
                  Text(
                    '${day.day} ${_shortGregorianMonth(day.month)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      height: 1.0,
                      fontSize: 10,
                      color: inMonth
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shortGregorianMonth(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
