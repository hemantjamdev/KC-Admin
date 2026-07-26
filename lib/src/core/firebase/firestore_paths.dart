/// Centralized collection and document path registry for Firestore.
abstract class FirestorePaths {
  const FirestorePaths._();

  static const String boutiques = 'boutiques';
  static String boutique(String boutiqueId) => 'boutiques/$boutiqueId';

  static const String branches = 'branches';
  static String branch(String branchId) => 'branches/$branchId';

  static const String admins = 'admins';
  static String admin(String adminId) => 'admins/$adminId';

  static const String customers = 'customers';
  static String customer(String customerId) => 'customers/$customerId';

  static const String categories = 'categories';
  static String category(String categoryId) => 'categories/$categoryId';

  static const String designs = 'designs';
  static String design(String designId) => 'designs/$designId';

  static const String designAvailability = 'designAvailability';
  static String availability(String branchId, String designId) =>
      'designAvailability/${branchId}_$designId';

  static const String sections = 'sections';
  static String section(String sectionId) => 'sections/$sectionId';

  static const String sectionItems = 'sectionItems';
  static String sectionItem(String itemId) => 'sectionItems/$itemId';

  static const String stitchingOrders = 'stitchingOrders';
  static String stitchingOrder(String orderId) => 'stitchingOrders/$orderId';

  static const String stitchingOrderHistory = 'stitchingOrderHistory';
  static String orderHistoryEvent(String historyId) =>
      'stitchingOrderHistory/$historyId';

  static const String notifications = 'notifications';
  static String notification(String notificationId) =>
      'notifications/$notificationId';

  static const String notificationReads = 'notificationReads';
  static String notificationRead(String notificationId, String customerId) =>
      'notificationReads/${notificationId}_$customerId';

  static const String deviceTokens = 'deviceTokens';
  static String deviceToken(String tokenId) => 'deviceTokens/$tokenId';
}
