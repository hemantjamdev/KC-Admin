/// Centralized Firebase Storage path helper for Kapada Creation Admin.
abstract class FirebaseStoragePaths {
  const FirebaseStoragePaths._();

  static String boutiqueLogo(String boutiqueId, String fileId, String ext) =>
      'boutiques/$boutiqueId/branding/logo/$fileId.$ext';

  static String boutiqueBanner(String boutiqueId, String fileId, String ext) =>
      'boutiques/$boutiqueId/branding/banner/$fileId.$ext';

  static String categoryImage(
    String boutiqueId,
    String categoryId,
    String fileId,
    String ext,
  ) => 'boutiques/$boutiqueId/categories/$categoryId/$fileId.$ext';

  static String designImage(
    String boutiqueId,
    String designId,
    String fileId,
    String ext,
  ) => 'boutiques/$boutiqueId/designs/$designId/$fileId.$ext';
}
