import 'package:flutter/material.dart';

import '../../domain/models/notification_model.dart';
import '../../domain/models/notification_read_model.dart';

enum NotificationReadFilter { all, unread, read }

/// Controller managing notification publishing lifecycle, eligibility filtering, and customer read state.
class NotificationController extends ChangeNotifier {
  NotificationController({
    required this.boutiqueId,
    this.branchId,
    this.authenticatedCustomerId,
  }) {
    loadNotifications();
  }

  final String boutiqueId;
  final String? branchId;
  final String? authenticatedCustomerId;

  bool _isLoading = false;
  String _searchQuery = '';
  NotificationType? _selectedTypeFilter;
  NotificationStatus? _selectedStatusFilter;
  NotificationAudienceType? _selectedAudienceFilter;
  NotificationReadFilter _selectedReadFilter = NotificationReadFilter.all;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  NotificationType? get selectedTypeFilter => _selectedTypeFilter;
  NotificationStatus? get selectedStatusFilter => _selectedStatusFilter;
  NotificationAudienceType? get selectedAudienceFilter =>
      _selectedAudienceFilter;
  NotificationReadFilter get selectedReadFilter => _selectedReadFilter;

  static final List<NotificationModel> _sessionNotifications = [];
  static final List<NotificationReadModel> _sessionReadRecords = [];

  /// Evaluates scheduled notifications lifecycle (simulated on-demand publish check).
  void _evaluateScheduledLifecycle() {
    final now = DateTime.now();
    for (var i = 0; i < _sessionNotifications.length; i++) {
      final notif = _sessionNotifications[i];
      if (notif.status == NotificationStatus.scheduled &&
          notif.scheduledAt != null &&
          notif.scheduledAt!.isBefore(now)) {
        _sessionNotifications[i] = notif.copyWith(
          status: NotificationStatus.published,
          publishedAt: notif.scheduledAt,
          updatedAt: now,
        );
      }
    }
  }

  /// Evaluates if a customer is eligible to see a published notification.
  bool isNotificationEligibleForCustomer(
    NotificationModel notif,
    String customerId,
    String? currentBranchId,
  ) {
    final now = DateTime.now();

    // Must be published
    if (notif.status != NotificationStatus.published) return false;

    // Must match boutique
    if (notif.boutiqueId != boutiqueId) return false;

    // Must be publishedAt <= now
    if (notif.publishedAt == null || notif.publishedAt!.isAfter(now)) {
      return false;
    }

    // Must not be expired
    if (notif.expiresAt != null && notif.expiresAt!.isBefore(now)) {
      return false;
    }

    // Audience filtering
    switch (notif.audienceType) {
      case NotificationAudienceType.allBoutiqueCustomers:
        return true;

      case NotificationAudienceType.branchCustomers:
        if (notif.branchId == null) return true;
        return notif.branchId == currentBranchId;

      case NotificationAudienceType.selectedCustomers:
        return notif.customerIds.contains(customerId);
    }
  }

  /// Returns customer-visible eligible notifications sorted by publishedAt descending.
  List<NotificationModel> get visibleNotificationsForCustomer {
    if (authenticatedCustomerId == null) return [];
    _evaluateScheduledLifecycle();

    var list = _sessionNotifications.where((n) {
      if (!isNotificationEligibleForCustomer(
        n,
        authenticatedCustomerId!,
        branchId,
      )) {
        return false;
      }

      if (_selectedTypeFilter != null && n.type != _selectedTypeFilter) {
        return false;
      }

      final isRead = isNotificationRead(n.id);
      if (_selectedReadFilter == NotificationReadFilter.unread && isRead) {
        return false;
      }
      if (_selectedReadFilter == NotificationReadFilter.read && !isRead) {
        return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchTitle = n.title.toLowerCase().contains(q);
        final matchBody = n.body.toLowerCase().contains(q);
        return matchTitle || matchBody;
      }

      return true;
    }).toList();

    list.sort((a, b) {
      final aTime = a.publishedAt ?? a.createdAt;
      final bTime = b.publishedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    return list;
  }

  /// Returns admin-visible notifications sorted by date descending.
  List<NotificationModel> get visibleNotificationsForAdmin {
    _evaluateScheduledLifecycle();

    var list = _sessionNotifications.where((n) {
      if (n.boutiqueId != boutiqueId) return false;
      if (branchId != null && n.branchId != null && n.branchId != branchId) {
        return false;
      }
      if (_selectedTypeFilter != null && n.type != _selectedTypeFilter) {
        return false;
      }
      if (_selectedStatusFilter != null && n.status != _selectedStatusFilter) {
        return false;
      }
      if (_selectedAudienceFilter != null &&
          n.audienceType != _selectedAudienceFilter) {
        return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchTitle = n.title.toLowerCase().contains(q);
        final matchBody = n.body.toLowerCase().contains(q);
        return matchTitle || matchBody;
      }

      return true;
    }).toList();

    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Unread count for customer.
  int get unreadCount {
    if (authenticatedCustomerId == null) return 0;
    _evaluateScheduledLifecycle();

    final eligible = _sessionNotifications.where(
      (n) => isNotificationEligibleForCustomer(
        n,
        authenticatedCustomerId!,
        branchId,
      ),
    );

    return eligible.where((n) => !isNotificationRead(n.id)).length;
  }

  bool isNotificationRead(String notificationId) {
    if (authenticatedCustomerId == null) return false;
    final id = '${notificationId}_$authenticatedCustomerId';
    return _sessionReadRecords.any((r) => r.id == id && r.isRead);
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _evaluateScheduledLifecycle();
    _isLoading = false;
    notifyListeners();
  }

  void searchNotifications(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void filterByType(NotificationType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void filterByStatus(NotificationStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void filterByAudience(NotificationAudienceType? audience) {
    _selectedAudienceFilter = audience;
    notifyListeners();
  }

  void filterByReadState(NotificationReadFilter filter) {
    _selectedReadFilter = filter;
    notifyListeners();
  }

  NotificationModel? getNotificationById(String id) {
    try {
      return _sessionNotifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Customer Actions ---

  Future<void> markAsRead(String notificationId) async {
    if (authenticatedCustomerId == null) return;
    final id = '${notificationId}_$authenticatedCustomerId';

    final index = _sessionReadRecords.indexWhere((r) => r.id == id);
    final now = DateTime.now();

    if (index == -1) {
      _sessionReadRecords.add(
        NotificationReadModel(
          id: id,
          notificationId: notificationId,
          customerId: authenticatedCustomerId!,
          readAt: now,
          createdAt: now,
        ),
      );
      notifyListeners();
    } else if (!_sessionReadRecords[index].isRead) {
      _sessionReadRecords[index] = _sessionReadRecords[index].copyWith(
        readAt: now,
      );
      notifyListeners();
    }
  }

  Future<void> markAsUnread(String notificationId) async {
    if (authenticatedCustomerId == null) return;
    final id = '${notificationId}_$authenticatedCustomerId';

    final index = _sessionReadRecords.indexWhere((r) => r.id == id);
    if (index != -1) {
      _sessionReadRecords[index] = _sessionReadRecords[index].copyWith(
        clearReadAt: true,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (authenticatedCustomerId == null) return;
    final eligible = visibleNotificationsForCustomer;
    final now = DateTime.now();

    for (final notif in eligible) {
      final id = '${notif.id}_$authenticatedCustomerId';
      final index = _sessionReadRecords.indexWhere((r) => r.id == id);
      if (index == -1) {
        _sessionReadRecords.add(
          NotificationReadModel(
            id: id,
            notificationId: notif.id,
            customerId: authenticatedCustomerId!,
            readAt: now,
            createdAt: now,
          ),
        );
      } else if (!_sessionReadRecords[index].isRead) {
        _sessionReadRecords[index] = _sessionReadRecords[index].copyWith(
          readAt: now,
        );
      }
    }
    notifyListeners();
  }

  // --- Admin Actions ---

  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final newNotif = notification.copyWith(createdAt: now, updatedAt: now);

    _sessionNotifications.add(newNotif);
    _isLoading = false;
    notifyListeners();
    return newNotif;
  }

  Future<NotificationModel> updateNotification(
    NotificationModel notification,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));
    final index = _sessionNotifications.indexWhere(
      (n) => n.id == notification.id,
    );
    if (index != -1) {
      final now = DateTime.now();
      final updated = notification.copyWith(updatedAt: now);
      _sessionNotifications[index] = updated;
      _isLoading = false;
      notifyListeners();
      return updated;
    }

    _isLoading = false;
    notifyListeners();
    return notification;
  }

  Future<void> publishNotification(
    String notificationId,
    String updatedBy,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));
    final index = _sessionNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (index != -1) {
      final now = DateTime.now();
      _sessionNotifications[index] = _sessionNotifications[index].copyWith(
        status: NotificationStatus.published,
        publishedAt: now,
        updatedAt: now,
        updatedBy: updatedBy,
        clearScheduledAt: true,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> scheduleNotification({
    required String notificationId,
    required DateTime scheduledAt,
    required String updatedBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));
    final index = _sessionNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (index != -1) {
      final now = DateTime.now();
      _sessionNotifications[index] = _sessionNotifications[index].copyWith(
        status: NotificationStatus.scheduled,
        scheduledAt: scheduledAt,
        updatedAt: now,
        updatedBy: updatedBy,
        clearPublishedAt: true,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelScheduledNotification(
    String notificationId,
    String updatedBy,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sessionNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (index != -1) {
      final now = DateTime.now();
      _sessionNotifications[index] = _sessionNotifications[index].copyWith(
        status: NotificationStatus.cancelled,
        updatedAt: now,
        updatedBy: updatedBy,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> archiveNotification(
    String notificationId,
    String updatedBy,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sessionNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (index != -1) {
      final now = DateTime.now();
      _sessionNotifications[index] = _sessionNotifications[index].copyWith(
        status: NotificationStatus.archived,
        updatedAt: now,
        updatedBy: updatedBy,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDraft(String notificationId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    _sessionNotifications.removeWhere((n) => n.id == notificationId);
    _sessionReadRecords.removeWhere((r) => r.notificationId == notificationId);

    _isLoading = false;
    notifyListeners();
  }
}
