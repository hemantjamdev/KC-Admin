import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

enum CustomerStatusFilter { all, active, inactive }

enum CustomerSourceFilter { all, google, admin }

/// Admin Customer List page — search, filter, and view Firestore customer records.
class AdminCustomerListPage extends StatefulWidget {
  const AdminCustomerListPage({super.key});

  @override
  State<AdminCustomerListPage> createState() => _AdminCustomerListPageState();
}

class _AdminCustomerListPageState extends State<AdminCustomerListPage> {
  late final CustomerRepository _repository;
  final TextEditingController _searchController = TextEditingController();

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  CustomerStatusFilter _statusFilter = CustomerStatusFilter.all;
  CustomerSourceFilter _sourceFilter = CustomerSourceFilter.all;

  @override
  void initState() {
    super.initState();
    _repository = CustomerRepositoryImpl();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id;

    try {
      final results = await _repository.getCustomersForAdmin(
        boutiqueId: boutiqueId,
        isActive: switch (_statusFilter) {
          CustomerStatusFilter.active => true,
          CustomerStatusFilter.inactive => false,
          CustomerStatusFilter.all => null,
        },
        source: switch (_sourceFilter) {
          CustomerSourceFilter.google => CustomerSource.google,
          CustomerSourceFilter.admin => CustomerSource.admin,
          CustomerSourceFilter.all => null,
        },
        searchQuery: _searchController.text,
      );

      if (!mounted) return;
      setState(() {
        _customers = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load customers. Please check connection.';
      });
    }
  }

  Future<void> _confirmToggleStatus(CustomerModel customer) async {
    final newStatus = !customer.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(
          newStatus ? 'Activate Customer?' : 'Deactivate Customer?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          newStatus
              ? 'Re-activate "${customer.displayName}" customer profile?'
              : '"${customer.displayName}" will see a restricted profile state in KC-App.',
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
              newStatus ? 'Activate' : 'Deactivate',
              style: TextStyle(
                color: newStatus ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.setCustomerActiveStatus(
          customer.id,
          newStatus,
          'admin',
        );
        await _loadCustomers();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '"${customer.displayName}" activated.'
                  : '"${customer.displayName}" deactivated.',
            ),
            backgroundColor: AppColors.surfaceLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update customer status.'),
            backgroundColor: AppColors.surfaceLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _filterChip<T>(
    T value,
    T current,
    String label,
    void Function(T) onSelected,
  ) {
    final selected = value == current;
    return GestureDetector(
      onTap: () {
        onSelected(value);
        _loadCustomers();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.borderPill,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = BoutiqueSelectionScope.of(context);
    final boutique = scope.selectedBoutique;
    final branch = scope.selectedBranch;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customers',
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
          onPressed: () => context.go(AppRoutes.adminHome),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Customer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.go(AppRoutes.adminCustomerAdd),
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
                      Expanded(
                        child: Text(
                          boutique?.name ?? '—',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (branch != null)
                        Text(
                          branch.name,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '${_customers.length} customers',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone…',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _loadCustomers();
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
                        borderSide: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.borderMd,
                        borderSide: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.borderMd,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (_) => _loadCustomers(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Status & Source Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip(
                          CustomerStatusFilter.all,
                          _statusFilter,
                          'All Status',
                          (v) => setState(() => _statusFilter = v),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _filterChip(
                          CustomerStatusFilter.active,
                          _statusFilter,
                          'Active',
                          (v) => setState(() => _statusFilter = v),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _filterChip(
                          CustomerStatusFilter.inactive,
                          _statusFilter,
                          'Inactive',
                          (v) => setState(() => _statusFilter = v),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _filterChip(
                          CustomerSourceFilter.all,
                          _sourceFilter,
                          'All Sources',
                          (v) => setState(() => _sourceFilter = v),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _filterChip(
                          CustomerSourceFilter.google,
                          _sourceFilter,
                          'Google',
                          (v) => setState(() => _sourceFilter = v),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _filterChip(
                          CustomerSourceFilter.admin,
                          _sourceFilter,
                          'Admin Created',
                          (v) => setState(() => _sourceFilter = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppLoadingIndicator(size: 32),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Loading customers...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton.icon(
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                              onPressed: _loadCustomers,
                            ),
                          ],
                        ),
                      ),
                    )
                  : _customers.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xxl + AppSpacing.xl,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _customers.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final customer = _customers[i];
                        return _CustomerCard(
                          customer: customer,
                          onTapDetails: () => context.go(
                            AppRoutes.adminCustomerDetails,
                            extra: customer,
                          ),
                          onEdit: () => context.go(
                            AppRoutes.adminCustomerEdit,
                            extra: customer,
                          ),
                          onToggleStatus: () => _confirmToggleStatus(customer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter =
        _searchController.text.isNotEmpty ||
        _statusFilter != CustomerStatusFilter.all ||
        _sourceFilter != CustomerSourceFilter.all;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilter
                  ? 'No customers match the selected filters.'
                  : 'No customers have been added for this boutique.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.onTapDetails,
    required this.onEdit,
    required this.onToggleStatus,
  });

  final CustomerModel customer;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  String get _initials {
    final parts = customer.displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customer.displayName
        .substring(0, customer.displayName.length.clamp(1, 2))
        .toUpperCase();
  }

  String _boutiqueBranchSummary() {
    final boutiqueCount = customer.boutiqueIds.length;
    final branchCount = customer.branchIds.length;
    if (boutiqueCount == 0 && branchCount == 0) return 'Unassigned';
    return '$boutiqueCount boutique(s)${branchCount > 0 ? ', $branchCount branch(es)' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        onTap: onTapDetails,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
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
                    fontSize: 14,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _Badge(
              label: customer.isActive ? 'Active' : 'Inactive',
              color: customer.isActive ? AppColors.success : AppColors.error,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            if (customer.email != null)
              Text(
                customer.email!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            if (customer.phone != null)
              Text(
                customer.phone!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _Badge(
                  label: customer.source.label,
                  color: customer.source == CustomerSource.google
                      ? AppColors.primary
                      : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                if (customer.isFirebaseLinked)
                  const Icon(
                    Icons.link_rounded,
                    color: AppColors.success,
                    size: 14,
                  ),
                const Spacer(),
                Expanded(
                  child: Text(
                    _boutiqueBranchSummary(),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surfaceLight,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'View Profile',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Edit Customer',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    customer.isActive
                        ? Icons.person_off_rounded
                        : Icons.person_outline_rounded,
                    color: customer.isActive
                        ? AppColors.warning
                        : AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    customer.isActive ? 'Deactivate' : 'Activate',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (val) {
            switch (val) {
              case 'details':
                onTapDetails();
              case 'edit':
                onEdit();
              case 'toggle':
                onToggleStatus();
            }
          },
        ),
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
