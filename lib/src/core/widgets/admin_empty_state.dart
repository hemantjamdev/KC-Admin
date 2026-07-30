import 'package:flutter/material.dart';
import 'app_state_views.dart';

/// Reusable empty state widget for admin screens — adapts to generic AppEmptyState.
class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: subtitle ?? '',
      icon: icon,
      onAction: action,
      actionLabel: actionLabel,
    );
  }
}
