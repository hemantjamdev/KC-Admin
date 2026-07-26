import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/data/repositories/branch_firestore_repository.dart';
import '../../../boutique/domain/models/branch_model.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../../design/data/repositories/design_firestore_repository.dart';
import '../../../design/domain/models/design_model.dart';
import '../../../section/data/repositories/section_firestore_repository.dart';
import '../../../section/domain/models/section_model.dart';
import '../../../stitching/data/repositories/stitching_order_firestore_repository.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';
import '../../domain/models/notification_model.dart';
import '../controllers/notification_controller.dart';

enum DeliveryMode { publishNow, schedule, saveDraft }

/// Add / Edit Notification Form Page for KC-Admin.
class AdminNotificationFormPage extends StatefulWidget {
  const AdminNotificationFormPage({super.key, this.existingNotification});
  final NotificationModel? existingNotification;
  bool get isEditMode => existingNotification != null;

  @override
  State<AdminNotificationFormPage> createState() =>
      _AdminNotificationFormPageState();
}

class _AdminNotificationFormPageState extends State<AdminNotificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  NotificationType _type = NotificationType.general;
  NotificationAudienceType _audienceType =
      NotificationAudienceType.allBoutiqueCustomers;
  String? _selectedBranchId;
  final List<String> _selectedCustomerIds = [];

  NotificationDestinationType _destinationType =
      NotificationDestinationType.none;
  String? _selectedEntityId;

  DeliveryMode _deliveryMode = DeliveryMode.saveDraft;
  DateTime? _scheduledAt;
  DateTime? _expiresAt;

  bool _isSaving = false;
  bool _hasChanges = false;

  late NotificationController _controller;
  final CustomerRepositoryImpl _customerRepo = CustomerRepositoryImpl();
  final BranchFirestoreRepository _branchRepo = BranchFirestoreRepository();
  final DesignFirestoreRepository _designRepo = DesignFirestoreRepository();
  final SectionFirestoreRepository _sectionRepo = SectionFirestoreRepository();
  final StitchingOrderFirestoreRepository _orderRepo = StitchingOrderFirestoreRepository();

  List<CustomerModel> _availableCustomers = [];
  List<BranchModel> _availableBranches = [];
  List<DesignModel> _availableDesigns = [];
  List<SectionModel> _availableSections = [];
  List<StitchingOrderModel> _availableOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();

    if (widget.isEditMode) {
      final n = widget.existingNotification!;
      _titleController.text = n.title;
      _bodyController.text = n.body;
      _type = n.type;
      _audienceType = n.audienceType;
      _selectedBranchId = n.branchId;
      _selectedCustomerIds.addAll(n.customerIds);
      _destinationType =
          n.relatedEntityType ?? NotificationDestinationType.none;
      _selectedEntityId = n.relatedEntityId;
      _scheduledAt = n.scheduledAt;
      _expiresAt = n.expiresAt;

      if (n.status == NotificationStatus.published) {
        _deliveryMode = DeliveryMode.publishNow;
      } else if (n.status == NotificationStatus.scheduled) {
        _deliveryMode = DeliveryMode.schedule;
      } else {
        _deliveryMode = DeliveryMode.saveDraft;
      }
    }

    _titleController.addListener(_markDirty);
    _bodyController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadCustomers() async {
    try {
      final list = await _customerRepo.getCustomersForAdmin();
      if (!mounted) return;
      setState(() => _availableCustomers = list);
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    _controller = NotificationController(
      boutiqueId: boutiqueId,
      branchId: scope.selectedBranch?.id,
    );
    _loadMetadata(boutiqueId);
  }

  Future<void> _loadMetadata(String boutiqueId) async {
    try {
      final branches = await _branchRepo.getBranchesForBoutique(boutiqueId);
      final designs = await _designRepo.watchDesigns(boutiqueId).first;
      final sections = await _sectionRepo.watchSections(boutiqueId).first;
      final orders = await _orderRepo.watchAdminOrders(boutiqueId, null).first;
      if (!mounted) return;
      setState(() {
        _availableBranches = branches;
        _availableDesigns = designs;
        _availableSections = sections;
        _availableOrders = orders;
      });
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
          'Unsaved notification details will be lost.',
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

    // Audience validation
    if (_audienceType == NotificationAudienceType.branchCustomers &&
        _selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a branch for this audience.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    if (_audienceType == NotificationAudienceType.selectedCustomers &&
        _selectedCustomerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one customer for this audience.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    // Schedule validation
    if (_deliveryMode == DeliveryMode.schedule && _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a future date/time for scheduling.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }

    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final router = GoRouter.of(context);

    // Publish confirmation dialog
    if (_deliveryMode == DeliveryMode.publishNow) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          title: const Text(
            'Publish Notification?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Publish "${_titleController.text.trim()}" now into the customer app? Published notifications cannot be edited.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Publish',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();

    NotificationStatus initialStatus = NotificationStatus.draft;
    DateTime? pubAt;

    if (_deliveryMode == DeliveryMode.publishNow) {
      initialStatus = NotificationStatus.published;
      pubAt = now;
    } else if (_deliveryMode == DeliveryMode.schedule) {
      initialStatus = NotificationStatus.scheduled;
    }

    try {
      if (widget.isEditMode) {
        final existing = widget.existingNotification!;
        final updated = existing.copyWith(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          type: _type,
          audienceType: _audienceType,
          branchId: _selectedBranchId,
          customerIds: _selectedCustomerIds,
          relatedEntityType: _destinationType,
          relatedEntityId: _selectedEntityId,
          status: initialStatus,
          scheduledAt: _scheduledAt,
          publishedAt: pubAt,
          expiresAt: _expiresAt,
          updatedAt: now,
          updatedBy: 'admin',
        );
        await _controller.updateNotification(updated);
      } else {
        final newNotif = NotificationModel(
          id: const Uuid().v4(),
          boutiqueId: boutiqueId,
          branchId: _selectedBranchId,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          type: _type,
          audienceType: _audienceType,
          customerIds: _selectedCustomerIds,
          relatedEntityType: _destinationType,
          relatedEntityId: _selectedEntityId,
          status: initialStatus,
          scheduledAt: _scheduledAt,
          publishedAt: pubAt,
          expiresAt: _expiresAt,
          createdAt: now,
          updatedAt: now,
          createdBy: 'admin',
          updatedBy: 'admin',
        );
        await _controller.createNotification(newNotif);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Notification updated.'
                : 'Notification created.',
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      router.go(AppRoutes.adminNotificationList);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save notification. Please try again.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
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
        if (canLeave) router.go(AppRoutes.adminNotificationList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Notification' : 'Create Notification',
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
              if (canLeave) router.go(AppRoutes.adminNotificationList);
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
                      // Title
                      _field(
                        'Notification Title *',
                        TextFormField(
                          controller: _titleController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec(
                            'e.g. New Bridal Collection Arrived!',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Title is required.';
                            }
                            if (v.trim().length < 3) {
                              return 'Title must be at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Body
                      _field(
                        'Notification Message *',
                        TextFormField(
                          controller: _bodyController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          maxLines: 3,
                          decoration: _dec(
                            'Enter notification message for customers…',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Message is required.';
                            }
                            if (v.trim().length < 5) {
                              return 'Message must be at least 5 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Type Selector
                      _field(
                        'Notification Type *',
                        DropdownButtonFormField<NotificationType>(
                          initialValue: _type,
                          dropdownColor: AppColors.surfaceLight,
                          style: _fieldStyle,
                          decoration: _dec('Select type'),
                          items: NotificationType.values.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _type = v;
                                _hasChanges = true;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Audience Selector
                      _audienceSection(),
                      const SizedBox(height: AppSpacing.md),

                      // Destination Selector
                      _destinationSection(),
                      const SizedBox(height: AppSpacing.md),

                      // Delivery Mode
                      _deliveryModeSection(),
                      const SizedBox(height: AppSpacing.xl),

                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: _deliveryMode == DeliveryMode.publishNow
                                  ? 'Publish Notification'
                                  : (_deliveryMode == DeliveryMode.schedule
                                        ? 'Schedule Notification'
                                        : 'Save as Draft'),
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

  Widget _audienceSection() {
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
            'Audience Targeting *',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<NotificationAudienceType>(
            initialValue: _audienceType,
            dropdownColor: AppColors.surfaceLight,
            style: _fieldStyle,
            decoration: _dec('Select audience'),
            items: NotificationAudienceType.values.map((a) {
              return DropdownMenuItem(value: a, child: Text(a.label));
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _audienceType = v;
                  _hasChanges = true;
                });
              }
            },
          ),
          if (_audienceType == NotificationAudienceType.branchCustomers) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedBranchId,
              dropdownColor: AppColors.surfaceLight,
              style: _fieldStyle,
              decoration: _dec('Select Branch'),
              items: _availableBranches.map((b) {
                return DropdownMenuItem(value: b.id, child: Text(b.name));
              }).toList(),
              onChanged: (v) => setState(() {
                _selectedBranchId = v;
                _hasChanges = true;
              }),
            ),
          ],
          if (_audienceType == NotificationAudienceType.selectedCustomers) ...[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Select Customers:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ..._availableCustomers.map((c) {
              final isChecked = _selectedCustomerIds.contains(c.id);
              return CheckboxListTile(
                value: isChecked,
                title: Text(
                  c.displayName,
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
                      _selectedCustomerIds.add(c.id);
                    } else {
                      _selectedCustomerIds.remove(c.id);
                    }
                    _hasChanges = true;
                  });
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _destinationSection() {
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
            'Destination Link',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<NotificationDestinationType>(
            initialValue: _destinationType,
            dropdownColor: AppColors.surfaceLight,
            style: _fieldStyle,
            decoration: _dec('Select destination'),
            items: NotificationDestinationType.values.map((d) {
              return DropdownMenuItem(value: d, child: Text(d.label));
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _destinationType = v;
                  _selectedEntityId = null;
                  _hasChanges = true;
                });
              }
            },
          ),
          if (_destinationType == NotificationDestinationType.design) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedEntityId,
              dropdownColor: AppColors.surfaceLight,
              style: _fieldStyle,
              decoration: _dec('Select Design'),
              items: _availableDesigns.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(d.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) => setState(() {
                _selectedEntityId = v;
                _hasChanges = true;
              }),
            ),
          ],
          if (_destinationType == NotificationDestinationType.section) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedEntityId,
              dropdownColor: AppColors.surfaceLight,
              style: _fieldStyle,
              decoration: _dec('Select Section'),
              items: _availableSections.map((s) {
                return DropdownMenuItem(
                  value: s.id,
                  child: Text(s.title, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) => setState(() {
                _selectedEntityId = v;
                _hasChanges = true;
              }),
            ),
          ],
          if (_destinationType ==
              NotificationDestinationType.stitchingOrder) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedEntityId,
              dropdownColor: AppColors.surfaceLight,
              style: _fieldStyle,
              decoration: _dec('Select Stitching Order'),
              items: _availableOrders.map((o) {
                return DropdownMenuItem(
                  value: o.id,
                  child: Text(
                    '${o.orderNumber} (Cust #${o.customerId})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() {
                _selectedEntityId = v;
                _hasChanges = true;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _deliveryModeSection() {
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
            'Delivery Mode',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          RadioListTile<DeliveryMode>(
            value: DeliveryMode.publishNow,
            groupValue: _deliveryMode,
            title: const Text(
              'Publish Immediately',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            activeColor: AppColors.primary,
            dense: true,
            onChanged: (v) => setState(() {
              _deliveryMode = v!;
              _hasChanges = true;
            }),
          ),
          RadioListTile<DeliveryMode>(
            value: DeliveryMode.schedule,
            groupValue: _deliveryMode,
            title: const Text(
              'Schedule for Future Date/Time',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            activeColor: AppColors.primary,
            dense: true,
            onChanged: (v) => setState(() {
              _deliveryMode = v!;
              _hasChanges = true;
            }),
          ),
          if (_deliveryMode == DeliveryMode.schedule) ...[
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  Text(
                    _scheduledAt == null
                        ? 'No schedule date set'
                        : 'Scheduled: ${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _scheduledAt ??
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                      );
                      if (picked != null) {
                        setState(() {
                          _scheduledAt = picked;
                          _hasChanges = true;
                        });
                      }
                    },
                    child: const Text('Pick Schedule Date'),
                  ),
                ],
              ),
            ),
          ],
          RadioListTile<DeliveryMode>(
            value: DeliveryMode.saveDraft,
            groupValue: _deliveryMode,
            title: const Text(
              'Save as Draft',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            activeColor: AppColors.primary,
            dense: true,
            onChanged: (v) => setState(() {
              _deliveryMode = v!;
              _hasChanges = true;
            }),
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
