import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/stitching_order_model.dart';

/// In-memory controller for managing stitching orders and history timelines.
class StitchingOrderController extends ChangeNotifier {
  StitchingOrderController({
    required this.boutiqueId,
    this.branchId,
    this.customerId,
  }) {
    loadOrders();
  }

  final String boutiqueId;
  final String? branchId;
  final String? customerId;

  bool _isLoading = false;
  String _searchQuery = '';
  StitchingOrderStatus? _selectedStatusFilter;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  StitchingOrderStatus? get selectedStatusFilter => _selectedStatusFilter;

  static final List<StitchingOrderModel> _sessionOrders = [];
  static final List<StitchingOrderHistoryModel> _sessionHistory = [];

  List<StitchingOrderModel> get visibleOrders {
    var list = _sessionOrders.where((o) {
      if (o.boutiqueId != boutiqueId) return false;
      if (branchId != null && o.branchId != branchId) return false;
      if (customerId != null && o.customerId != customerId) return false;
      if (_selectedStatusFilter != null && o.status != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((o) {
        final matchNum = o.orderNumber.toLowerCase().contains(q);
        final matchDesign = o.designReferences.any(
          (d) => d.designName.toLowerCase().contains(q),
        );
        final matchNotes =
            o.notes != null && o.notes!.toLowerCase().contains(q);
        return matchNum || matchDesign || matchNotes;
      }).toList();
    }

    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  void searchOrders(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void filterByStatus(StitchingOrderStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  StitchingOrderModel? getOrderById(String id) {
    try {
      return _sessionOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<StitchingOrderHistoryModel> getHistoryForOrder(String stitchingOrderId) {
    final list = _sessionHistory
        .where((h) => h.stitchingOrderId == stitchingOrderId)
        .toList();
    list.sort((a, b) => a.changedAt.compareTo(b.changedAt));
    return list;
  }

  Future<StitchingOrderModel> createOrder(StitchingOrderModel order) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final newOrder = order.copyWith(createdAt: now, updatedAt: now);

    _sessionOrders.add(newOrder);

    // Initial history record
    final initialHistory = StitchingOrderHistoryModel(
      id: const Uuid().v4(),
      stitchingOrderId: newOrder.id,
      boutiqueId: newOrder.boutiqueId,
      branchId: newOrder.branchId,
      customerId: newOrder.customerId,
      status: newOrder.status,
      note: 'Order logged into system.',
      changedAt: now,
      changedBy: newOrder.createdBy ?? 'admin',
    );
    _sessionHistory.add(initialHistory);

    _isLoading = false;
    notifyListeners();
    return newOrder;
  }

  Future<StitchingOrderModel> updateOrder(StitchingOrderModel order) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    final index = _sessionOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      final now = DateTime.now();
      final updated = order.copyWith(updatedAt: now);
      _sessionOrders[index] = updated;

      _isLoading = false;
      notifyListeners();
      return updated;
    }

    _isLoading = false;
    notifyListeners();
    return order;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required StitchingOrderStatus newStatus,
    String? note,
    required String updatedBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    final index = _sessionOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final current = _sessionOrders[index];
      final now = DateTime.now();

      final updated = current.copyWith(
        status: newStatus,
        updatedAt: now,
        updatedBy: updatedBy,
        completedAt: newStatus == StitchingOrderStatus.completed ? now : null,
        clearCompletedAt: newStatus != StitchingOrderStatus.completed,
      );

      _sessionOrders[index] = updated;

      // Add history record
      final historyRecord = StitchingOrderHistoryModel(
        id: const Uuid().v4(),
        stitchingOrderId: orderId,
        boutiqueId: current.boutiqueId,
        branchId: current.branchId,
        customerId: current.customerId,
        status: newStatus,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        changedAt: now,
        changedBy: updatedBy,
      );

      _sessionHistory.add(historyRecord);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMockOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    _sessionOrders.removeWhere((o) => o.id == orderId);
    _sessionHistory.removeWhere((h) => h.stitchingOrderId == orderId);

    _isLoading = false;
    notifyListeners();
  }
}
