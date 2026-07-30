import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pagination_controller.dart';
import 'pagination_state.dart';
import '../widgets/app_state_views.dart';
import '../theme/app_colors.dart';

/// A generic, reusable scrollable list widget that handles:
/// - Initial loading, empty state, and error state
/// - Pull-to-refresh
/// - Automatic infinite scroll (loadMore when approaching bottom)
/// - Bottom loading spinner when fetching next page
class PaginatedListView<T> extends ConsumerWidget {
  const PaginatedListView({
    super.key,
    required this.state,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding = const EdgeInsets.all(16),
    this.emptyIcon,
    this.emptyTitle = 'No Items Found',
    this.emptyMessage = 'There are no records available right now.',
    this.scrollThreshold = 200.0,
  });

  final PaginationState<T> state;
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry padding;
  final IconData? emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final double scrollThreshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isInitialLoading) {
      return const AppLoadingState(type: AppLoadingType.list);
    }

    if (state.failure != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.failure?.message ?? 'An unexpected error occurred',
        onRetry: () => controller.loadInitial(),
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AppEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      color: AppColors.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - scrollThreshold) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: padding,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) {
            if (separatorBuilder != null && index < state.items.length - 1) {
              return separatorBuilder!(context, index);
            }
            return const SizedBox(height: 12);
          },
          itemBuilder: (context, index) {
            if (index == state.items.length) {
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
            return itemBuilder(context, state.items[index], index);
          },
        ),
      ),
    );
  }
}
