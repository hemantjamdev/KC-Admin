import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:kc_admin/src/app/app.dart';
import 'package:kc_admin/src/bootstrap/bootstrap.dart';
import 'package:kc_admin/src/features/notification/data/services/admin_firebase_messaging_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(
    adminFirebaseMessagingBackgroundHandler,
  );

  await bootstrap(() => const KcAdminApp());
}
