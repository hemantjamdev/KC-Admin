import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
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

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();
    _repository = CustomerRepositoryImpl();

    if (widget.isEditMode) {
      final c = widget.existingCustomer!;
      _displayNameController.text = c.displayName;
      _emailController.text = c.email ?? '';
      _phoneController.text = c.phone ?? '';
    }

    _displayNameController.addListener(_markDirty);
    _emailController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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

    setState(() => _isSaving = true);

    try {
      const adminUid = 'admin_local_actor';
      final now = DateTime.now();

      if (widget.isEditMode) {
        final existing = widget.existingCustomer!;
        final updated = existing.copyWith(
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          isActive: true,
          updatedAt: now,
          updatedBy: adminUid,
          clearEmail: _emailController.text.trim().isEmpty,
          clearPhone: _phoneController.text.trim().isEmpty,
        );

        await _repository.updateCustomer(updated);
      } else {
        final id = const Uuid().v4();
        final created = CustomerModel(
          id: id,
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          source: CustomerSource.admin,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          createdBy: adminUid,
          updatedBy: adminUid,
        );

        await _repository.createCustomer(created);
      }

      if (!mounted) return;
      _allowDiscardPop = true;
      AppToast.show(
        context,
        widget.isEditMode
            ? 'Customer updated successfully.'
            : 'Customer created successfully.',
        type: ToastType.success,
      );
      context.popOrGoWithResult(true, AppRoutes.adminCustomerList);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        'Failed to save customer profile.',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowDiscardPop || !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          setState(() => _allowDiscardPop = true);
          context.popOrGo(AppRoutes.adminCustomerList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                setState(() => _allowDiscardPop = true);
                context.popOrGo(AppRoutes.adminCustomerList);
              }
            },
          ),
          title: Text(
            widget.isEditMode ? 'Edit Customer' : 'Add New Customer',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Name
                      const Text(
                        'Full Name *',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _displayNameController,
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(
                          context,
                        ).requestFocus(_emailFocusNode),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'e.g., Ananya Sharma',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Display Name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Email
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(
                          context,
                        ).requestFocus(_phoneFocusNode),
                        style: const TextStyle(color: AppColors.textPrimary),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'e.g., ananya@example.com',
                        ),
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(val.trim())) {
                              return 'Please enter a valid email address.';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Phone
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                        style: const TextStyle(color: AppColors.textPrimary),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'e.g., +919876543210',
                        ),
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                            if (!phoneRegex.hasMatch(val.trim())) {
                              return 'Please enter a valid phone number.';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

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
}
