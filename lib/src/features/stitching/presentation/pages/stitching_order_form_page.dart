import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../../design/data/repositories/design_firestore_repository.dart';
import '../../../design/domain/models/design_model.dart';
import '../../domain/models/stitching_order_model.dart';
import '../controllers/stitching_order_controller.dart';

/// Add / Edit Stitching Order Form Page.
class StitchingOrderFormPage extends StatefulWidget {
  const StitchingOrderFormPage({super.key, this.existingOrder});
  final StitchingOrderModel? existingOrder;
  bool get isEditMode => existingOrder != null;

  @override
  State<StitchingOrderFormPage> createState() => _StitchingOrderFormPageState();
}

class _StitchingOrderFormPageState extends State<StitchingOrderFormPage> {
  final DesignFirestoreRepository _designRepository = DesignFirestoreRepository();
  List<DesignModel> _availableDesigns = [];
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // Measurement controllers
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _sleeveLengthController = TextEditingController();
  final _garmentLengthController = TextEditingController();
  final _inseamController = TextEditingController();
  String _measurementUnit = 'in';

  final CustomerRepositoryImpl _customerRepo = CustomerRepositoryImpl();
  List<CustomerModel> _availableCustomers = [];
  String? _selectedCustomerId;

  List<DesignReferenceModel> _designReferences = [];
  DateTime? _expectedReadyAt;
  StitchingOrderStatus _status = StitchingOrderStatus.received;

  bool _isSaving = false;
  bool _hasChanges = false;
  late StitchingOrderController _controller;

  @override
  void initState() {
    super.initState();
    _loadCustomers();

    if (widget.isEditMode) {
      final o = widget.existingOrder!;
      _selectedCustomerId = o.customerId;
      _orderNumberController.text = o.orderNumber;
      _notesController.text = o.notes ?? '';
      _status = o.status;
      _expectedReadyAt = o.expectedReadyAt;
      _designReferences = List.from(o.designReferences);

      if (o.measurementSummary != null) {
        final m = o.measurementSummary!;
        _chestController.text = m.chest?.toString() ?? '';
        _waistController.text = m.waist?.toString() ?? '';
        _hipController.text = m.hip?.toString() ?? '';
        _shoulderController.text = m.shoulder?.toString() ?? '';
        _sleeveLengthController.text = m.sleeveLength?.toString() ?? '';
        _garmentLengthController.text = m.garmentLength?.toString() ?? '';
        _inseamController.text = m.inseam?.toString() ?? '';
        _measurementUnit = m.unit;
      }
    } else {
      final nowStr = DateTime.now().millisecondsSinceEpoch.toString();
      _orderNumberController.text =
          'KC-ORD-${nowStr.substring(nowStr.length - 4)}';
      _designReferences.add(
        const DesignReferenceModel(
          designId: 'design_01',
          designName: 'Royal Velvet Bridal Lehenga',
          quantity: 1,
        ),
      );
    }

    _orderNumberController.addListener(_markDirty);
    _notesController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadCustomers() async {
    try {
      final list = await _customerRepo.getCustomersForAdmin();
      if (!mounted) return;
      setState(() {
        _availableCustomers = list;
        if (!widget.isEditMode && list.isNotEmpty) {
          _selectedCustomerId = list.first.id;
        }
      });
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    _controller = StitchingOrderController(
      boutiqueId: boutiqueId,
      branchId: scope.selectedBranch?.id,
    );
    _loadDesigns(boutiqueId);
  }

  Future<void> _loadDesigns(String boutiqueId) async {
    try {
      final list = await _designRepository.watchDesigns(boutiqueId).first;
      if (!mounted) return;
      setState(() => _availableDesigns = list);
    } catch (_) {}
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
          'Unsaved order details will be lost.',
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

  void _addDesignReference() {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = '';
        int qty = 1;
        String? selectedDesignId = _availableDesigns.isNotEmpty ? _availableDesigns.first.id : null;

        return StatefulBuilder(
          builder: (context, setDlgState) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderLg,
            ),
            title: const Text(
              'Add Design Reference',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: selectedDesignId,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Catalogue Design or Custom',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Custom Design'),
                      ),
                      ..._availableDesigns.map(
                        (d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(d.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setDlgState(() {
                        selectedDesignId = val;
                        if (val != null) {
                          name = _availableDesigns
                              .firstWhere((d) => d.id == val)
                              .name;
                        }
                      });
                    },
                  ),
                  if (selectedDesignId == null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter custom design name',
                      ),
                      onChanged: (val) => name = val,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () {
                  final finalName = selectedDesignId != null
                      ? _availableDesigns
                            .firstWhere((d) => d.id == selectedDesignId)
                            .name
                      : name;
                  if (finalName.trim().isEmpty) return;

                  final thumb = selectedDesignId != null
                      ? _availableDesigns
                            .firstWhere((d) => d.id == selectedDesignId)
                            .thumbnailUrl
                      : null;

                  setState(() {
                    _designReferences.add(
                      DesignReferenceModel(
                        designId: selectedDesignId,
                        designName: finalName.trim(),
                        thumbnailUrl: thumb,
                        quantity: qty,
                      ),
                    );
                    _hasChanges = true;
                  });
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer for this order.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    if (_designReferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one design reference.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id ?? 'branch_01';
    final router = GoRouter.of(context);

    // Build measurement summary
    final chest = double.tryParse(_chestController.text.trim());
    final waist = double.tryParse(_waistController.text.trim());
    final hip = double.tryParse(_hipController.text.trim());
    final shoulder = double.tryParse(_shoulderController.text.trim());
    final sleeve = double.tryParse(_sleeveLengthController.text.trim());
    final garment = double.tryParse(_garmentLengthController.text.trim());
    final inseam = double.tryParse(_inseamController.text.trim());

    final MeasurementSummaryModel? measurements =
        (chest != null ||
            waist != null ||
            hip != null ||
            shoulder != null ||
            sleeve != null ||
            garment != null ||
            inseam != null)
        ? MeasurementSummaryModel(
            chest: chest,
            waist: waist,
            hip: hip,
            shoulder: shoulder,
            sleeveLength: sleeve,
            garmentLength: garment,
            inseam: inseam,
            unit: _measurementUnit,
          )
        : null;

    final now = DateTime.now();

    try {
      if (widget.isEditMode) {
        final existing = widget.existingOrder!;
        final updated = existing.copyWith(
          customerId: _selectedCustomerId,
          orderNumber: _orderNumberController.text.trim(),
          status: _status,
          designReferences: _designReferences,
          measurementSummary: measurements,
          clearMeasurementSummary: measurements == null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          clearNotes: _notesController.text.trim().isEmpty,
          expectedReadyAt: _expectedReadyAt,
          clearExpectedReadyAt: _expectedReadyAt == null,
          updatedAt: now,
          updatedBy: 'admin',
        );
        await _controller.updateOrder(updated);
      } else {
        final newOrder = StitchingOrderModel(
          id: const Uuid().v4(),
          boutiqueId: boutiqueId,
          branchId: branchId,
          customerId: _selectedCustomerId!,
          orderNumber: _orderNumberController.text.trim(),
          status: _status,
          designReferences: _designReferences,
          measurementSummary: measurements,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          expectedReadyAt: _expectedReadyAt,
          createdAt: now,
          updatedAt: now,
          createdBy: 'admin',
          updatedBy: 'admin',
        );
        await _controller.createOrder(newOrder);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Order ${_orderNumberController.text} updated.'
                : 'Order ${_orderNumberController.text} created.',
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      router.go(AppRoutes.adminStitchingOrderList);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save order. Please try again.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _notesController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _shoulderController.dispose();
    _sleeveLengthController.dispose();
    _garmentLengthController.dispose();
    _inseamController.dispose();
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
        if (canLeave) router.go(AppRoutes.adminStitchingOrderList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Order' : 'Add Stitching Order',
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
              if (canLeave) router.go(AppRoutes.adminStitchingOrderList);
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
                      // Customer Dropdown
                      _field(
                        'Select Customer *',
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCustomerId,
                          dropdownColor: AppColors.surfaceLight,
                          style: _fieldStyle,
                          decoration: _dec('Select customer'),
                          items: _availableCustomers.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                '${c.displayName}${c.phone != null ? ' (${c.phone})' : ''}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() {
                            _selectedCustomerId = v;
                            _hasChanges = true;
                          }),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Order Number
                      _field(
                        'Order Number *',
                        TextFormField(
                          controller: _orderNumberController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('e.g. KC-AHD-2026-0001'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Order number is required.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Design References List
                      _designReferencesSection(),
                      const SizedBox(height: AppSpacing.md),

                      // Measurement Editor
                      _measurementEditorSection(),
                      const SizedBox(height: AppSpacing.md),

                      // Expected Ready Date Picker
                      _datePickerSection(),
                      const SizedBox(height: AppSpacing.md),

                      // Notes
                      _field(
                        'General Notes (Optional)',
                        TextFormField(
                          controller: _notesController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          maxLines: 3,
                          decoration: _dec(
                            'e.g. Special lining requests, urgent delivery',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Save Order'
                                  : 'Create Order',
                              onPressed: _save,
                            ),
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

  Widget _designReferencesSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Design References *',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Design', style: TextStyle(fontSize: 12)),
                onPressed: _addDesignReference,
              ),
            ],
          ),
          if (_designReferences.isEmpty)
            const Text(
              'No design references added yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _designReferences.length,
              separatorBuilder: (_, _) => const Divider(
                color: AppColors.surfaceBorder,
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, i) {
                final item = _designReferences[i];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.designName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${item.isCustom ? 'Custom Pattern' : 'Catalogue Design'} • Qty: ${item.quantity}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _designReferences.removeAt(i);
                          _hasChanges = true;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _measurementEditorSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Body & Garment Measurements',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: _measurementUnit,
                dropdownColor: AppColors.surfaceLight,
                style: const TextStyle(color: AppColors.primary, fontSize: 12),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'in', child: Text('Inches (in)')),
                  DropdownMenuItem(
                    value: 'cm',
                    child: Text('Centimeters (cm)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _measurementUnit = v;
                      _hasChanges = true;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _measInput('Chest', _chestController)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _measInput('Waist', _waistController)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _measInput('Hip', _hipController)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _measInput('Shoulder', _shoulderController)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _measInput('Sleeve', _sleeveLengthController)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _measInput('Length', _garmentLengthController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _measInput(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
    );
  }

  Widget _datePickerSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expected Ready Date',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _expectedReadyAt == null
                      ? 'No date set'
                      : '${_expectedReadyAt!.day}/${_expectedReadyAt!.month}/${_expectedReadyAt!.year}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    _expectedReadyAt ??
                    DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 180)),
              );
              if (picked != null) {
                setState(() {
                  _expectedReadyAt = picked;
                  _hasChanges = true;
                });
              }
            },
            child: const Text('Pick Date'),
          ),
        ],
      ),
    );
  }

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
  );
}
