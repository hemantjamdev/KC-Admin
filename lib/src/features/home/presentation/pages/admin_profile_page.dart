import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/providers/admin_profile_providers.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../shop_profile/domain/models/shop_profile_model.dart';

/// Admin Profile screen — account details, studio profile, settings, logout.
class AdminProfilePage extends ConsumerWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(adminDisplayNameProvider);
    final email = ref.watch(adminEmailProvider);
    final photoUrl = ref.watch(adminPhotoUrlProvider);
    final shopProfile = ref.watch(adminShopProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile & Studio',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Account preferences & boutique configuration',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Admin User Card (Editable) ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (photoUrl != null && photoUrl.isNotEmpty) {
                                _showFullScreenImageDialog(context, photoUrl, displayName);
                              }
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                ),
                                image: photoUrl != null && photoUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(photoUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: photoUrl == null || photoUrl.isEmpty
                                  ? Center(
                                      child: Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : 'A',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _showAdminProfileEditModal(
                                context,
                                ref,
                                displayName,
                                photoUrl,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: PhosphorIcon(
                                  PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              displayName.isNotEmpty ? displayName : 'Admin User',
                              style: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              email.isNotEmpty ? email : 'admin@kapadacreation.com',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Shop / Studio Profile Card (Compact Live Preview Style) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2), // Warm cream card surface
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
                      // Header bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'KAPADA CREATION INFO',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.push(AppRoutes.adminShopProfileEdit),
                            child: Container(
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
                                  Text(
                                    'Edit Details',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  PhosphorIcon(
                                    PhosphorIcons.arrowRight(),
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Main Card Content Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Primary Details Column (Maximized Width)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  shopProfile.name.isNotEmpty
                                      ? shopProfile.name
                                      : 'Kapada Creation',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Est. 2015',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  shopProfile.subtitle.isNotEmpty
                                      ? shopProfile.subtitle
                                      : 'Luxury Bespoke Designer Apparel & Custom Tailoring',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13.5,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (shopProfile.address != null &&
                                    shopProfile.address!.isNotEmpty)
                                  Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.mapPin(),
                                        size: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          shopProfile.address!,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (shopProfile.phone != null &&
                                    shopProfile.phone!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.phone(),
                                        size: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        shopProfile.phone!,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 2),
                                GestureDetector(
                                  onTap: () => _showWorkingHoursBottomSheet(
                                    context,
                                    shopProfile,
                                  ),
                                  child: Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.clock(),
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Working Hours',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      PhosphorIcon(
                                        PhosphorIcons.info(PhosphorIconsStyle.fill),
                                        size: 15,
                                        color: const Color(0xFFD97706),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 2. Right Feature Aesthetic Image Thumbnail
                          GestureDetector(
                            onTap: () {
                              if (shopProfile.logoUrl != null &&
                                  shopProfile.logoUrl!.isNotEmpty) {
                                _showFullScreenImageDialog(
                                  context,
                                  shopProfile.logoUrl!,
                                  shopProfile.name,
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: (shopProfile.logoUrl != null &&
                                      shopProfile.logoUrl!.isNotEmpty)
                                  ? Image.network(
                                      shopProfile.logoUrl!,
                                      width: 78,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        width: 78,
                                        height: 96,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        child: Icon(
                                          PhosphorIcons.storefront(),
                                          color: AppColors.primary,
                                          size: 32,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 78,
                                      height: 96,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      child: Icon(
                                        PhosphorIcons.storefront(),
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Studio Management Settings List ───────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STUDIO MANAGEMENT',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      icon: PhosphorIcons.squaresFour(PhosphorIconsStyle.bold),
                      title: 'Category Manager',
                      subtitle: 'Organise apparel categories & catalog collections',
                      onTap: () => context.push(AppRoutes.adminCategoryList),
                    ),
                    _SettingsTile(
                      icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
                      title: 'Customer Directory',
                      subtitle: 'Registered clients & stitching profiles',
                      onTap: () => context.push(AppRoutes.adminCustomerList),
                    ),
                    _SettingsTile(
                      icon: PhosphorIcons.bellRinging(PhosphorIconsStyle.bold),
                      title: 'Push Notifications',
                      subtitle: 'Broadcast notifications & announcements to clients',
                      onTap: () =>
                          context.push(AppRoutes.adminNotificationList),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 12),

                    Center(
                      child: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.hasData
                              ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                              : 'v1.0.0';
                          return Column(
                            children: [
                              Text(
                                'Kapada Creation Admin',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                version,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: Text(
                                'Sign Out',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to log out of Kapada Creation Admin?',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                  ),
                                  child: Text(
                                    'Sign Out',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref
                                .read(adminAuthProvider.notifier)
                                .signOut();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          }
                        },
                        icon: PhosphorIcon(
                          PhosphorIcons.signOut(PhosphorIconsStyle.bold),
                          color: const Color(0xFFDC2626),
                          size: 20,
                        ),
                        label: Text(
                          'Sign Out',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFFDC2626),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Modal Sheet: Edit Admin Profile ──────────────────────────────────────────
  void _showAdminProfileEditModal(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String? currentPhotoUrl,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AdminProfileEditForm(
        currentName: currentName,
        currentPhotoUrl: currentPhotoUrl,
      ),
    );
  }
}

class _AdminProfileEditForm extends ConsumerStatefulWidget {
  const _AdminProfileEditForm({
    required this.currentName,
    required this.currentPhotoUrl,
  });

  final String currentName;
  final String? currentPhotoUrl;

  @override
  ConsumerState<_AdminProfileEditForm> createState() => _AdminProfileEditFormState();
}

class _AdminProfileEditFormState extends ConsumerState<_AdminProfileEditForm> {
  late final TextEditingController _nameController;
  File? _selectedAvatarFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedAvatarFile = File(image.path));
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.show(context, 'Display Name cannot be empty.', type: ToastType.error);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(adminProfileUpdateProvider.notifier).updateProfile(
            displayName: name,
            avatarFile: _selectedAvatarFile,
          );
      if (mounted) {
        Navigator.pop(context);
        AppToast.show(context, 'Admin Profile updated successfully!', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Failed to update profile: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Text(
              'Edit Admin Profile',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Update your admin display name & photo saved to Firebase',
              style: GoogleFonts.montserrat(
                fontSize: 13.5,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 20),

            // Avatar Picker Row
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.5,
                      ),
                      image: _selectedAvatarFile != null
                          ? DecorationImage(
                              image: FileImage(_selectedAvatarFile!),
                              fit: BoxFit.cover,
                            )
                          : widget.currentPhotoUrl != null && widget.currentPhotoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.currentPhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: _selectedAvatarFile == null &&
                            (widget.currentPhotoUrl == null || widget.currentPhotoUrl!.isEmpty)
                        ? Center(
                            child: Text(
                              widget.currentName.isNotEmpty
                                  ? widget.currentName[0].toUpperCase()
                                  : 'A',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: GestureDetector(
                      onTap: _pickAvatarImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Display Name Input
            Text(
              'DISPLAY NAME',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.montserrat(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Admin Display Name',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Action Button
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
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Profile Changes',
                        style: GoogleFonts.montserrat(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

void _showWorkingHoursBottomSheet(
  BuildContext ctx,
  ShopProfileModel shopProfile,
) {
    final opHours =
        shopProfile.operatingHours ?? OperatingHoursModel.defaultSchedule;
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
                            shopProfile.name.isNotEmpty
                                ? shopProfile.name
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
                  final sched = opHours.dailySchedules[day] ??
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

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        trailing: onTap != null
            ? PhosphorIcon(
                PhosphorIcons.caretRight(),
                color: AppColors.textMuted.withValues(alpha: 0.6),
                size: 18,
              )
            : null,
      ),
    );
  }
}

void _showFullScreenImageDialog(
  BuildContext context,
  String imageUrl,
  String title,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(32),
                    color: AppColors.surface,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: GoogleFonts.montserrat(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
