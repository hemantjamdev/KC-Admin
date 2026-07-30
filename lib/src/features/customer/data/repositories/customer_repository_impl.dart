import '../../data/datasources/customer_firestore_data_source.dart';
import '../../domain/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

/// Concrete implementation of [CustomerRepository] using Firestore.
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl({CustomerFirestoreDataSource? dataSource})
    : _dataSource = dataSource ?? CustomerFirestoreDataSource();

  final CustomerFirestoreDataSource _dataSource;

  @override
  Future<CustomerModel?> getCustomerById(String id) {
    return _dataSource.fetchById(id);
  }

  @override
  Future<CustomerModel?> getCustomerByFirebaseUid(String firebaseUid) {
    return _dataSource.fetchByFirebaseUid(firebaseUid);
  }

  @override
  Future<List<CustomerModel>> getCustomersForAdmin({
    String? boutiqueId,
    bool? isActive,
    CustomerSource? source,
    String? searchQuery,
  }) async {
    final list = await _dataSource.fetchAll(
      boutiqueId: boutiqueId,
      isActive: isActive,
      source: source,
    );

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      return list.where((c) {
        final inName = c.displayName.toLowerCase().contains(q);
        final inEmail = c.email != null && c.email!.toLowerCase().contains(q);
        final inPhone = c.phone != null && c.phone!.contains(q);
        return inName || inEmail || inPhone;
      }).toList();
    }

    return list;
  }

  @override
  Future<({List<CustomerModel> items, String? lastDocId, bool hasMore})> fetchPaginatedCustomers({
    int limit = 20,
    String? startAfterId,
  }) {
    return _dataSource.fetchPaginated(limit: limit, startAfterId: startAfterId);
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    await _dataSource.create(customer);
    return customer;
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    await _dataSource.update(customer);
    return customer;
  }

  @override
  Future<void> setCustomerActiveStatus(
    String customerId,
    bool isActive,
    String updatedBy,
  ) {
    return _dataSource.setActiveStatus(customerId, isActive, updatedBy);
  }
}
