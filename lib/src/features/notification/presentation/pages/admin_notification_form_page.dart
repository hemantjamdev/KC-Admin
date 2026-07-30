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
  final NotificationAudienceType _audienceType =
      NotificationAudienceType.allBoutiqueCustomers;
  final List<String> _selectedCustomerIds = const [];

  final NotificationDestinationType _destinationType =
      NotificationDestinationType.none;
  final String? _selectedEntityId = null;

  DateTime? _expiresAt;

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      final n = widget.existingNotification!;
      _titleController.text = n.title;
      _bodyController.text = n.body;
      _type = n.type;
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
    setState(() {
      _hasChanges = true;
    });
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

                      // 2. Live Notification Preview Card
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
    return ListenableBuilder(
      listenable: Listenable.merge([_titleController, _bodyController]),
      builder: (context, _) {
        final titleText = _titleController.text.trim().isEmpty
            ? 'Notification Title Preview'
            : _titleController.text.trim();
        final bodyText = _bodyController.text.trim().isEmpty
            ? 'Notification message text will appear here as you type…'
            : _bodyController.text.trim();

        final (typeIcon, typeColor) = switch (_type) {
          NotificationType.general => (
              PhosphorIcons.bell(PhosphorIconsStyle.bold),
              AppColors.primary,
            ),
          NotificationType.stitchingUpdate => (
              PhosphorIcons.scissors(PhosphorIconsStyle.bold),
              const Color(0xFF10B981),
            ),
          NotificationType.designUpdate => (
              PhosphorIcons.sparkle(PhosphorIconsStyle.bold),
              const Color(0xFF2563EB),
            ),
          NotificationType.boutiqueAnnouncement => (
              PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
              const Color(0xFFD97706),
            ),
        };

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: typeColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: typeColor.withValues(alpha: 0.05),
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
                    color: typeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE CUSTOMER PREVIEW',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: typeColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'iOS / Android',
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: PhosphorIcon(
                          typeIcon,
                          color: Colors.white,
                          size: 20,
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
      },
    );
  }
}
