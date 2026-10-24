import 'monitor_domain.dart';
import 'personal_mix.dart';
import 'personal_response.dart';

class RegistryScope {
  const RegistryScope({
    required this.visible,
    required this.mix,
    required this.domains,
  });

  factory RegistryScope.fromPrefs({
    required Set<MonitorDomain> visible,
    required PersonalMix mix,
  }) {
    return RegistryScope(
      visible: visible,
      mix: mix,
      domains: homeMixDomains(visible, mix).toSet(),
    );
  }

  final Set<MonitorDomain> visible;
  final PersonalMix mix;
  final Set<MonitorDomain> domains;

  bool includes(MonitorDomain domain) => domains.contains(domain);

  bool includesNote(PersonalResponse item) {
    final domain = noteMonitorDomain(item);
    if (domain == null) return true;
    return includes(domain);
  }

  String get domainList {
    final labels = [
      for (final domain in MonitorDomain.values)
        if (domains.contains(domain)) domain.shortLabel,
    ];
    if (labels.isEmpty) return 'none';
    return labels.join(', ');
  }
}
