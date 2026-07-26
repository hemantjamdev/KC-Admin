import 'package:flutter/widgets.dart';
import 'package:kc_admin/src/app/app.dart';
import 'package:kc_admin/src/bootstrap/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrap(() => const KcAdminApp());
}
