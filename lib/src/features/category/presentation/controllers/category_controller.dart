import 'package:flutter/material.dart';
import '../../data/repositories/category_firestore_repository.dart';
import '../../domain/models/category_model.dart';

/// Status filter options for the admin category list.
enum CategoryStatusFilter { all, active, inactive }

/// Full CRUD category controller for KC-Admin.
/// Scoped to the currently selected boutique.
class CategoryController extends ChangeNotifier {
  CategoryController({
    required String boutiqueId,
    CategoryFirestoreRepository? repository,
  })  : _boutiqueId = boutiqueId,
        _repository = repository ?? CategoryFirestoreRepository();

  final String _boutiqueId;
  final CategoryFirestoreRepository _repository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  CategoryStatusFilter _statusFilter = CategoryStatusFilter.all;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  CategoryStatusFilter get statusFilter => _statusFilter;

  /// All categories in the boutique after status filter + search.
  List<CategoryModel> get visibleCategories {
    var results = _categories.where((c) {
      switch (_statusFilter) {
        case CategoryStatusFilter.active:
          if (!c.isActive) return false;
        case CategoryStatusFilter.inactive:
          if (c.isActive) return false;
        case CategoryStatusFilter.all:
          break;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c.name.toLowerCase().contains(q) ||
            c.slug.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    results.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      return sortCompare != 0 ? sortCompare : a.name.compareTo(b.name);
    });

    return results;
  }

  /// All categories (unfiltered) for reordering.
  List<CategoryModel> get allCategories => List.unmodifiable(_categories);

  int get totalCount => _categories.length;

  Future<void> loadCategories() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.watchCategories(_boutiqueId).first;
    } catch (_) {
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCategories(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query.trim();
    notifyListeners();
  }

  void filterByStatus(CategoryStatusFilter filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
  }

  /// Returns null on success, or an error message string on failure.
  String? addCategory(CategoryModel category) {
    if (category.boutiqueId != _boutiqueId) {
      return 'Category does not belong to this boutique.';
    }
    final slugConflict = _categories.any((c) => c.slug == category.slug);
    if (slugConflict) {
      return 'A category with this slug already exists.';
    }
    _categories.add(category);
    _resort();
    notifyListeners();
    return null;
  }

  /// Returns null on success, or an error message string on failure.
  String? updateCategory(CategoryModel updated) {
    if (updated.boutiqueId != _boutiqueId) {
      return 'Category does not belong to this boutique.';
    }
    final slugConflict = _categories.any(
      (c) => c.slug == updated.slug && c.id != updated.id,
    );
    if (slugConflict) {
      return 'A category with this slug already exists.';
    }
    final idx = _categories.indexWhere((c) => c.id == updated.id);
    if (idx == -1) return 'Category not found.';
    _categories[idx] = updated;
    _resort();
    notifyListeners();
    return null;
  }

  void toggleCategoryStatus(String categoryId) {
    final idx = _categories.indexWhere((c) => c.id == categoryId);
    if (idx == -1) return;
    final cat = _categories[idx];
    _categories[idx] = cat.copyWith(
      isActive: !cat.isActive,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  /// Reorders categories and reassigns sequential sortOrder values.
  void reorderCategories(List<CategoryModel> reordered) {
    final updated = List<CategoryModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    // Update matching IDs in _categories
    for (final item in updated) {
      final idx = _categories.indexWhere((c) => c.id == item.id);
      if (idx != -1) {
        _categories[idx] = item;
      }
    }
    notifyListeners();
  }

  void _resort() {
    _categories.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      return sortCompare != 0 ? sortCompare : a.name.compareTo(b.name);
    });
  }
}
