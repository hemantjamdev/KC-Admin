import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../application/providers/home_providers.dart';
import '../../../stitching/presentation/pages/admin_stitching_order_details_page.dart';

/// Admin Activity List Page — shows all live boutique activity events
/// across Stitching Requests, Customer Favorites, Designs, and Notifications.
class AdminActivityListPage extends ConsumerStatefulWidget {
  const AdminActivityListPage({super.key});

  @override
  ConsumerState<AdminActivityListPage> createState() =>
      _AdminActivityListPageState();
}

class _AdminActivityListPageState extends ConsumerState<AdminActivityListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  AdminActivityCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedActivityNotifierProvider.notifier).fetchNextPage();
    }
  }

  void _updateFilter({AdminActivityCategory? category, String? query}) {
    final cat = category ?? _selectedCategory;
    final q = query ?? _searchQuery;
    ref.read(paginatedActivityNotifierProvider.notifier).fetchInitial(
          category: cat,
          query: q,
        );
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(paginatedActivityNotifierProvider);
    final items = activityState.items;

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
            'All Activity',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.textPrimary,
              fontSize: 22,
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
              // Search Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.montserrat(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search activity by title or description…',
                        hintStyle: GoogleFonts.montserrat(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _updateFilter(query: '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        _updateFilter(query: val);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip(null, 'All Events'),
                          const SizedBox(width: 8),
                          _filterChip(
                            AdminActivityCategory.stitchingRequest,
                            'Stitching',
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            AdminActivityCategory.favorite,
                            'Favorites',
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            AdminActivityCategory.newDesign,
                            'Catalogue',
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            AdminActivityCategory.notification,
                            'Notifications',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Activity List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await ref
                        .read(paginatedActivityNotifierProvider.notifier)
                        .fetchInitial(
                          category: _selectedCategory,
                          query: _searchQuery,
                        );
                  },
                  child: activityState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: _buildEmptyState(),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount:
                                  items.length + (activityState.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return _ActivityCardTile(item: items[index]);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(AdminActivityCategory? category, String label) {
    final selected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _updateFilter(category: category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: selected ? AppColors.background : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter = _searchQuery.isNotEmpty || _selectedCategory != null;

    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: hasFilter ? 'No Matching Activities' : 'No Activity Events Yet',
      message: hasFilter
          ? 'No activity items match your search query or selected filter.'
          : 'Customer and admin activity events will appear here as they occur.',
    );
  }
}

// ── Activity Card Tile ────────────────────────────────────────────────────────

class _ActivityCardTile extends StatelessWidget {
  const _ActivityCardTile({required this.item});

  final AdminActivityItem item;

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM yyyy, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.associatedOrder != null) {
          AdminStitchingOrderDetailsPage.showAsBottomSheet(
            context,
            order: item.associatedOrder!,
          );
        } else if (item.category == AdminActivityCategory.newDesign ||
            item.category == AdminActivityCategory.favorite) {
          context.go(AppRoutes.adminProducts);
        } else if (item.category == AdminActivityCategory.notification) {
          context.push(AppRoutes.adminNotificationList);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent stripe indicator matching category color
                  Container(
                    width: 4.5,
                    color: item.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(item.icon, size: 20, color: item.color),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(item.timestamp),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.subtitle,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                        ],
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
}
