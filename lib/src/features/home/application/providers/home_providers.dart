import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/core/pagination/paginated_state.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/design/application/providers/design_providers.dart';
import 'package:kc_admin/src/features/notification/application/providers/notification_providers.dart';
import 'package:kc_admin/src/features/stitching/application/providers/stitching_providers.dart';
import 'package:kc_admin/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─────────────────────────────────────────────
// Greeting provider
// ─────────────────────────────────────────────

/// Returns a time-based greeting (Morning/Afternoon/Evening).
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
});

// ─────────────────────────────────────────────
// Stitching counts by status
// ─────────────────────────────────────────────

/// Returns a map of [StitchingOrderStatus] → count for the active boutique.
final stitchingCountByStatusProvider = Provider<Map<StitchingOrderStatus, int>>(
  (ref) {
    final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
    final map = <StitchingOrderStatus, int>{};
    for (final status in StitchingOrderStatus.values) {
      map[status] = orders.where((o) => o.status == status).length;
    }
    return map;
  },
);

/// Number of requests in 'requested' status.
final requestedOnlyCountProvider = Provider<int>((ref) {
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  return orders.where((o) => o.status == StitchingOrderStatus.requested).length;
});

/// Number of requests in 'accepted' status.
final acceptedOnlyCountProvider = Provider<int>((ref) {
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  return orders.where((o) => o.status == StitchingOrderStatus.accepted).length;
});

/// Number of requests in 'completed' status.
final completedOnlyCountProvider = Provider<int>((ref) {
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  return orders.where((o) => o.status == StitchingOrderStatus.completed).length;
});

/// Legacy requestedCountProvider (all non-completed) for backwards compatibility.
final requestedCountProvider = Provider<int>((ref) {
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  return orders.where((o) => o.status != StitchingOrderStatus.completed).length;
});

/// Legacy completedCountProvider.
final completedCountProvider = completedOnlyCountProvider;

/// Alias for backwards compatibility.
final pendingOrderCountProvider = requestedCountProvider;

/// Number of orders in 'accepted' status.
final readyForPickupCountProvider = acceptedOnlyCountProvider;

/// Orders received today.
final newOrdersTodayCountProvider = Provider<int>((ref) {
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  final today = DateTime.now();
  return orders.where((o) {
    final created = o.createdAt;
    return created.year == today.year &&
        created.month == today.month &&
        created.day == today.day;
  }).length;
});

// ─────────────────────────────────────────────
// Stream of Live Customer Favorites from Firestore
// ─────────────────────────────────────────────

final adminRecentFavoritesProvider = StreamProvider<List<Map<String, dynamic>>>(
  (ref) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    return firestore
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList())
        .handleError((_) => <Map<String, dynamic>>[]);
  },
);

// ─────────────────────────────────────────────
// Unified Live Recent Activity Feed (100% Real Data)
// ─────────────────────────────────────────────

enum AdminActivityCategory {
  stitchingRequest,
  stitchingStatus,
  favorite,
  newDesign,
  notification,
}

class AdminActivityItem {
  const AdminActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.category,
    required this.icon,
    required this.color,
    this.associatedOrder,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final AdminActivityCategory category;
  final IconData icon;
  final Color color;
  final StitchingOrderModel? associatedOrder;
}

/// Stream/Provider of combined multi-event live activities across the boutique.
/// 100% dynamic, derived exclusively from real Firestore collections.
final allActivityFeedProvider = Provider<List<AdminActivityItem>>((ref) {
  final items = <AdminActivityItem>[];

  // 1. Live Stitching Requests & Status Events
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  for (final o in orders) {
    final designName = o.designReferences.isNotEmpty
        ? o.designReferences.first.designName
        : 'Custom Stitching Request';

    if (o.status == StitchingOrderStatus.completed) {
      items.add(
        AdminActivityItem(
          id: 'status_completed_${o.id}',
          title: 'Stitching Completed: #${o.orderNumber}',
          subtitle: '$designName • Marked completed & customer notified',
          timestamp: o.updatedAt,
          category: AdminActivityCategory.stitchingStatus,
          icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          color: const Color(0xFF2E7D32),
          associatedOrder: o,
        ),
      );
    } else if (o.status == StitchingOrderStatus.accepted) {
      items.add(
        AdminActivityItem(
          id: 'status_accepted_${o.id}',
          title: 'Request Accepted: #${o.orderNumber}',
          subtitle: '$designName • Accepted by admin',
          timestamp: o.updatedAt,
          category: AdminActivityCategory.stitchingStatus,
          icon: PhosphorIcons.handshake(PhosphorIconsStyle.fill),
          color: const Color(0xFF0284C7),
          associatedOrder: o,
        ),
      );
    } else {
      items.add(
        AdminActivityItem(
          id: 'req_${o.id}',
          title: 'New Stitching Request: #${o.orderNumber}',
          subtitle: '$designName created by customer',
          timestamp: o.createdAt,
          category: AdminActivityCategory.stitchingRequest,
          icon: PhosphorIcons.clock(PhosphorIconsStyle.fill),
          color: const Color(0xFFD97706),
          associatedOrder: o,
        ),
      );
    }
  }

  // 2. Real Customer Favorites from Firestore `favorites` collection
  final rawFavs = ref.watch(adminRecentFavoritesProvider).valueOrNull ?? [];
  final designs = ref.watch(designListProvider).valueOrNull ?? [];
  final designMap = {for (final d in designs) d.id: d};

  for (final fav in rawFavs) {
    final designId = fav['designId'] as String? ?? '';
    final createdAtRaw = fav['createdAt'];
    DateTime timestamp = DateTime.now();
    if (createdAtRaw is Timestamp) {
      timestamp = createdAtRaw.toDate();
    }

    final matchedDesign = designMap[designId];
    final designName = matchedDesign?.name ?? 'Bespoke Item';

    items.add(
      AdminActivityItem(
        id: 'fav_${fav['id'] ?? designId}',
        title: 'Saved to Customer Favorites',
        subtitle: '"$designName" favorited by customer',
        timestamp: timestamp,
        category: AdminActivityCategory.favorite,
        icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
        color: const Color(0xFFE11D48),
      ),
    );
  }

  // 3. Real Catalogue Designs
  for (final d in designs) {
    items.add(
      AdminActivityItem(
        id: 'design_${d.id}',
        title: 'New Catalogue Design',
        subtitle: '"${d.name}" published to collection',
        timestamp: d.createdAt,
        category: AdminActivityCategory.newDesign,
        icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
        color: const Color(0xFFD4AF37),
      ),
    );
  }

  // 4. Real Broadcast / Custom Notifications (excluding automated status duplicate notifications)
  final notifications = ref.watch(notificationListProvider).valueOrNull ?? [];
  for (final n in notifications) {
    // Skip automated stitching status notification duplicates as they are already represented in order events
    if (n.title.startsWith('Stitching Order Status:')) {
      continue;
    }

    items.add(
      AdminActivityItem(
        id: 'notif_${n.id}',
        title: n.title,
        subtitle: n.body.isNotEmpty ? n.body : 'Broadcast notification published',
        timestamp: n.createdAt,
        category: AdminActivityCategory.notification,
        icon: PhosphorIcons.bellRinging(PhosphorIconsStyle.fill),
        color: const Color(0xFF7C3AED),
      ),
    );
  }

  // Sort newest first
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
});

/// Home dashboard limited subset (top 6 items)
final recentActivityFeedProvider = Provider<List<AdminActivityItem>>((ref) {
  final all = ref.watch(allActivityFeedProvider);
  return all.take(6).toList();
});

/// Legacy alias for backwards compatibility
final recentStitchingRequestsProvider = Provider<List<StitchingOrderModel>>((
  ref,
) {
  final orders = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  final pending = orders
      .where((o) => o.status != StitchingOrderStatus.completed)
      .toList();
  pending.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return pending.take(3).toList(growable: false);
});

// ─────────────────────────────────────────────
// Paginated Activity Notifier (10k+ Daily Events Scalability)
// ─────────────────────────────────────────────

class PaginatedActivityNotifier
    extends StateNotifier<PaginatedState<AdminActivityItem>> {
  PaginatedActivityNotifier(this._ref) : super(const PaginatedState()) {
    fetchInitial();
  }

  final Ref _ref;
  AdminActivityCategory? _currentCategory;
  String _currentQuery = '';
  static const int _pageSize = 20;

  Future<void> fetchInitial({
    AdminActivityCategory? category,
    String query = '',
  }) async {
    _currentCategory = category;
    _currentQuery = query.trim().toLowerCase();

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      items: [],
      hasMore: true,
    );

    try {
      final allItems = _ref.read(allActivityFeedProvider);
      final filtered = _filterItems(allItems);
      final pageItems = filtered.take(_pageSize).toList();

      state = state.copyWith(
        items: pageItems,
        isLoading: false,
        hasMore: filtered.length > _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final allItems = _ref.read(allActivityFeedProvider);
      final filtered = _filterItems(allItems);

      final currentLength = state.items.length;
      final nextChunk = filtered.skip(currentLength).take(_pageSize).toList();

      state = state.copyWith(
        items: [...state.items, ...nextChunk],
        isLoadingMore: false,
        hasMore: currentLength + nextChunk.length < filtered.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  List<AdminActivityItem> _filterItems(List<AdminActivityItem> items) {
    return items.where((item) {
      if (_currentCategory != null) {
        if (_currentCategory == AdminActivityCategory.stitchingRequest) {
          if (item.category != AdminActivityCategory.stitchingRequest &&
              item.category != AdminActivityCategory.stitchingStatus) {
            return false;
          }
        } else if (item.category != _currentCategory) {
          return false;
        }
      }

      if (_currentQuery.isNotEmpty) {
        final titleMatch = item.title.toLowerCase().contains(_currentQuery);
        final subMatch = item.subtitle.toLowerCase().contains(_currentQuery);
        return titleMatch || subMatch;
      }

      return true;
    }).toList();
  }
}

final paginatedActivityNotifierProvider = StateNotifierProvider<
    PaginatedActivityNotifier,
    PaginatedState<AdminActivityItem>>((ref) {
  return PaginatedActivityNotifier(ref);
});
