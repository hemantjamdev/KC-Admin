import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../customer/application/providers/customer_providers.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../application/providers/stitching_providers.dart';
import '../../domain/models/stitching_order_model.dart';

/// Unified Add / Edit Stitching Request Form Page.
class StitchingOrderFormPage extends ConsumerStatefulWidget {
  const StitchingOrderFormPage({
    super.key,
    this.existingOrder,
    this.preselectedCustomer,
  });

  final StitchingOrderModel? existingOrder;
  final CustomerModel? preselectedCustomer;

  bool get isEditMode => existingOrder != null;

  @override
  ConsumerState<StitchingOrderFormPage> createState() =>
      _StitchingOrderFormPageState();
}

class _StitchingOrderFormPageState
    extends ConsumerState<StitchingOrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'New Arrival';
  DateTime? _pickupDate;

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  List<CustomerModel> _availableCustomers = [];
  String? _selectedCustomerId;

  static const List<String> _defaultCategories = [
    'New Arrival',
    'Seasonal',
    'Festive',
    'Blouse',
    'Lehenga',
    'Suit',
    'Saree',
    'Kurti',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomers();

    final minPickupDate = DateTime.now().add(const Duration(days: 3));

    if (widget.isEditMode) {
      final o = widget.existingOrder!;
      _selectedCustomerId = o.customerId;
      _nameController.text = o.displayRequestName;
      _selectedCategory = o.displayCategoryName;
      _notesController.text = o.notes ?? '';
      _pickupDate = o.expectedReadyAt ?? minPickupDate;
    } else {
      if (widget.preselectedCustomer != null) {
        final pc = widget.preselectedCustomer!;
        _selectedCustomerId = pc.firebaseUid ?? pc.id;
      }
      _pickupDate = minPickupDate;
    }

    _nameController.addListener(_markDirty);
    _notesController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadCustomers() async {
    try {
      final list =
          await ref.read(customerRepositoryProvider).getCustomersForAdmin();
      if (!mounted) return;
      setState(() {
        _availableCustomers = list;

        if (widget.preselectedCustomer != null) {
          final pc = widget.preselectedCustomer!;
          final targetId = pc.firebaseUid ?? pc.id;

          if (!list.any((c) => (c.firebaseUid ?? c.id) == targetId)) {
            _availableCustomers.insert(0, pc);
          }
          _selectedCustomerId = targetId;
        } else if (!widget.isEditMode &&
            _selectedCustomerId == null &&
            list.isNotEmpty) {
          final firstCustomer = list.first;
          _selectedCustomerId = firstCustomer.firebaseUid ?? firstCustomer.id;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_allowDiscardPop || !_hasChanges || _isSaving) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes to this request. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  Future<void> _selectPickupDate() async {
    final now = DateTime.now();
    final minDate = now.add(const Duration(days: 3));
    final maxDate = now.add(const Duration(days: 30));

    final initialDate = _pickupDate != null &&
            _pickupDate!.isAfter(minDate.subtract(const Duration(days: 1))) &&
            _pickupDate!.isBefore(maxDate.add(const Duration(days: 1)))
        ? _pickupDate!
        : minDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'Select Pickup Date (3 to 30 days in future)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surfaceWhite,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _pickupDate) {
      setState(() {
        _pickupDate = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      AppToast.show(
        context,
        'Please select a customer for this request',
        type: ToastType.error,
      );
      return;
    }

    if (_pickupDate == null) {
      AppToast.show(
        context,
        'Please select a valid pickup date',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(stitchingRepositoryProvider);
      final customer = _availableCustomers.firstWhere(
        (c) => (c.firebaseUid ?? c.id) == _selectedCustomerId,
        orElse: () => widget.preselectedCustomer ??
            CustomerModel(
              id: _selectedCustomerId!,
              displayName: 'Customer',
              isActive: true,
              source: CustomerSource.admin,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );

      final nowStr = DateTime.now().millisecondsSinceEpoch.toString();
      final orderNumber = widget.isEditMode
          ? widget.existingOrder!.orderNumber
          : 'REQ-${nowStr.substring(nowStr.length - 6)}';

      final requestName = _nameController.text.trim();
      final remarkNotes = _notesController.text.trim();

      final orderModel = StitchingOrderModel(
        id: widget.isEditMode
            ? widget.existingOrder!.id
            : const Uuid().v4(),
        boutiqueId: 'boutique_01',
        branchId: 'branch_01',
        customerId: _selectedCustomerId!,
        customerName: customer.displayName,
        customerPhone: customer.phone,
        customerEmail: customer.email,
        orderNumber: orderNumber,
        status: widget.isEditMode
            ? widget.existingOrder!.status
            : StitchingOrderStatus.requested,
        requestName: requestName,
        categoryName: _selectedCategory,
        designReferences: [
          DesignReferenceModel(
            designName: requestName,
            quantity: 1,
            notes: _selectedCategory,
          ),
        ],
        notes: remarkNotes.isNotEmpty ? remarkNotes : null,
        expectedReadyAt: _pickupDate,
        createdAt: widget.isEditMode
            ? widget.existingOrder!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditMode) {
        await repo.updateOrder(orderModel);
      } else {
        await repo.createOrderWithHistory(
          order: orderModel,
          initialNote:
              'Request created for $requestName under $_selectedCategory.',
          createdBy: 'Admin',
        );
      }

      if (!mounted) return;

      AppToast.show(
        context,
        widget.isEditMode
            ? 'Stitching request updated successfully'
            : 'Stitching request created successfully',
        type: ToastType.success,
      );

      _allowDiscardPop = true;
      context.popOrGo(AppRoutes.adminStitchingOrderList);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        'Failed to save request: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final categoryList = categoriesAsync.valueOrNull ?? [];

    final categoryOptions = <String>{
      ..._defaultCategories,
      ...categoryList.map((c) => c.name),
    }.toList();

    final selectedCat = categoryOptions.contains(_selectedCategory)
        ? _selectedCategory
        : categoryOptions.first;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop()) {
          _allowDiscardPop = true;
          if (context.mounted) {
            context.popOrGo(AppRoutes.adminStitchingOrderList);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(
          title: widget.isEditMode
              ? 'Edit Stitching Request'
              : 'New Stitching Request',
          onBackTap: () async {
            if (await _onWillPop()) {
              _allowDiscardPop = true;
              if (context.mounted) {
                context.popOrGo(AppRoutes.adminStitchingOrderList);
              }
            }
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Card Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Selection Header Tile
                            _buildCustomerSection(),

                            const SizedBox(height: 16),
                            const Divider(
                              color: AppColors.surfaceBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 16),

                            // Request Name Field
                            Text(
                              'Request Name *',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. Royal Silk Anarkali Suit',
                                hintStyle: GoogleFonts.montserrat(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceLight,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSoft,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSoft,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter request name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Category Selection Field
                            Text(
                              'Category *',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: selectedCat,
                              icon: PhosphorIcon(
                                PhosphorIcons.caretDown(),
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              dropdownColor: AppColors.surface,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceLight,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSoft,
                                  ),
                                ),
                              ),
                              items: categoryOptions.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCategory = val;
                                    _hasChanges = true;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Pickup Date Tile
                            Text(
                              'Pickup Date * (Min 3 days, Max 1 month)',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _selectPickupDate,
                              borderRadius: AppRadius.borderMd,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: AppRadius.borderMd,
                                  border:
                                      Border.all(color: AppColors.borderSoft),
                                ),
                                child: Row(
                                  children: [
                                    PhosphorIcon(
                                      PhosphorIcons.calendarBlank(),
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _pickupDate != null
                                            ? '${DateFormat('EEE, dd MMM yyyy').format(_pickupDate!)}  (${_getPickupDelayText(_pickupDate!)})'
                                            : 'Select Pickup Date',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    PhosphorIcon(
                                      PhosphorIcons.pencilSimple(),
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Remark / Instructions Field
                            Text(
                              'Remark / Instructions (Optional)',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 4,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Add custom latkan preference, lining material, urgent event details...',
                                hintStyle: GoogleFonts.montserrat(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceLight,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSoft,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSoft,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Submit Button
                      _isSaving
                          ? const Center(child: AppLoadingIndicator())
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Update Request'
                                  : 'Submit Request',
                              onPressed: _saveRequest,
                            ),
                      const SizedBox(height: 24),
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

  Widget _buildCustomerSection() {
    if (widget.preselectedCustomer != null) {
      final pc = widget.preselectedCustomer!;
      final initials = pc.displayName
          .trim()
          .split(RegExp(r'\s+'))
          .map((e) => e.isNotEmpty ? e[0] : '')
          .take(2)
          .join()
          .toUpperCase();

      return Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceLight,
            backgroundImage:
                pc.photoUrl != null ? NetworkImage(pc.photoUrl!) : null,
            child: pc.photoUrl == null
                ? Text(
                    initials,
                    style: GoogleFonts.montserrat(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUSTOMER',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  pc.displayName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final selectedCust = _availableCustomers.any(
      (c) => (c.firebaseUid ?? c.id) == _selectedCustomerId,
    )
        ? _selectedCustomerId
        : (_availableCustomers.isNotEmpty
            ? (_availableCustomers.first.firebaseUid ?? _availableCustomers.first.id)
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Customer *',
          style: GoogleFonts.montserrat(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selectedCust,
          icon: PhosphorIcon(
            PhosphorIcons.caretDown(),
            size: 18,
            color: AppColors.textMuted,
          ),
          dropdownColor: AppColors.surface,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(
                color: AppColors.borderSoft,
              ),
            ),
          ),
          items: _availableCustomers.map((cust) {
            final id = cust.firebaseUid ?? cust.id;
            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                '${cust.displayName}${cust.phone != null ? ' (${cust.phone})' : ''}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCustomerId = val;
                _hasChanges = true;
              });
            }
          },
          validator: (val) => val == null ? 'Please select customer' : null,
        ),
      ],
    );
  }

  String _getPickupDelayText(DateTime pickupDate) {
    final diff = pickupDate.difference(DateTime.now()).inDays + 1;
    if (diff <= 3) return 'Urgent - 3 days delay';
    return 'Pickup in $diff days';
  }
}
