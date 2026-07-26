import 'package:go_router/go_router.dart';
import '../../modules/starter/presentation/pages/starter_page.dart';
import 'route_paths.dart';

final List<RouteBase> appRoutes = [
  GoRoute(
    path: RoutePaths.initial,
    builder: (context, state) =>
        const StarterPage(title: 'Kapada Creation Admin'),
  ),
];
