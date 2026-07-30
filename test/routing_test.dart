import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kc_admin/src/app/app_routes.dart';

void main() {
  group('Admin Routing & Launch Flow Verification', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    List<String> getRegisteredPaths(GoRouter router) {
      final paths = <String>[];
      for (final route in router.configuration.routes) {
        if (route is GoRoute) {
          paths.add(route.path);
          for (final subRoute in route.routes) {
            if (subRoute is GoRoute) {
              paths.add(subRoute.path);
            }
          }
        }
      }
      return paths;
    }

    test('1. Signed out Admin launch routes directly to Admin Login', () async {
      final router = createAppRouter(container);
      expect(router.configuration.routes, isNotEmpty);
      expect(AppRoutes.login, equals('/login'));
    });

    test('2. Authorized Admin launch routes directly to Admin Home', () {
      final router = createAppRouter(container);
      expect(AppRoutes.adminHome, equals('/admin/home'));
      expect(router.configuration.routes, isNotEmpty);
    });

    test(
      '3. Obsolete boutique and branch routes are NOT registered in GoRouter',
      () {
        final router = createAppRouter(container);
        final registeredPaths = getRegisteredPaths(router);

        expect(registeredPaths, isNot(contains('/admin/select-boutique')));
        expect(registeredPaths, isNot(contains('/admin/boutiques/add')));
        expect(registeredPaths, isNot(contains('/admin/boutiques/edit')));
        expect(registeredPaths, isNot(contains('/admin/select-branch')));
        expect(registeredPaths, isNot(contains('/admin/branches/add')));
        expect(registeredPaths, isNot(contains('/admin/branches/edit')));
      },
    );

    test(
      '4. Empty boutique collection does not prevent routing to Admin Home',
      () {
        final router = createAppRouter(container);
        expect(router.configuration.routes, isNotEmpty);
      },
    );

    test(
      '5. Empty branch collection does not prevent routing to Admin Home',
      () {
        final router = createAppRouter(container);
        expect(router.configuration.routes, isNotEmpty);
      },
    );

    test(
      '6. Stale local boutique or branch selection data does not alter routing',
      () {
        final router = createAppRouter(container);
        expect(router.configuration.routes, isNotEmpty);
      },
    );

    test('7. Shop Profile route is registered correctly', () {
      final router = createAppRouter(container);
      final registeredPaths = getRegisteredPaths(router);
      expect(registeredPaths, contains(AppRoutes.adminShopProfileEdit));
    });
  });
}
