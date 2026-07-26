import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/customer_model.dart';

/// Admin Customer Details Page — shows identity, audit metadata, and status.
class AdminCustomerDetailsPage extends StatelessWidget {
  const AdminCustomerDetailsPage({super.key, required this.customer});
  final CustomerModel customer;

  String get _initials {
    final parts = customer.displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customer.displayName
        .substring(0, customer.displayName.length.clamp(1, 2))
        .toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<String> get _boutiqueNames {
    return customer.boutiqueIds;
  }

  List<String> get _branchNames {
    return customer.branchIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Profile',
          style: TextStyle(
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
          onPressed: () => context.go(AppRoutes.adminCustomerList),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            tooltip: 'Edit Profile',
            onPressed: () =>
                context.go(AppRoutes.adminCustomerEdit, extra: customer),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identity Header Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.surfaceLight,
                          backgroundImage: customer.photoUrl != null
                              ? NetworkImage(customer.photoUrl!)
                              : null,
                          child: customer.photoUrl == null
                              ? Text(
                                  _initials,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          customer.displayName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Badge(
                              label: customer.source.label,
                              color: customer.source == CustomerSource.google
                                  ? AppColors.primary
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _Badge(
                              label: customer.isActive ? 'Active' : 'Inactive',
                              color: customer.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            if (customer.isFirebaseLinked) ...[
                              const SizedBox(width: AppSpacing.xs),
                              const _Badge(
                                label: 'Firebase Linked',
                                color: AppColors.success,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Contact Details Section
                  _infoCard('Contact Details', [
                    _infoRow('Email Address', customer.email ?? 'Not provided'),
                    _infoRow('Phone Number', customer.phone ?? 'Not provided'),
                  ]),

                  const SizedBox(height: AppSpacing.md),

                  // Assignments Section
                  _infoCard('Boutique & Branch Assignments', [
                    _infoRow(
                      'Boutiques',
                      _boutiqueNames.isEmpty
                          ? 'None'
                          : _boutiqueNames.join(', '),
                    ),
                    _infoRow(
                      'Branches',
                      _branchNames.isEmpty ? 'None' : _branchNames.join('\n'),
                    ),
                  ]),

                  const SizedBox(height: AppSpacing.md),

                  // System Metadata & Audit
                  _infoCard('System Metadata', [
                    _infoRow('Customer Document ID', customer.id),
                    _infoRow(
                      'Firebase Auth UID',
                      customer.firebaseUid ?? 'Not linked',
                    ),
                    _infoRow('Created At', _formatDate(customer.createdAt)),
                    _infoRow('Updated At', _formatDate(customer.updatedAt)),
                    _infoRow('Created By', customer.createdBy ?? 'System'),
                    _infoRow('Updated By', customer.updatedBy ?? 'System'),
                  ]),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: AppRadius.borderPill,
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}
