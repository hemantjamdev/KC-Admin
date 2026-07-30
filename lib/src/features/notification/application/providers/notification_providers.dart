import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kc_admin/src/core/errors/failure_mapper.dart';
import 'package:kc_admin/src/core/pagination/paginated_state.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/notification/data/repositories/notification_firestore_repository.dart';
import 'package:kc_admin/src/features/notification/data/services/admin_firebase_messaging_service.dart';
import 'package:kc_admin/src/features/notification/domain/models/notification_model.dart';
import 'package:kc_admin/src/features/notification/domain/models/notification_permission_state.dart';
import 'package:kc_admin/src/features/notification/domain/models/notification_messaging_state.dart';

// ─────────────────────────────────────────────
// Repository & Service providers
// ─────────────────────────────────────────────

final notificationRepositoryProvider =
    Provider<NotificationFirestoreRepository>((ref) {
      return NotificationFirestoreRepository(
        firestore: ref.watch(firebaseFirestoreProvider),
      );
    });

final adminFirebaseMessagingServiceProvider =
    Provider<AdminFirebaseMessagingService>((ref) {
      return AdminFirebaseMessagingService();
    });

// ─────────────────────────────────────────────
// Admin Notification Permission Notifier
// ─────────────────────────────────────────────

final adminNotificationPermissionProvider =
    NotifierProvider<
      AdminNotificationPermissionNotifier,
      NotificationPermissionState
    >(AdminNotificationPermissionNotifier.new);

class AdminNotificationPermissionNotifier
    extends Notifier<NotificationPermissionState> {
  @override
  NotificationPermissionState build() {
    Future.microtask(() => checkPermissionStatus());
    return const NotificationPermissionState.unknown();
  }

  Future<void> checkPermissionStatus() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        state = const NotificationPermissionState.granted();
      } else if (status.isPermanentlyDenied) {
        state = const NotificationPermissionState.permanentlyDenied();
      } else {
        state = const NotificationPermissionState.notRequested();
      }
    } catch (e, st) {
      state = NotificationPermissionState.failure(FailureMapper.map(e, st));
    }
  }

  Future<void> requestPermission({String? adminUid}) async {
    if (state is NotificationPermissionRequesting) return;
    state = const NotificationPermissionState.requesting();

    try {
      final service = ref.read(adminFirebaseMessagingServiceProvider);
      final settings = await service.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        state = const NotificationPermissionState.granted();
        if (adminUid != null && adminUid.isNotEmpty) {
          await ref
              .read(adminNotificationMessagingProvider.notifier)
              .initializeForAdmin(uid: adminUid);
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        state = const NotificationPermissionState.denied();
      } else {
        state = const NotificationPermissionState.notRequested();
      }
    } catch (e, st) {
      state = NotificationPermissionState.failure(FailureMapper.map(e, st));
    }
  }
}

// ─────────────────────────────────────────────
// Admin Messaging Coordinator Notifier
// ─────────────────────────────────────────────

final adminNotificationMessagingProvider =
    NotifierProvider<
      AdminNotificationMessagingNotifier,
      NotificationMessagingState
    >(AdminNotificationMessagingNotifier.new);

class AdminNotificationMessagingNotifier
    extends Notifier<NotificationMessagingState> {
  @override
  NotificationMessagingState build() {
    return const NotificationMessagingState.idle();
  }

  Future<void> initializeForAdmin({required String uid}) async {
    if (uid.isEmpty) return;
    state = const NotificationMessagingState.initializing();

    try {
      final service = ref.read(adminFirebaseMessagingServiceProvider);
      await service.initialize(adminId: uid, firebaseUid: uid);
      final token = service.currentToken ?? '';
      state = NotificationMessagingState.ready(
        tokenRegistered: token.isNotEmpty,
        token: token,
      );
    } catch (e, st) {
      state = NotificationMessagingState.failure(FailureMapper.map(e, st));
    }
  }
}

// ─────────────────────────────────────────────
// Admin Notification list — live stream
// ─────────────────────────────────────────────

final notificationListProvider = StreamProvider<List<NotificationModel>>((ref) {
  // Re-subscribe whenever Firebase auth state changes (e.g. login/logout)
  ref.watch(firebaseAuthStateProvider);
  return ref.watch(notificationRepositoryProvider).watchAdminNotifications();
});

/// Count of notifications that are pending or unread.
final adminUnreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationListProvider).valueOrNull ?? [];
  return list.where((n) => n.status == NotificationStatus.draft).length;
});

// ─────────────────────────────────────────────
// Paginated Notifications Notifier
// ─────────────────────────────────────────────

final paginatedNotificationsProvider =
    StateNotifierProvider<PaginatedNotificationsNotifier, PaginatedState<NotificationModel>>(
  (ref) {
    return PaginatedNotificationsNotifier(
      repository: ref.watch(notificationRepositoryProvider),
    );
  },
);

class PaginatedNotificationsNotifier extends StateNotifier<PaginatedState<NotificationModel>> {
  PaginatedNotificationsNotifier({required this.repository})
      : super(const PaginatedState()) {
    fetchInitial();
  }

  final NotificationFirestoreRepository repository;
  String _currentQuery = '';

  Future<void> fetchInitial({String query = ''}) async {
    _currentQuery = query.trim();

    state = state.copyWith(isLoading: true, errorMessage: null, items: [], lastDocId: null, hasMore: true);

    try {
      final res = await repository.fetchPaginatedNotifications(limit: 20);

      var filtered = res.items;
      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        filtered = filtered.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q)
        ).toList();
      }

      state = state.copyWith(
        items: filtered,
        isLoading: false,
        lastDocId: res.lastDocId,
        hasMore: res.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final res = await repository.fetchPaginatedNotifications(
        limit: 20,
        startAfterId: state.lastDocId,
      );

      var filtered = res.items;
      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        filtered = filtered.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q)
        ).toList();
      }

      state = state.copyWith(
        items: [...state.items, ...filtered],
        isLoadingMore: false,
        lastDocId: res.lastDocId,
        hasMore: res.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    await fetchInitial(query: _currentQuery);
  }
}

// ─────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────

enum NotificationReadFilter { all, unread, read }

class NotificationFilterState {
  const NotificationFilterState({
    this.searchQuery = '',
    this.typeFilter,
    this.statusFilter,
    this.audienceFilter,
    this.readFilter = NotificationReadFilter.all,
  });

  final String searchQuery;
  final NotificationType? typeFilter;
  final NotificationStatus? statusFilter;
  final NotificationAudienceType? audienceFilter;
  final NotificationReadFilter readFilter;

  NotificationFilterState copyWith({
    String? searchQuery,
    Object? typeFilter = _sentinel,
    Object? statusFilter = _sentinel,
    Object? audienceFilter = _sentinel,
    NotificationReadFilter? readFilter,
  }) => NotificationFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    typeFilter: typeFilter == _sentinel
        ? this.typeFilter
        : typeFilter as NotificationType?,
    statusFilter: statusFilter == _sentinel
        ? this.statusFilter
        : statusFilter as NotificationStatus?,
    audienceFilter: audienceFilter == _sentinel
        ? this.audienceFilter
        : audienceFilter as NotificationAudienceType?,
    readFilter: readFilter ?? this.readFilter,
  );
}

const _sentinel = Object();

final notificationFilterProvider =
    NotifierProvider<NotificationFilterNotifier, NotificationFilterState>(
      NotificationFilterNotifier.new,
    );

class NotificationFilterNotifier extends Notifier<NotificationFilterState> {
  @override
  NotificationFilterState build() => const NotificationFilterState();

  void search(String q) => state = state.copyWith(searchQuery: q.trim());

  void filterByType(NotificationType? t) =>
      state = state.copyWith(typeFilter: t);

  void filterByStatus(NotificationStatus? s) =>
      state = state.copyWith(statusFilter: s);

  void filterByAudience(NotificationAudienceType? a) =>
      state = state.copyWith(audienceFilter: a);

  void filterByRead(NotificationReadFilter r) =>
      state = state.copyWith(readFilter: r);

  void reset() => state = const NotificationFilterState();
}

// Alias used by UI pages
final adminNotificationFilterProvider = notificationFilterProvider;

// ─────────────────────────────────────────────
// Derived: filtered admin notification list
// ─────────────────────────────────────────────

final filteredAdminNotificationListProvider = Provider<List<NotificationModel>>(
  (ref) {
    final all = ref.watch(notificationListProvider).valueOrNull ?? [];
    final filter = ref.watch(notificationFilterProvider);

    return all.where((n) {
      if (filter.statusFilter != null && n.status != filter.statusFilter) {
        return false;
      }
      if (filter.typeFilter != null && n.type != filter.typeFilter) {
        return false;
      }
      if (filter.audienceFilter != null &&
          n.audienceType != filter.audienceFilter) {
        return false;
      }
      if (filter.searchQuery.isNotEmpty) {
        final q = filter.searchQuery.toLowerCase();
        return n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  },
);

// ─────────────────────────────────────────────
// Admin Notification Mutation Notifier
// ─────────────────────────────────────────────

final adminNotificationMutationProvider =
    NotifierProvider<AdminNotificationMutationNotifier, AsyncValue<void>>(
      AdminNotificationMutationNotifier.new,
    );

class AdminNotificationMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  NotificationFirestoreRepository get _repo =>
      ref.read(notificationRepositoryProvider);

  Future<void> create(NotificationModel notification) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.createNotification(notification),
    );
    if (!state.hasError) ref.invalidate(notificationListProvider);
  }

  Future<void> update(NotificationModel notification) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.updateNotification(notification),
    );
    if (!state.hasError) ref.invalidate(notificationListProvider);
  }

  Future<void> delete(String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.deleteNotification(notificationId),
    );
    if (!state.hasError) ref.invalidate(notificationListProvider);
  }

  Future<void> publish(String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.publishNotification(notificationId),
    );
    if (!state.hasError) ref.invalidate(notificationListProvider);
  }
}
