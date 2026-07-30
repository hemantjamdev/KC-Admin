import '../models/customer_model.dart';

/// Abstract repository defining customer data operations.
abstract class CustomerRepository {
  Future<CustomerModel?> getCustomerById(String id);
  Future<CustomerModel?> getCustomerByFirebaseUid(String firebaseUid);
  Future<List<CustomerModel>> getCustomersForAdmin({
    String? boutiqueId,
    bool? isActive,
    CustomerSource? source,
    String? searchQuery,
  });
  Future<({List<CustomerModel> items, String? lastDocId, bool hasMore})> fetchPaginatedCustomers({
    int limit = 20,
    String? startAfterId,
  });
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> setCustomerActiveStatus(
    String customerId,
    bool isActive,
    String updatedBy,
  );
}
