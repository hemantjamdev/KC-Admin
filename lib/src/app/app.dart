import 'package:flutter/material.dart';
import '../features/boutique/presentation/controllers/boutique_selection_controller.dart';
import 'app_routes.dart';
import 'app_theme.dart';

/// Root application widget for Kapada Creation Admin.
class KcAdminApp extends StatefulWidget {
  const KcAdminApp({super.key});

  @override
  State<KcAdminApp> createState() => _KcAdminAppState();
}

class _KcAdminAppState extends State<KcAdminApp> {
  final _selectionController = BoutiqueSelectionController();

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoutiqueSelectionScope(
      controller: _selectionController,
      child: MaterialApp.router(
        title: 'Kapada Creation Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
