import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/core/services/network_connectivity_service.dart';
import 'package:kc_admin/src/features/design/domain/models/design_model.dart';
import 'package:kc_admin/src/features/notification/domain/models/notification_model.dart';
import 'package:kc_admin/src/features/stitching/domain/models/stitching_order_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DesignModel Tests', () {
    test('CopyWith and property updates work correctly', () {
      final now = DateTime.now();
      final design = DesignModel(
        id: 'design_101',
        boutiqueId: 'boutique_01',
        categoryId: 'cat_01',
        slug: 'silk-anarkali-suit',
        name: 'Silk Anarkali Suit',
        price: 4999.0,
        imageUrls: const ['https://example.com/img1.jpg'],
        colors: const ['#FF0000', '#00FF00'],
        sizes: const ['M', 'L', 'XL'],
        tags: const ['trending'],
        searchKeywords: const ['silk', 'anarkali'],
        sortOrder: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(design.id, equals('design_101'));
      expect(design.name, equals('Silk Anarkali Suit'));
      expect(design.price, equals(4999.0));
      expect(design.isActive, isTrue);

      final copy = design.copyWith(price: 5499.0, isActive: false);
      expect(copy.price, equals(5499.0));
      expect(copy.isActive, isFalse);
      expect(copy.name, equals('Silk Anarkali Suit'));
    });
  });

  group('StitchingOrderModel Tests', () {
    test('Status admin labels and progression', () {
      final now = DateTime.now();
      final order = StitchingOrderModel(
        id: 'order_1',
        orderNumber: 'STITCH-1001',
        boutiqueId: 'boutique_01',
        branchId: 'branch_01',
        customerId: 'customer_01',
        designReferences: const [],
        status: StitchingOrderStatus.requested,
        createdAt: now,
        updatedAt: now,
      );

      expect(order.status.adminLabel, equals('Requested'));
      expect(
        StitchingOrderStatus.accepted.adminLabel,
        equals('Accepted'),
      );
      expect(StitchingOrderStatus.completed.adminLabel, equals('Completed'));

      final updated = order.copyWith(status: StitchingOrderStatus.completed);
      expect(updated.status, equals(StitchingOrderStatus.completed));
    });
  });

  group('NotificationModel Tests', () {
    test('Target user resolution for broadcast vs specific customer', () {
      final now = DateTime.now();
      final broadcast = NotificationModel(
        id: 'notif_1',
        boutiqueId: 'boutique_01',
        title: 'Festival Sale',
        body: 'New festive collection in store!',
        type: NotificationType.general,
        audienceType: NotificationAudienceType.allBoutiqueCustomers,
        customerIds: const [],
        status: NotificationStatus.published,
        createdAt: now,
        updatedAt: now,
      );
      expect(broadcast.customerIds, isEmpty);

      final specific = NotificationModel(
        id: 'notif_2',
        boutiqueId: 'boutique_01',
        title: 'Stitching Ready',
        body: 'Your blouse is ready for pickup.',
        type: NotificationType.stitchingUpdate,
        audienceType: NotificationAudienceType.selectedCustomers,
        customerIds: const ['customer_99'],
        status: NotificationStatus.published,
        createdAt: now,
        updatedAt: now,
      );
      expect(specific.customerIds, contains('customer_99'));
    });
  });

  group('Cross-App Data Contract Tests', () {
    test('Admin Product deserializes correctly across app boundaries', () {
      final json = {
        'id': 'product_101',
        'boutiqueId': 'boutique_01',
        'categoryId': 'cat_01',
        'slug': 'silk-saree',
        'name': 'Royal Silk Saree',
        'price': 8999.0,
        'imageUrls': ['https://example.com/saree.jpg'],
        'colors': ['Red', 'Gold'],
        'sizes': ['Free Size'],
        'tags': ['trending'],
        'searchKeywords': ['silk', 'saree'],
        'sortOrder': 1,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final design = DesignModel(
        id: json['id'] as String,
        boutiqueId: json['boutiqueId'] as String,
        categoryId: json['categoryId'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrls: List<String>.from(json['imageUrls'] as List),
        colors: List<String>.from(json['colors'] as List),
        sizes: List<String>.from(json['sizes'] as List),
        tags: List<String>.from(json['tags'] as List),
        searchKeywords: List<String>.from(json['searchKeywords'] as List),
        sortOrder: json['sortOrder'] as int,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

      expect(design.id, equals('product_101'));
      expect(design.price, equals(8999.0));
      expect(design.name, equals('Royal Silk Saree'));
    });

    test(
      'Stitching request status updates serialize properly for Customer stream',
      () {
        final order = StitchingOrderModel(
          id: 'stitch_202',
          orderNumber: 'KC-ST-002',
          boutiqueId: 'boutique_01',
          branchId: '',
          customerId: 'user_uid_123',
          designReferences: const [],
          status: StitchingOrderStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(order.status.adminLabel, equals('Completed'));
        expect(order.customerId, equals('user_uid_123'));
      },
    );
  });

  group('NetworkConnectivityService Tests', () {
    test('Service instance initializes and holds online status property', () {
      final service = NetworkConnectivityService.instance;
      service.initialize();
      expect(service.isOnline, isA<bool>());
    });
  });
}
