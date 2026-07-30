import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_state_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/customer_providers.dart';
import '../../domain/models/customer_model.dart';

/// Admin Customer List page — search and view Firestore customer records.
class AdminCustomerListPage extends ConsumerStatefulWidget {
  const AdminCustomerListPage({super.key});

  @override
  ConsumerState<AdminCustomerListPage> createState() => _AdminCustomerListPageState();
}

class _AdminCustomerListPageState extends ConsumerState<AdminCustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedCustomersProvider.notifier).fetchNextPage();
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Customer Directory',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.popOrGo(AppRoutes.adminHome),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${ref.watch(paginatedCustomersProvider).items.length} registered customers',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Search Field
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.montserrat(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, phone…',
                        hintStyle: GoogleFonts.montserrat(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: PhosphorIcon(
                          PhosphorIcons.magnifyingGlass(),
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: PhosphorIcon(
                                  PhosphorIcons.x(),
                                  color: AppColors.textMuted,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(paginatedCustomersProvider.notifier)
                                      .fetchInitial(query: '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                          borderSide: BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                          borderSide: BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (q) {
                        ref
                            .read(paginatedCustomersProvider.notifier)
                            .fetchInitial(query: q);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final paginatedState = ref.watch(paginatedCustomersProvider);
                    final customers = paginatedState.items;

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        await ref
                            .read(paginatedCustomersProvider.notifier)
                            .refresh();
                      },
                      child: paginatedState.isLoading && customers.isEmpty
                          ? const AppLoadingState(type: AppLoadingType.list)
                          : paginatedState.errorMessage != null && customers.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.6,
                                alignment: Alignment.center,
                                child: AppErrorState(
                                  message: paginatedState.errorMessage!,
                                  onRetry: () => ref
                                      .read(paginatedCustomersProvider.notifier)
                                      .refresh(),
                                ),
                              ),
                            )
                          : customers.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.6,
                                alignment: Alignment.center,
                                child: _buildEmptyState(),
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.sm,
                                AppSpacing.lg,
                                AppSpacing.xxl + AppSpacing.xl,
                              ),
                              itemCount: customers.length + (paginatedState.isLoadingMore ? 1 : 0),
                              separatorBuilder: (ctx, i) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                if (index == customers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }
                                final customer = customers[index];
                                return _CustomerCard(
                                  customer: customer,
                                  onTapDetails: () => context.push(
                                    AppRoutes.adminCustomerDetails,
                                    extra: customer,
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter = _searchController.text.isNotEmpty;

    return AppEmptyState(
      icon: hasFilter ? PhosphorIcons.magnifyingGlass() : PhosphorIcons.users(),
      title: hasFilter
          ? 'No matching customers'
          : 'No registered customers yet',
      message: hasFilter
          ? 'Try adjusting your search query.'
          : 'Customers will appear here after signing in to the Customer App.',
      actionLabel: 'Refresh',
      onAction: () => ref.read(paginatedCustomersProvider.notifier).refresh(),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.onTapDetails,
  });

  final CustomerModel customer;
  final VoidCallback onTapDetails;

  String get _initials {
    final parts = customer.displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customer.displayName
        .substring(0, customer.displayName.length.clamp(1, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapDetails,
      borderRadius: AppRadius.borderLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            // Customer Avatar / Monogram
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentGlow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                image: customer.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(customer.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: customer.photoUrl == null
                  ? Center(
                      child: Text(
                        _initials,
                        style: GoogleFonts.montserrat(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            // Customer Info Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.displayName,
                    style: GoogleFonts.montserrat(
                      color: AppColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (customer.email != null && customer.email!.isNotEmpty) ...[
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.envelopeSimple(),
                          size: 13.5,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            customer.email!,
                            style: GoogleFonts.montserrat(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.phone(),
                          size: 13.5,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          customer.phone!,
                          style: GoogleFonts.montserrat(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Trailing Caret
            PhosphorIcon(
              PhosphorIcons.caretRight(),
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
