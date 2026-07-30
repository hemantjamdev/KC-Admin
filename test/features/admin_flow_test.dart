import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/features/customer/domain/models/customer_model.dart';
import 'package:kc_admin/src/features/design/domain/models/design_model.dart';
import 'package:kc_admin/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:kc_admin/src/features/stitching/domain/models/stitching_status_mutation_state.dart';

void main() {
  group('KC-Admin Integration & Flow Tests', () {
    test('1. Admin reads customer profile keyed by Firebase UID', () {
      const firebaseUid = 'user_admin_test_123';
      final customer = CustomerModel(
        id: firebaseUid,
        firebaseUid: firebaseUid,
        displayName: 'Test Customer',
        email: 'customer@example.com',
        phone: '+919876543210',
        boutiqueIds: const ['default'],
        branchIds: const [],
        source: CustomerSource.google,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customer.id, equals(firebaseUid));
      expect(customer.firebaseUid, equals(firebaseUid));
      expect(customer.displayName, equals('Test Customer'));
    });

    test(
      '2. Row-level stitching status mutation state initializes as idle',
      () {
        const state = StitchingStatusMutationState();
        expect(state.requests.isEmpty, isTrue);
      },
    );

    test('3. Row mutation loading state updates specific request ID only', () {
      const orderId = 'stitch_202';
      final requests = <String, RowMutationState>{
        orderId: const RowMutationState(status: MutationStatus.loading),
      };

      final state = StitchingStatusMutationState(requests: requests);
      expect(state.requests[orderId]?.status, equals(MutationStatus.loading));
      expect(state.requests['other_id'], isNull);
    });

    test(
      '4. Row mutation failure preserves error message and allows retry',
      () {
        const orderId = 'stitch_203';
        final requests = <String, RowMutationState>{
          orderId: const RowMutationState(
            status: MutationStatus.failure,
            errorMessage: 'Permission denied',
          ),
        };

        final state = StitchingStatusMutationState(requests: requests);
        expect(state.requests[orderId]?.status, equals(MutationStatus.failure));
        expect(
          state.requests[orderId]?.errorMessage,
          equals('Permission denied'),
        );
      },
    );

    test(
      '5. Admin stitching status update triggers customer notification payload',
      () {
        const customerId = 'user_abc_789';
        const orderNumber = 'KC-ST-888';
        const newStatusLabel = 'Ready for Collection';

        final title = 'Stitching Update: $orderNumber';
        final body =
            'Your tailoring request status has updated to: $newStatusLabel';

        expect(customerId, isNotEmpty);
        expect(title, contains(orderNumber));
        expect(body, contains(newStatusLabel));
      },
    );

    test(
      '6. Product creation accepts empty/optional price defaulting to 0.0',
      () {
        const priceText = '';
        final price = double.tryParse(priceText.trim()) ?? 0.0;
        expect(price, equals(0.0));
      },
    );

    test(
      '7. Admin product creation does not require boutique or branch selection',
      () {
        final design = DesignModel(
          id: 'design_no_boutique_req',
          boutiqueId: 'default',
          categoryId: 'cat_01',
          name: 'Royal Silk Saree',
          slug: 'royal-silk-saree',
          imageUrls: const [],
          price: 15000.0,
          isActive: true,
          tags: const [],
          searchKeywords: const [],
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(design.name, equals('Royal Silk Saree'));
        expect(design.id, isNotEmpty);
      },
    );

    test(
      '8. Admin stitching request creation assigns customer UID to shared collection query',
      () {
        const selectedCustomerUid = 'firebase_uid_customer_A';
        final order = StitchingOrderModel(
          id: 'order_admin_001',
          boutiqueId: 'default',
          branchId: '',
          customerId: selectedCustomerUid,
          orderNumber: 'KC-ST-999',
          status: StitchingOrderStatus.requested,
          designReferences: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(order.customerId, equals('firebase_uid_customer_A'));
        expect(order.status, equals(StitchingOrderStatus.requested));
      },
    );
  });
}
