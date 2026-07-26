import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/data/repositories/boutique_firestore_repository.dart';
import '../../../boutique/data/repositories/branch_firestore_repository.dart';
import '../../../boutique/domain/models/boutique_model.dart';
import '../../../boutique/domain/models/branch_model.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

/// Admin Customer Add/Edit Form page.
class AdminCustomerFormPage extends StatefulWidget {
  const AdminCustomerFormPage({super.key, this.existingCustomer});
  final CustomerModel? existingCustomer;
  bool get isEditMode => existingCustomer != null;

  @override
  State<AdminCustomerFormPage> createState() => _AdminCustomerFormPageState();
}

class _AdminCustomerFormPageState extends State<AdminCustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final CustomerRepository _repository;
  final _boutiqueRepository = BoutiqueFirestoreRepository();
  final _branchRepository = BranchFirestoreRepository();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isActive = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  List<BoutiqueModel> _allBoutiques = [];
  List<BranchModel> _allBranches = [];

  final List<String> _selectedBoutiqueIds = [];
  final List<String> _selectedBranchIds = [];

  @override
  void initState() {
    super.initState();
    _repository = CustomerRepositoryImpl();
    _loadBoutiquesAndBranches();

    _displayNameController.addListener(_markDirty);
    _emailController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
  }

  Future<void> _loadBoutiquesAndBranches() async {
    final boutiques = await _boutiqueRepository.getBoutiques();
    if (!mounted) return;
    setState(() {
      _allBoutiques = boutiques;
    });

    final currentBoutique = BoutiqueSelectionScope.of(context).selectedBoutique;
    final currentBranch = BoutiqueSelectionScope.of(context).selectedBranch;

    if (currentBoutique != null) {
      final branches = await _branchRepository.getBranchesForBoutique(currentBoutique.id);
      if (!mounted) return;
      setState(() {
        _allBranches = branches;
      });
    }

    if (widget.isEditMode) {
      final c = widget.existingCustomer!;
      _displayNameController.text = c.displayName;
      _emailController.text = c.email ?? '';
      _phoneController.text = c.phone ?? '';
      _isActive = c.isActive;
      _selectedBoutiqueIds.addAll(c.boutiqueIds);
      _selectedBranchIds.addAll(c.branchIds);
    } else {
      if (currentBoutique != null) {
        _selectedBoutiqueIds.add(currentBoutique.id);
      }
      if (currentBranch != null) {
        _selectedBranchIds.add(currentBranch.id);
      }
    }

    _displayNameController.addListener(_markDirty);
    _emailController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Discard Changes?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Unsaved customer details will be lost.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedBoutiqueIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one boutique assignment.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    if (_selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one branch assignment.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final adminUid =
        FirebaseAuth.instance.currentUser?.uid ?? 'admin_local_actor';
    final now = DateTime.now();
    final router = GoRouter.of(context);

    try {
      final CustomerModel customer;
      if (widget.isEditMode) {
        final existing = widget.existingCustomer!;
        customer = existing.copyWith(
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          boutiqueIds: _selectedBoutiqueIds,
          branchIds: _selectedBranchIds,
          isActive: _isActive,
          updatedAt: now,
          updatedBy: adminUid,
          clearEmail: _emailController.text.trim().isEmpty,
          clearPhone: _phoneController.text.trim().isEmpty,
        );
        await _repository.updateCustomer(customer);
      } else {
        final newId = const Uuid().v4();
        customer = CustomerModel(
          id: newId,
          firebaseUid: null,
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          photoUrl: null,
          boutiqueIds: _selectedBoutiqueIds,
          branchIds: _selectedBranchIds,
          source: CustomerSource.admin,
          isActive: _isActive,
          createdAt: now,
          updatedAt: now,
          createdBy: adminUid,
          updatedBy: adminUid,
        );
        await _repository.createCustomer(customer);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? '"${customer.displayName}" updated.'
                : '"${customer.displayName}" created.',
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      router.go(AppRoutes.adminCustomerList);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save customer record. Please try again.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final canLeave = await _onWillPop();
        if (canLeave) router.go(AppRoutes.adminCustomerList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Customer' : 'Add Customer',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              final router = GoRouter.of(context);
              final canLeave = await _onWillPop();
              if (canLeave) router.go(AppRoutes.adminCustomerList);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(
                        'Display Name *',
                        TextFormField(
                          controller: _displayNameController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('e.g. Priya Sharma'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Display name is required.';
                            }
                            if (v.trim().length < 2) {
                              return 'Name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Email Address',
                        TextFormField(
                          controller: _emailController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec('e.g. priya@example.com'),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final ok = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(v.trim());
                              if (!ok) return 'Please enter a valid email.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Phone Number',
                        TextFormField(
                          controller: _phoneController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          keyboardType: TextInputType.phone,
                          decoration: _dec('e.g. +91 9876543210'),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              if (v.trim().length < 7) {
                                return 'Please enter a valid phone number.';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Boutique Assignment Checkboxes
                      _boutiqueAssignmentSection(),
                      const SizedBox(height: AppSpacing.md),
                      // Branch Assignment Checkboxes
                      _branchAssignmentSection(),
                      const SizedBox(height: AppSpacing.md),
                      // Active Toggle
                      _activeToggle(),
                      const SizedBox(height: AppSpacing.xl),
                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Save Customer'
                                  : 'Create Customer',
                              onPressed: _save,
                            ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _boutiqueAssignmentSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Boutiques *',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ..._allBoutiques.map((b) {
            final isChecked = _selectedBoutiqueIds.contains(b.id);
            return CheckboxListTile(
              value: isChecked,
              title: Text(
                b.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              activeColor: AppColors.primary,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedBoutiqueIds.add(b.id);
                  } else {
                    _selectedBoutiqueIds.remove(b.id);
                  }
                  _hasChanges = true;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _branchAssignmentSection() {
    final availableBranches = _allBranches
        .where((br) => _selectedBoutiqueIds.contains(br.boutiqueId))
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Branches *',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (availableBranches.isEmpty)
            const Text(
              'Select a boutique to see available branches.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            )
          else
            ...availableBranches.map((br) {
              final isChecked = _selectedBranchIds.contains(br.id);
              return CheckboxListTile(
                value: isChecked,
                title: Text(
                  '${br.name} (${br.city})',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                activeColor: AppColors.primary,
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedBranchIds.add(br.id);
                    } else {
                      _selectedBranchIds.remove(br.id);
                    }
                    _hasChanges = true;
                  });
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _activeToggle() => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.borderMd,
      border: Border.all(color: AppColors.surfaceBorder),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Inactive profiles have restricted access in KC-App.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (v) => setState(() {
            _isActive = v;
            _hasChanges = true;
          }),
          activeThumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.surfaceBorder,
        ),
      ],
    ),
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      child,
    ],
  );

  static const TextStyle _fieldStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.surfaceBorder),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.surfaceBorder),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  );
}
