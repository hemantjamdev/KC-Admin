import 'package:uuid/uuid.dart';

class IdGenerator {
  const IdGenerator._();

  static const Uuid _uuid = Uuid();

  static String generateId() {
    return _uuid.v4();
  }
}
