import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:kc_admin/src/app/app.dart';
import 'package:kc_admin/src/bootstrap/bootstrap.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await bootstrap(() => const KcAdminApp());
}
