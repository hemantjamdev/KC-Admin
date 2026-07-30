import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/features/design/application/providers/design_providers.dart';
import 'package:kc_admin/src/features/design/domain/models/design_model.dart';
import 'package:kc_admin/src/features/section/application/providers/section_providers.dart';
import 'package:kc_admin/src/features/section/domain/models/section_model.dart';

// ─────────────────────────────────────────────
// Section engagement (item count as proxy)
// ─────────────────────────────────────────────

/// Maps section title → design count for engagement visualization.
/// Uses design list filtered by the section's type as a proxy for engagement.
final sectionEngagementProvider = Provider<Map<String, int>>((ref) {
  final sections = ref.watch(sectionListProvider).valueOrNull ?? [];
  final designs = ref.watch(designListProvider).valueOrNull ?? [];

  final map = <String, int>{};
  for (final section in sections) {
    // Use design count as engagement proxy for now.
    // When KC-App writes sectionItems, this can be replaced with real item counts.
    final count = designs
        .where((d) => d.isActive && d.categoryId.isNotEmpty)
        .length;
    map[section.title] = count;
  }
  return map;
});

// ─────────────────────────────────────────────
// Popular colors (aggregated from active designs)
// ─────────────────────────────────────────────

/// Returns color → frequency map from all active designs.
final popularColorsProvider = Provider<Map<String, int>>((ref) {
  final designs = ref.watch(designListProvider).valueOrNull ?? [];
  final freq = <String, int>{};
  for (final design in designs) {
    if (!design.isActive) continue;
    for (final color in design.colors) {
      freq[color] = (freq[color] ?? 0) + 1;
    }
  }
  // Sort by frequency
  final sorted = freq.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(sorted.take(10));
});

// ─────────────────────────────────────────────
// Popular sizes (aggregated from active designs)
// ─────────────────────────────────────────────

/// Returns size → frequency map from all active designs.
final popularSizesProvider = Provider<Map<String, int>>((ref) {
  final designs = ref.watch(designListProvider).valueOrNull ?? [];
  final freq = <String, int>{};
  for (final design in designs) {
    if (!design.isActive) continue;
    for (final size in design.sizes) {
      freq[size] = (freq[size] ?? 0) + 1;
    }
  }
  final sorted = freq.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(sorted);
});

// ─────────────────────────────────────────────
// Top designs (most recently updated active)
// ─────────────────────────────────────────────

/// Returns top N active designs sorted by updatedAt desc.
/// Serves as a proxy for "recently engaged" products until
/// a dedicated views/favorites collection is available.
final topDesignsProvider = Provider<List<DesignModel>>((ref) {
  final designs = ref.watch(designListProvider).valueOrNull ?? [];
  final active = designs.where((d) => d.isActive).toList();
  active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return active.take(5).toList(growable: false);
});

// ─────────────────────────────────────────────
// Most active section
// ─────────────────────────────────────────────

/// Returns the most recently updated or first active section.
final mostActiveSectionProvider = Provider<SectionModel?>((ref) {
  final sections = ref.watch(sectionListProvider).valueOrNull ?? [];
  final active = sections.where((s) => s.isCurrentlyActive).toList();
  if (active.isEmpty) return null;
  active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return active.first;
});

// ─────────────────────────────────────────────
// Insights time filter state
// ─────────────────────────────────────────────

enum InsightsTimeRange { week, month, quarter }

extension InsightsTimeRangeExt on InsightsTimeRange {
  String get label {
    return switch (this) {
      InsightsTimeRange.week => '7 Days',
      InsightsTimeRange.month => '30 Days',
      InsightsTimeRange.quarter => '90 Days',
    };
  }
}

final insightsTimeRangeProvider =
    NotifierProvider<InsightsTimeRangeNotifier, InsightsTimeRange>(
      InsightsTimeRangeNotifier.new,
    );

class InsightsTimeRangeNotifier extends Notifier<InsightsTimeRange> {
  @override
  InsightsTimeRange build() => InsightsTimeRange.month;

  void select(InsightsTimeRange range) => state = range;
}
