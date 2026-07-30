import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/media/image_upload_service.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../application/providers/shop_profile_providers.dart';
import '../../domain/models/shop_profile_model.dart';

/// Form screen to edit the single Kapada Creation studio profile details.
class ShopProfileFormPage extends ConsumerStatefulWidget {
  const ShopProfileFormPage({super.key});

  @override
  ConsumerState<ShopProfileFormPage> createState() =>
      _ShopProfileFormPageState();
}

class _ShopProfileFormPageState extends ConsumerState<ShopProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  final _nameFocusNode = FocusNode();
  final _subtitleFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  String? _logoUrl;

  // Per-Day Custom Operating Hours Map
  late Map<String, DayOperatingSchedule> _dailySchedules;

  bool _isSaving = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  final ImageUploadService _uploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(shopProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _subtitleController = TextEditingController(text: profile.subtitle);
    _phoneController = TextEditingController(text: profile.phone ?? '');
    _emailController = TextEditingController(text: profile.email ?? '');
    _addressController = TextEditingController(text: profile.address ?? '');
    _logoUrl = profile.logoUrl;

    // Init per-day operating schedules
    final existingHours =
        profile.operatingHours ?? OperatingHoursModel.defaultSchedule;
    _dailySchedules = Map<String, DayOperatingSchedule>.from(
      existingHours.dailySchedules,
    );

    // Rebuild live preview when form values change
    void updatePreview() => setState(() {});
    _nameController.addListener(updatePreview);
    _subtitleController.addListener(updatePreview);
    _phoneController.addListener(updatePreview);
    _addressController.addListener(updatePreview);
    _emailController.addListener(updatePreview);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _nameController.dispose();
    _subtitleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final isAm = clean.endsWith('AM');
      final parts = clean
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim()
          .split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  OperatingHoursModel _buildOperatingHoursModel() {
    return OperatingHoursModel(dailySchedules: _dailySchedules);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final current = ref.read(shopProfileProvider);
      final opHoursModel = _buildOperatingHoursModel();

      final updated = current.copyWith(
        name: _nameController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        openingHours: opHoursModel.summary,
        operatingHours: opHoursModel,
        logoUrl: _logoUrl,
      );

      await ref.read(shopProfileRepositoryProvider).updateShopProfile(updated);

      if (mounted) {
        AppToast.show(
          context,
          'Studio profile & per-day operating hours updated successfully.',
          type: ToastType.success,
        );
        context.popOrGo(AppRoutes.adminProfile);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Failed to update studio profile.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminProfile);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => context.popOrGo(AppRoutes.adminProfile),
          ),
          title: Text(
            'Edit Studio Profile',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LIVE CUSTOMER VIEW PREVIEW CARD ─────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFEBE4D8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.sparkle(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'KAPADA CREATION INFO',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  PhosphorIcon(
                                    PhosphorIcons.eye(),
                                    size: 11,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Live Preview',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameController.text.trim().isNotEmpty
                                        ? _nameController.text.trim()
                                        : 'Kapada Creation',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Est. 2015',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _subtitleController.text.trim().isNotEmpty
                                        ? _subtitleController.text.trim()
                                        : 'Luxury Bespoke Designer Apparel & Custom Tailoring',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12.5,
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.mapPin(),
                                        size: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          _addressController.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? _addressController.text.trim()
                                              : 'Main Market, M.G. Road, Jaipur, Rajasthan 302001',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.phone(),
                                        size: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _phoneController.text.trim().isNotEmpty
                                            ? _phoneController.text.trim()
                                            : '+91 98765 43210',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () => _showWorkingHoursBottomSheet(
                                      context,
                                    ),
                                    child: Row(
                                      children: [
                                        PhosphorIcon(
                                          PhosphorIcons.clock(),
                                          size: 12,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Working Hours',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        PhosphorIcon(
                                          PhosphorIcons.info(PhosphorIconsStyle.fill),
                                          size: 14,
                                          color: const Color(0xFFD97706),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _logoUrl != null && _logoUrl!.isNotEmpty
                                  ? Image.network(
                                      _logoUrl!,
                                      width: 58,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _fallbackImage(),
                                    )
                                  : _fallbackImage(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── BOUTIQUE PHOTO & FEATURE IMAGE ────────────────
                  Text(
                    'Boutique Photo & Feature Image',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildImageUploadSection(),

                  const SizedBox(height: 20),

                  // ── STUDIO NAME (Max 50 Chars) ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Studio Name *',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_nameController.text.length}/50',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    maxLength: 50,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_subtitleFocusNode),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Studio name is required'
                        : null,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Kapada Creation Studio',
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── TAGLINE / SHORT TITLE (Max 50 Chars) ────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tagline / Short Title',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_subtitleController.text.length}/50',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _subtitleController,
                    focusNode: _subtitleFocusNode,
                    maxLength: 50,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_addressFocusNode),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Luxury Bespoke Designer Apparel',
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── STUDIO ADDRESS (Max 150 Chars) ──────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Studio Address',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_addressController.text.length}/150',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    maxLength: 150,
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_phoneFocusNode),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'e.g. Main Market, M.G. Road, Jaipur, Rajasthan 302001',
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── PHONE NUMBER (STACKED VERTICALLY IN COLUMN) ────
                  Text(
                    'Phone Number',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocusNode),
                    decoration: const InputDecoration(
                      hintText: 'e.g. +91 98765 43210',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── EMAIL ADDRESS (STACKED VERTICALLY IN COLUMN) ────
                  Text(
                    'Email Address',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'e.g. contact@kapadacreation.com',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── PER-DAY CUSTOM WORKING HOURS ENGINE ─────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.clock(PhosphorIconsStyle.fill),
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Studio Working Hours (Per Day)',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Toggle open days & customize individual timings per day',
                          style: GoogleFonts.montserrat(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List of all 7 days with custom time pickers
                        ...OperatingHoursModel.allWeekDays.map((day) {
                          final sched =
                              _dailySchedules[day] ??
                              DayOperatingSchedule(
                                day: day,
                                isOpen: day != 'Sunday',
                              );
                          return _buildDayScheduleTile(day, sched);
                        }),
                      ],
                    ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save Studio Profile',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Image.network(
      'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=500&auto=format&fit=crop&q=60',
      width: 58,
      height: 72,
      fit: BoxFit.cover,
    );
  }

  Widget _buildDayScheduleTile(String day, DayOperatingSchedule sched) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: sched.isOpen
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: sched.isOpen
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.surfaceBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: sched.isOpen,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _dailySchedules[day] = sched.copyWith(
                        isOpen: val == true,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                day,
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: sched.isOpen
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (sched.isOpen) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final tod =
                          _parseTimeOfDay(sched.openTime) ??
                          const TimeOfDay(hour: 10, minute: 0);
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: tod,
                      );
                      if (picked != null) {
                        setState(() {
                          _dailySchedules[day] = sched.copyWith(
                            openTime: _formatTimeOfDay(picked),
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.sun(),
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Open: ${sched.openTime}',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final tod =
                          _parseTimeOfDay(sched.closeTime) ??
                          const TimeOfDay(hour: 20, minute: 30);
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: tod,
                      );
                      if (picked != null) {
                        setState(() {
                          _dailySchedules[day] = sched.copyWith(
                            closeTime: _formatTimeOfDay(picked),
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.moon(),
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Close: ${sched.closeTime}',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_logoUrl != null && _logoUrl!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _logoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Feature Photo Uploaded',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  onPressed: () => setState(() => _logoUrl = null),
                ),
              ],
            ),
          ),

        if (_isUploadingImage) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceBorder,
          ),
          const SizedBox(height: 8),
        ],

        // Upload Image Button (Opens Bottom Sheet - Secondary Outlined Styling)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isUploadingImage
                ? null
                : () => _showImageSourceBottomSheet(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            icon: PhosphorIcon(
              PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold),
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              'Upload Image',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle indicator bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Header
                Text(
                  'Upload Feature Image',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select image source for boutique feature photo',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),

                // Camera Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.camera(),
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Take a photo using device camera',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),

                const Divider(height: 1, color: AppColors.surfaceBorder),

                // Gallery Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.image(),
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Choose an existing photo from gallery',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final file = await _uploadService.pickImage(source: source);
      if (file == null) return;

      setState(() {
        _isUploadingImage = true;
        _uploadProgress = 0.1;
      });

      final result = await _uploadService.uploadImage(
        file: File(file.path),
        storagePath:
            'shop_profile/logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      setState(() {
        _logoUrl = result.downloadUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        AppToast.show(
          context,
          'Image uploaded successfully.',
          type: ToastType.success,
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        AppToast.show(
          context,
          'Failed to upload image.',
          type: ToastType.error,
        );
      }
    }
  }

  void _showWorkingHoursBottomSheet(BuildContext ctx) {
    final opHours = _buildOperatingHoursModel();
    final isOpenNow = opHours.isCurrentlyOpen();

    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle indicator
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title + Live Status Badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Studio Working Hours',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _nameController.text.trim().isNotEmpty
                                ? _nameController.text.trim()
                                : 'Kapada Creation Studio',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isOpenNow
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                            : const Color(0xFFDC2626).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOpenNow
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                              : const Color(0xFFDC2626).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOpenNow
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpenNow ? 'OPEN NOW' : 'CLOSED NOW',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isOpenNow
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                const SizedBox(height: 12),

                // 7 Days List Schedule
                ...OperatingHoursModel.allWeekDays.map((day) {
                  final sched = _dailySchedules[day] ??
                      DayOperatingSchedule(day: day, isOpen: day != 'Sunday');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sched.isOpen
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          sched.isOpen
                              ? '${sched.openTime} - ${sched.closeTime}'
                              : 'Closed',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            fontWeight: sched.isOpen
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: sched.isOpen
                                ? AppColors.primary
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
