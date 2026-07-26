import 'package:flutter/material.dart';
import '../../data/repositories/section_firestore_repository.dart';
import '../../domain/models/section_item_model.dart';
import '../../domain/models/section_model.dart';
import '../../../design/domain/models/design_model.dart';
import '../../../design/presentation/controllers/design_controller.dart';

enum SectionStatusFilter { all, active, inactive }

enum SectionScopeFilter { all, boutiqueWide, currentBranch }

/// Section Controller for KC-Admin with full CRUD, section items management, and design resolution preview.
class SectionController extends ChangeNotifier {
  SectionController({
    required String boutiqueId,
    required String? branchId,
    required DesignController designController,
    SectionFirestoreRepository? repository,
  })  : _boutiqueId = boutiqueId,
        _branchId = branchId,
        _designController = designController,
        _repository = repository ?? SectionFirestoreRepository();

  final String _boutiqueId;
  final String? _branchId;
  final DesignController _designController;
  final SectionFirestoreRepository _repository;

  List<SectionModel> _sections = [];
  List<SectionItemModel> _sectionItems = [];
  bool _isLoading = false;
  String _searchQuery = '';
  SectionType? _selectedTypeFilter;
  SectionStatusFilter _statusFilter = SectionStatusFilter.all;
  SectionScopeFilter _scopeFilter = SectionScopeFilter.all;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  SectionType? get selectedTypeFilter => _selectedTypeFilter;
  SectionStatusFilter get statusFilter => _statusFilter;
  SectionScopeFilter get scopeFilter => _scopeFilter;

  List<SectionModel> get visibleSections {
    var results = _sections.where((s) {
      // Status filter
      switch (_statusFilter) {
        case SectionStatusFilter.active:
          if (!s.isActive) return false;
        case SectionStatusFilter.inactive:
          if (s.isActive) return false;
        case SectionStatusFilter.all:
          break;
      }

      // Type filter
      if (_selectedTypeFilter != null && s.type != _selectedTypeFilter) {
        return false;
      }

      // Scope filter
      switch (_scopeFilter) {
        case SectionScopeFilter.boutiqueWide:
          if (s.branchId != null) return false;
        case SectionScopeFilter.currentBranch:
          if (s.branchId != _branchId) return false;
        case SectionScopeFilter.all:
          break;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = s.title.toLowerCase().contains(q);
        final matchSub = (s.subtitle ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchSub) return false;
      }

      return true;
    }).toList();

    results.sort((a, b) {
      final order = a.sortOrder.compareTo(b.sortOrder);
      return order != 0 ? order : a.title.compareTo(b.title);
    });

    return results;
  }

  List<SectionModel> get allSections => List.unmodifiable(_sections);
  List<SectionItemModel> get allSectionItems =>
      List.unmodifiable(_sectionItems);

  Future<void> loadSections() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _sections = await _repository.watchSections(_boutiqueId).first;
    } catch (_) {
      _sections = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchSections(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    notifyListeners();
  }

  void filterByType(SectionType? type) {
    if (_selectedTypeFilter == type) return;
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void filterByStatus(SectionStatusFilter filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
  }

  void filterByScope(SectionScopeFilter filter) {
    if (_scopeFilter == filter) return;
    _scopeFilter = filter;
    notifyListeners();
  }

  String? addSection(SectionModel section) {
    if (section.boutiqueId != _boutiqueId) {
      return 'Section does not belong to this boutique.';
    }
    _sections.add(section);
    _sortSections();
    notifyListeners();
    return null;
  }

  String? updateSection(SectionModel updated) {
    if (updated.boutiqueId != _boutiqueId) {
      return 'Section does not belong to this boutique.';
    }
    final idx = _sections.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return 'Section not found.';
    _sections[idx] = updated;
    _sortSections();
    notifyListeners();
    return null;
  }

  void toggleSectionStatus(String sectionId) {
    final idx = _sections.indexWhere((s) => s.id == sectionId);
    if (idx == -1) return;
    final s = _sections[idx];
    _sections[idx] = s.copyWith(
      isActive: !s.isActive,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void deleteSection(String sectionId) {
    _sections.removeWhere((s) => s.id == sectionId);
    _sectionItems.removeWhere((i) => i.sectionId == sectionId);
    notifyListeners();
  }

  void reorderSections(List<SectionModel> reordered) {
    final updated = List<SectionModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    for (final item in updated) {
      final idx = _sections.indexWhere((s) => s.id == item.id);
      if (idx != -1) _sections[idx] = item;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Manual Section Items Management
  // ---------------------------------------------------------------------------

  List<SectionItemModel> getItemsForSection(String sectionId) {
    final list = _sectionItems.where((i) => i.sectionId == sectionId).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<DesignModel> getDesignsForSection(
    SectionModel section,
    String? branchId,
  ) {
    if (section.type == SectionType.manual) {
      final items = getItemsForSection(section.id);
      final list = <DesignModel>[];
      for (final item in items) {
        final d = _designController.getDesignById(item.designId);
        if (d != null) list.add(d);
      }
      return list;
    } else if (section.type == SectionType.newArrivals) {
      final all = _designController.allDesigns
          .where((d) => d.isActive)
          .toList();
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all;
    } else if (section.type == SectionType.recommended) {
      final all = _designController.allDesigns
          .where((d) => d.isActive)
          .toList();
      final tagged = all
          .where(
            (d) => d.tags.any(
              (t) =>
                  t.contains('featured') ||
                  t.contains('popular') ||
                  t.contains('recommended'),
            ),
          )
          .toList();
      return tagged.isNotEmpty ? tagged : all;
    }
    return [];
  }

  void saveSectionItems(
    String sectionId,
    List<String> designIds,
    String? branchId,
  ) {
    _sectionItems.removeWhere((i) => i.sectionId == sectionId);
    final now = DateTime.now();
    for (var i = 0; i < designIds.length; i++) {
      _sectionItems.add(
        SectionItemModel(
          id: 'item_${now.millisecondsSinceEpoch}_$i',
          boutiqueId: _boutiqueId,
          branchId: branchId,
          sectionId: sectionId,
          designId: designIds[i],
          sortOrder: i,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    notifyListeners();
  }

  void _sortSections() {
    _sections.sort((a, b) {
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.title.compareTo(b.title);
    });
  }
}
