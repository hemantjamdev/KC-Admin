import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/admin_login_page.dart';
import '../features/boutique/presentation/pages/admin_boutique_selection_page.dart';
import '../features/boutique/presentation/pages/admin_branch_selection_page.dart';
import '../features/category/domain/models/category_model.dart';
import '../features/category/presentation/pages/admin_category_list_page.dart';
import '../features/category/presentation/pages/category_form_page.dart';
import '../features/category/presentation/pages/category_reorder_page.dart';
import '../features/customer/domain/models/customer_model.dart';
import '../features/customer/presentation/pages/admin_customer_details_page.dart';
import '../features/customer/presentation/pages/admin_customer_form_page.dart';
import '../features/customer/presentation/pages/admin_customer_list_page.dart';
import '../features/design/domain/models/design_model.dart';
import '../features/design/presentation/pages/admin_design_list_page.dart';
import '../features/design/presentation/pages/design_availability_page.dart';
import '../features/design/presentation/pages/design_form_page.dart';
import '../features/design/presentation/pages/design_reorder_page.dart';
import '../features/home/presentation/pages/admin_home_page.dart';
import '../features/notification/domain/models/notification_model.dart';
import '../features/notification/presentation/pages/admin_notification_details_page.dart';
import '../features/notification/presentation/pages/admin_notification_form_page.dart';
import '../features/notification/presentation/pages/admin_notification_list_page.dart';
import '../features/notification/presentation/pages/admin_notification_preview_page.dart';
import '../features/section/domain/models/section_model.dart';
import '../features/section/presentation/pages/admin_section_list_page.dart';
import '../features/section/presentation/pages/section_form_page.dart';
import '../features/section/presentation/pages/section_item_management_page.dart';
import '../features/section/presentation/pages/section_reorder_page.dart';
import '../features/stitching/domain/models/stitching_order_model.dart';
import '../features/stitching/presentation/pages/admin_stitching_order_details_page.dart';
import '../features/stitching/presentation/pages/admin_stitching_order_list_page.dart';
import '../features/stitching/presentation/pages/stitching_order_form_page.dart';

/// Centralized route paths and router configuration for KC-Admin.
abstract class AppRoutes {
  const AppRoutes._();

  // Auth
  static const String login = '/login';

  // Boutique selection
  static const String adminSelectBoutique = '/admin/select-boutique';
  static const String adminSelectBranch = '/admin/select-branch';

  // Admin shell
  static const String adminHome = '/admin/home';

  // Category management
  static const String adminCategoryList = '/admin/categories';
  static const String adminCategoryAdd = '/admin/categories/add';
  static const String adminCategoryEdit = '/admin/categories/edit';
  static const String adminCategoryReorder = '/admin/categories/reorder';

  // Design management
  static const String adminDesignList = '/admin/designs';
  static const String adminDesignAdd = '/admin/designs/add';
  static const String adminDesignEdit = '/admin/designs/edit';
  static const String adminDesignAvailability = '/admin/designs/availability';
  static const String adminDesignReorder = '/admin/designs/reorder';

  // Section management
  static const String adminSectionList = '/admin/sections';
  static const String adminSectionAdd = '/admin/sections/add';
  static const String adminSectionEdit = '/admin/sections/edit';
  static const String adminSectionItemManagement = '/admin/sections/items';
  static const String adminSectionDesignPicker = '/admin/sections/picker';
  static const String adminSectionReorder = '/admin/sections/reorder';

  // Customer management
  static const String adminCustomerList = '/admin/customers';
  static const String adminCustomerAdd = '/admin/customers/add';
  static const String adminCustomerEdit = '/admin/customers/edit';
  static const String adminCustomerDetails = '/admin/customers/details';

  // Stitching Order management
  static const String adminStitchingOrderList = '/admin/stitching';
  static const String adminStitchingOrderAdd = '/admin/stitching/add';
  static const String adminStitchingOrderEdit = '/admin/stitching/edit';
  static const String adminStitchingOrderDetails = '/admin/stitching/details';

  // Notification management
  static const String adminNotificationList = '/admin/notifications';
  static const String adminNotificationAdd = '/admin/notifications/add';
  static const String adminNotificationEdit = '/admin/notifications/edit';
  static const String adminNotificationDetails = '/admin/notifications/details';
  static const String adminNotificationPreview = '/admin/notifications/preview';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      path: AppRoutes.adminSelectBoutique,
      builder: (context, state) => const AdminBoutiqueSelectionPage(),
    ),
    GoRoute(
      path: AppRoutes.adminSelectBranch,
      builder: (context, state) => const AdminBranchSelectionPage(),
    ),
    GoRoute(
      path: AppRoutes.adminHome,
      builder: (context, state) => const AdminHomePage(),
    ),
    GoRoute(
      path: AppRoutes.adminCategoryList,
      builder: (context, state) => const AdminCategoryListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminCategoryAdd,
      builder: (context, state) => const CategoryFormPage(),
    ),
    GoRoute(
      path: AppRoutes.adminCategoryEdit,
      builder: (context, state) =>
          CategoryFormPage(existingCategory: state.extra as CategoryModel?),
    ),
    GoRoute(
      path: AppRoutes.adminCategoryReorder,
      builder: (context, state) => const CategoryReorderPage(),
    ),
    // Designs
    GoRoute(
      path: AppRoutes.adminDesignList,
      builder: (context, state) => const AdminDesignListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminDesignAdd,
      builder: (context, state) => const DesignFormPage(),
    ),
    GoRoute(
      path: AppRoutes.adminDesignEdit,
      builder: (context, state) =>
          DesignFormPage(existingDesign: state.extra as DesignModel?),
    ),
    GoRoute(
      path: AppRoutes.adminDesignAvailability,
      builder: (context, state) =>
          DesignAvailabilityPage(design: state.extra as DesignModel),
    ),
    GoRoute(
      path: AppRoutes.adminDesignReorder,
      builder: (context, state) => const DesignReorderPage(),
    ),
    // Sections
    GoRoute(
      path: AppRoutes.adminSectionList,
      builder: (context, state) => const AdminSectionListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminSectionAdd,
      builder: (context, state) => const SectionFormPage(),
    ),
    GoRoute(
      path: AppRoutes.adminSectionEdit,
      builder: (context, state) =>
          SectionFormPage(existingSection: state.extra as SectionModel?),
    ),
    GoRoute(
      path: AppRoutes.adminSectionItemManagement,
      builder: (context, state) =>
          SectionItemManagementPage(section: state.extra as SectionModel),
    ),
    GoRoute(
      path: AppRoutes.adminSectionReorder,
      builder: (context, state) => const SectionReorderPage(),
    ),
    // Customers
    GoRoute(
      path: AppRoutes.adminCustomerList,
      builder: (context, state) => const AdminCustomerListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminCustomerAdd,
      builder: (context, state) => const AdminCustomerFormPage(),
    ),
    GoRoute(
      path: AppRoutes.adminCustomerEdit,
      builder: (context, state) => AdminCustomerFormPage(
        existingCustomer: state.extra as CustomerModel?,
      ),
    ),
    GoRoute(
      path: AppRoutes.adminCustomerDetails,
      builder: (context, state) =>
          AdminCustomerDetailsPage(customer: state.extra as CustomerModel),
    ),
    // Stitching Orders
    GoRoute(
      path: AppRoutes.adminStitchingOrderList,
      builder: (context, state) => const AdminStitchingOrderListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminStitchingOrderAdd,
      builder: (context, state) => const StitchingOrderFormPage(),
    ),
    GoRoute(
      path: AppRoutes.adminStitchingOrderEdit,
      builder: (context, state) => StitchingOrderFormPage(
        existingOrder: state.extra as StitchingOrderModel?,
      ),
    ),
    GoRoute(
      path: AppRoutes.adminStitchingOrderDetails,
      builder: (context, state) => AdminStitchingOrderDetailsPage(
        order: state.extra as StitchingOrderModel,
      ),
    ),
    // Notifications
    GoRoute(
      path: AppRoutes.adminNotificationList,
      builder: (context, state) => const AdminNotificationListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminNotificationAdd,
      builder: (context, state) => const AdminNotificationFormPage(),
    ),
    GoRoute(
      path: AppRoutes.adminNotificationEdit,
      builder: (context, state) => AdminNotificationFormPage(
        existingNotification: state.extra as NotificationModel?,
      ),
    ),
    GoRoute(
      path: AppRoutes.adminNotificationDetails,
      builder: (context, state) => AdminNotificationDetailsPage(
        notification: state.extra as NotificationModel,
      ),
    ),
    GoRoute(
      path: AppRoutes.adminNotificationPreview,
      builder: (context, state) => AdminNotificationPreviewPage(
        notification: state.extra as NotificationModel,
      ),
    ),
  ],
);
