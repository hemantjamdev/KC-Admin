import 'package:flutter/material.dart';
import '../../domain/models/boutique_model.dart';
import '../../domain/models/branch_model.dart';

/// Lightweight session selection controller for managing current Boutique and Branch selections.
class BoutiqueSelectionController extends ChangeNotifier {
  BoutiqueModel? _selectedBoutique;
  BranchModel? _selectedBranch;

  BoutiqueModel? get selectedBoutique => _selectedBoutique;
  BranchModel? get selectedBranch => _selectedBranch;

  bool get hasSelectedBoutique => _selectedBoutique != null;
  bool get hasSelectedBranch => _selectedBranch != null;

  void selectBoutique(BoutiqueModel boutique) {
    if (!boutique.isActive) return;
    if (_selectedBoutique?.id != boutique.id) {
      _selectedBoutique = boutique;
      _selectedBranch = null;
      notifyListeners();
    }
  }

  void selectBranch(BranchModel branch) {
    if (!branch.isActive) return;
    if (_selectedBoutique != null &&
        branch.boutiqueId == _selectedBoutique!.id) {
      _selectedBranch = branch;
      notifyListeners();
    }
  }

  void clearBranch() {
    _selectedBranch = null;
    notifyListeners();
  }

  void clearAll() {
    _selectedBoutique = null;
    _selectedBranch = null;
    notifyListeners();
  }
}

/// InheritedNotifier scope for providing [BoutiqueSelectionController] to the widget tree.
class BoutiqueSelectionScope
    extends InheritedNotifier<BoutiqueSelectionController> {
  const BoutiqueSelectionScope({
    super.key,
    required BoutiqueSelectionController controller,
    required super.child,
  }) : super(notifier: controller);

  static BoutiqueSelectionController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BoutiqueSelectionScope>();
    assert(scope != null, 'No BoutiqueSelectionScope found in BuildContext');
    return scope!.notifier!;
  }
}
