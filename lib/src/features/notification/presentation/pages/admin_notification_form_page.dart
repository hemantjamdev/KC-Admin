// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../customer/application/providers/customer_providers.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../../section/application/providers/section_providers.dart';
import '../../../section/domain/models/section_model.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';
import '../../domain/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/notification_providers.dart';

/// Add / Edit Notification Form Page for KC-Admin.
class AdminNotificationFormPage extends ConsumerStatefulWidget {
  const AdminNotificationFormPage({super.key, this.existingNotification});
  final NotificationModel? existingNotification;
  bool get isEditMode => existingNotification != null;

  @override
  ConsumerState<AdminNotificationFormPage> createState() =>
      _AdminNotificationFormPageState();
}

class _AdminNotificationFormPageState
    extends ConsumerState<AdminNotificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _bodyFocusNode = FocusNode();

  NotificationType _type = NotificationType.general;
  NotificationAudienceType _audienceType =
      NotificationAudienceType.allBoutiqueCustomers;
  final List<String> _selectedCustomerIds = [];

  NotificationDestinationType _destinationType =
      NotificationDestinationType.none;
  String? _selectedEntityId;

  DateTime? _expiresAt;

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  List<CustomerModel> _availableCustomers = [];
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
      _selectedCustomerIds.addAll(n.customerIds);
      _destinationType =
          n.relatedEntityType ?? NotificationDestinationType.none;
      _selectedEntityId = n.relatedEntityId;
      _expiresAt = n.expiresAt;
    }

    _titleController.addListener(_markDirty);
    _bodyController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadCustomers() async {
    try {
      final repo = ref.read(customerRepositoryProvider);
      final list = await repo.getCustomersForAdmin();
      if (!mounted) return;
      setState(() => _availableCustomers = list);
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    const boutiqueId = 'boutique_01';
    _loadMetadata(boutiqueId);
  }

  Future<void> _loadMetadata(String boutiqueId) async {
    try {
      final designs = await ref.read(designRepositoryProvider).watchDesigns(boutiqueId).first;
      final sections = await ref.read(sectionRepositoryProvider).watchSections(boutiqueId).first;
      final orders = await ref.read(stitchingRepositoryProvider).watchAdminOrders(boutiqueId, null).first;
      if (!mounted) return;
      setState(() {
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

    if (_audienceType == NotificationAudienceType.selectedCustomers &&
        _selectedCustomerIds.isEmpty) {
      AppToast.show(
        context,
        'Please select at least one customer for this audience.',
        type: ToastType.warning,
      );
      return;
    }

    const boutiqueId = 'boutique_01';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(
          widget.isEditMode ? 'Update Notification?' : 'Publish Notification?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Publish "${_titleController.text.trim()}" now into the customer app?',
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
            child: Text(
              widget.isEditMode ? 'Update' : 'Publish',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();

    final initialStatus = NotificationStatus.published;
    final pubAt = now;

    try {
      if (widget.isEditMode) {
        final existing = widget.existingNotification!;
        final updated = existing.copyWith(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          type: _type,
          audienceType: _audienceType,
          customerIds: _selectedCustomerIds,
          relatedEntityType: _destinationType,
          relatedEntityId: _selectedEntityId,
          status: initialStatus,
          publishedAt: pubAt,
          expiresAt: _expiresAt,
          updatedAt: now,
          updatedBy: 'admin',
        );
        await ref
            .read(adminNotificationMutationProvider.notifier)
            .update(updated);
      } else {
        final newNotif = NotificationModel(
          id: const Uuid().v4(),
          boutiqueId: boutiqueId,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          type: _type,
          audienceType: _audienceType,
          customerIds: _selectedCustomerIds,
          relatedEntityType: _destinationType,
          relatedEntityId: _selectedEntityId,
          status: initialStatus,
          publishedAt: pubAt,
          expiresAt: _expiresAt,
          createdAt: now,
          updatedAt: now,
          createdBy: 'admin',
          updatedBy: 'admin',
        );
        await ref
            .read(adminNotificationMutationProvider.notifier)
            .create(newNotif);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        widget.isEditMode ? 'Notification updated.' : 'Notification created.',
        type: ToastType.success,
      );
      context.popOrGoWithResult(true, AppRoutes.adminNotificationList);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        'Failed to save notification. Please try again.',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges || _allowDiscardPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _onWillPop();
        if (canLeave && context.mounted) {
          setState(() => _allowDiscardPop = true);
          context.popOrGo(AppRoutes.adminNotificationList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(
          title: widget.isEditMode
              ? 'Edit Notification'
              : 'Create Notification',
          onBackTap: () async {
            if (!_hasChanges) {
              context.popOrGo(AppRoutes.adminNotificationList);
              return;
            }
            final pop = await _onWillPop();
            if (pop && context.mounted) {
              _allowDiscardPop = true;
              context.popOrGo(AppRoutes.adminNotificationList);
            }
          },
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
                      // 1. Content Card
                      _formCard(
                        title: 'Notification Content',
                        icon: PhosphorIcons.megaphone(),
                        children: [
                          _field(
                            'Notification Title *',
                            TextFormField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_bodyFocusNode),
                              style: _fieldStyle,
                              cursorColor: AppColors.primary,
                              decoration: _dec(
                                'e.g. New Festive Collection Arrived!',
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
                          _field(
                            'Notification Message *',
                            TextFormField(
                              controller: _bodyController,
                              focusNode: _bodyFocusNode,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
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
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 2. Audience Selector Card
                      _audienceSection(),
                      const SizedBox(height: AppSpacing.md),

                      // 3. Destination Selector Card
                      _destinationSection(),
                      const SizedBox(height: AppSpacing.md),

                      // 4. Live Notification Preview Card
                      _buildLivePreviewCard(),
                      const SizedBox(height: AppSpacing.md),

                      const SizedBox(height: AppSpacing.xl),

                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Update Notification'
                                  : 'Publish Notification',
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
    return _formCard(
      title: 'Audience Targeting',
      icon: PhosphorIcons.usersThree(),
      children: [
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

        if (_audienceType == NotificationAudienceType.selectedCustomers) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select Target Customers:',
            style: GoogleFonts.montserrat(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ..._availableCustomers.map((c) {
            final targetUid =
                (c.firebaseUid != null && c.firebaseUid!.isNotEmpty)
                ? c.firebaseUid!
                : c.id;
            final isChecked =
                _selectedCustomerIds.contains(targetUid) ||
                _selectedCustomerIds.contains(c.id);
            return CheckboxListTile(
              value: isChecked,
              title: Text(
                c.displayName,
                style: GoogleFonts.montserrat(
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
                    _selectedCustomerIds.add(targetUid);
                    if (c.id != targetUid) {
                      _selectedCustomerIds.add(c.id);
                    }
                  } else {
                    _selectedCustomerIds.remove(targetUid);
                    _selectedCustomerIds.remove(c.id);
                  }
                  _hasChanges = true;
                });
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _destinationSection() {
    return _formCard(
      title: 'In-App Destination Link',
      icon: PhosphorIcons.link(),
      children: [
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
            isExpanded: true,
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
            isExpanded: true,
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
            isExpanded: true,
            dropdownColor: AppColors.surfaceLight,
            style: _fieldStyle,
            decoration: _dec('Select Stitching Order'),
            items: _availableOrders.map((o) {
              return DropdownMenuItem(
                value: o.id,
                child: Text(
                  '${o.orderNumber} (${o.displayRequestName})',
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
    );
  }



  Widget _formCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
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

  Widget _buildLivePreviewCard() {
    final titleText = _titleController.text.trim().isEmpty
        ? 'Notification Title Preview'
        : _titleController.text.trim();
    final bodyText = _bodyController.text.trim().isEmpty
        ? 'Notification message text will appear here as you type…'
        : _bodyController.text.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.deviceMobile(),
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE CUSTOMER PREVIEW',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'iOS / Android',
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kapada Creation',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'now',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        titleText,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bodyText,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
