import 'package:flutter/material.dart';
import '../../data/repositories/design_firestore_repository.dart';
import '../../domain/models/design_availability_model.dart';
import '../../domain/models/design_model.dart';

/// Status filter options for the admin design list.
enum DesignStatusFilter { all, active, inactive }

/// Availability filter options (admin — per selected branch).
enum AvailabilityFilter { all, available, unavailable, hidden, notConfigured }

/// Full CRUD design controller for KC-Admin.
/// Scoped to the selected boutique.
class DesignController extends ChangeNotifier {
  DesignController({
    required String boutiqueId,
    required List<String> activeCategoryIds,
    DesignFirestoreRepository? repository,
  }) : _boutiqueId = boutiqueId,
       _activeCategoryIds = activeCategoryIds,
       _repository = repository ?? DesignFirestoreRepository();

  final String _boutiqueId;
  final List<String> _activeCategoryIds;
  final DesignFirestoreRepository _repository;

  List<DesignModel> _designs = [];
  List<DesignAvailabilityModel> _availability = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategoryId;
  DesignStatusFilter _statusFilter = DesignStatusFilter.all;
  AvailabilityFilter _availabilityFilter = AvailabilityFilter.all;
  String? _filterBranchId;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  DesignStatusFilter get statusFilter => _statusFilter;
  AvailabilityFilter get availabilityFilter => _availabilityFilter;

  /// All designs after filters + search applied.
  List<DesignModel> get visibleDesigns {
    var results = _designs.where((d) {
      // Status filter
      switch (_statusFilter) {
        case DesignStatusFilter.active:
          if (!d.isActive) return false;
        case DesignStatusFilter.inactive:
          if (cIsActive(d)) return false;
        case DesignStatusFilter.all:
          break;
      }
      // Category filter
      if (_selectedCategoryId != null && d.categoryId != _selectedCategoryId) {
        return false;
      }
      // Availability filter per branch
      if (_filterBranchId != null &&
          _availabilityFilter != AvailabilityFilter.all) {
        final avail = _getAvailabilityForBranchDesign(_filterBranchId!, d.id);
        switch (_availabilityFilter) {
          case AvailabilityFilter.notConfigured:
            if (avail != null) return false;
          case AvailabilityFilter.available:
            if (avail == null || avail.status != AvailabilityStatus.available) {
              return false;
            }
          case AvailabilityFilter.unavailable:
            if (avail == null ||
                avail.status != AvailabilityStatus.unavailable) {
              return false;
            }
          case AvailabilityFilter.hidden:
            if (avail == null || avail.status != AvailabilityStatus.hidden) {
              return false;
            }
          case AvailabilityFilter.all:
            break;
        }
      }
      // Search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final inName = d.name.toLowerCase().contains(q);
        final inSlug = d.slug.toLowerCase().contains(q);
        final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
        final inKeywords = d.searchKeywords.any(
          (k) => k.toLowerCase().contains(q),
        );
        if (!inName && !inSlug && !inTags && !inKeywords) return false;
      }
      return true;
    }).toList();

    results.sort((a, b) {
      // Sort by availability displayOrder for selected branch, then sortOrder
      if (_filterBranchId != null) {
        final aAvail = _getAvailabilityForBranchDesign(_filterBranchId!, a.id);
        final bAvail = _getAvailabilityForBranchDesign(_filterBranchId!, b.id);
        if (aAvail != null && bAvail != null) {
          final dOrder = aAvail.displayOrder.compareTo(bAvail.displayOrder);
          if (dOrder != 0) {
            return dOrder;
          }
        }
      }
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.name.compareTo(b.name);
    });
    return results;
  }

  bool cIsActive(DesignModel d) => d.isActive;

  List<DesignModel> get allDesigns => List.unmodifiable(_designs);
  List<DesignAvailabilityModel> get availabilityRecords =>
      List.unmodifiable(_availability);
  int get totalCount => _designs.length;

  Future<void> loadDesigns() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _designs = await _repository.watchDesigns(_boutiqueId).first;
    } catch (_) {
      _designs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchDesigns(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    notifyListeners();
  }

  void filterByCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void filterByStatus(DesignStatusFilter filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
  }

  void filterByAvailability(
    AvailabilityFilter filter, {
    required String? branchId,
  }) {
    if (_availabilityFilter == filter && _filterBranchId == branchId) return;
    _availabilityFilter = filter;
    _filterBranchId = branchId;
    notifyListeners();
  }

  /// Returns null on success, error message on failure.
  String? addDesign(DesignModel design) {
    if (design.boutiqueId != _boutiqueId) {
      return 'Design does not belong to this boutique.';
    }
    if (_designs.any((d) => d.slug == design.slug)) {
      return 'A design with this slug already exists.';
    }
    _designs.add(design);
    _sort();
    notifyListeners();
    return null;
  }

  /// Returns null on success, error message on failure.
  String? updateDesign(DesignModel updated) {
    if (updated.boutiqueId != _boutiqueId) {
      return 'Design does not belong to this boutique.';
    }
    if (_designs.any((d) => d.slug == updated.slug && d.id != updated.id)) {
      return 'A design with this slug already exists.';
    }
    final idx = _designs.indexWhere((d) => d.id == updated.id);
    if (idx == -1) return 'Design not found.';
    _designs[idx] = updated;
    _sort();
    notifyListeners();
    return null;
  }

  void toggleDesignStatus(String designId) {
    final idx = _designs.indexWhere((d) => d.id == designId);
    if (idx == -1) return;
    final d = _designs[idx];
    _designs[idx] = d.copyWith(
      isActive: !d.isActive,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void deleteDesign(String designId) {
    _designs.removeWhere((d) => d.id == designId);
    _availability.removeWhere((a) => a.designId == designId);
    notifyListeners();
  }

  void reorderDesigns(List<DesignModel> reordered) {
    final updated = List<DesignModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    for (final item in updated) {
      final idx = _designs.indexWhere((d) => d.id == item.id);
      if (idx != -1) _designs[idx] = item;
    }
    notifyListeners();
  }

  /// Upsert an availability record.
  void updateAvailability(DesignAvailabilityModel record) {
    final idx = _availability.indexWhere((a) => a.id == record.id);
    if (idx == -1) {
      _availability.add(record);
    } else {
      _availability[idx] = record;
    }
    notifyListeners();
  }

  /// Customer-eligible designs for a branch (respects all visibility rules).
  List<DesignModel> getAvailableDesignsForBranch(String branchId) {
    final now = DateTime.now();
    return _designs.where((d) {
      if (!d.isActive) return false;
      if (!_activeCategoryIds.contains(d.categoryId)) return false;
      final avail = _getAvailabilityForBranchDesign(branchId, d.id);
      if (avail == null) return false;
      if (avail.status != AvailabilityStatus.available) return false;
      if (avail.availableFrom != null && now.isBefore(avail.availableFrom!)) {
        return false;
      }
      if (avail.availableUntil != null && now.isAfter(avail.availableUntil!)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) {
      final aAvail = _getAvailabilityForBranchDesign(branchId, a.id)!;
      final bAvail = _getAvailabilityForBranchDesign(branchId, b.id)!;
      final d = aAvail.displayOrder.compareTo(bAvail.displayOrder);
      return d != 0 ? d : a.sortOrder.compareTo(b.sortOrder);
    });
  }

  DesignModel? getDesignById(String designId) {
    try {
      return _designs.firstWhere((d) => d.id == designId);
    } catch (_) {
      return null;
    }
  }

  DesignAvailabilityModel? getAvailabilityForBranchDesign(
    String branchId,
    String designId,
  ) => _getAvailabilityForBranchDesign(branchId, designId);

  List<DesignAvailabilityModel> getAvailabilityForDesign(String designId) {
    return _availability.where((a) => a.designId == designId).toList();
  }

  DesignAvailabilityModel? _getAvailabilityForBranchDesign(
    String branchId,
    String designId,
  ) {
    try {
      return _availability.firstWhere(
        (a) => a.branchId == branchId && a.designId == designId,
      );
    } catch (_) {
      return null;
    }
  }

  void _sort() {
    _designs.sort((a, b) {
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.name.compareTo(b.name);
    });
  }
}
