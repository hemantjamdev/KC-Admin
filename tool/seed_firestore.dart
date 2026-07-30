import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:kc_admin/firebase_options.dart';

/// Standalone development-only Firestore database seed utility for KC-Admin.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;

  debugPrint('--- Starting Firestore Development Seeding ---');

  const boutiqueId = 'boutique_kc_main';
  const branchId = 'branch_kc_central';

  // 1. Seed Boutique
  await db.collection('boutiques').doc(boutiqueId).set({
    'id': boutiqueId,
    'name': 'Kapada Creation Flagship',
    'code': 'KC-MAIN',
    'ownerName': 'Kapada Boutique Admin',
    'contactEmail': 'contact@kapadacreation.com',
    'contactPhone': '+91 98765 43210',
    'address': 'Main Palace Road, High Street',
    'city': 'Mumbai',
    'state': 'Maharastra',
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  debugPrint('Seeded Boutique: $boutiqueId');

  // 2. Seed Branch
  await db.collection('branches').doc(branchId).set({
    'id': branchId,
    'boutiqueId': boutiqueId,
    'name': 'Central Studio',
    'code': 'KC-CS',
    'address': 'Suite 101, Palace Road',
    'city': 'Mumbai',
    'phone': '+91 98765 43211',
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  debugPrint('Seeded Branch: $branchId');

  // 3. Seed Categories
  const category1Id = 'cat_lehenga';
  await db.collection('categories').doc(category1Id).set({
    'id': category1Id,
    'boutiqueId': boutiqueId,
    'name': 'Bridal Lehengas',
    'slug': 'bridal-lehengas',
    'description':
        'Handcrafted designer lehengas for weddings and grand events.',
    'sortOrder': 1,
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  const category2Id = 'cat_saree';
  await db.collection('categories').doc(category2Id).set({
    'id': category2Id,
    'boutiqueId': boutiqueId,
    'name': 'Designer Sarees',
    'slug': 'designer-sarees',
    'description': 'Silk, organza, and embroidered designer sarees.',
    'sortOrder': 2,
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  debugPrint('Seeded Categories: $category1Id, $category2Id');

  // 4. Seed Designs
  const design1Id = 'design_royal_velvet';
  await db.collection('designs').doc(design1Id).set({
    'id': design1Id,
    'boutiqueId': boutiqueId,
    'categoryId': category1Id,
    'name': 'Royal Velvet Zardozi Lehenga',
    'slug': 'royal-velvet-zardozi-lehenga',
    'shortDescription':
        'Rich crimson velvet lehenga with handcrafted gold zardozi.',
    'description':
        'An exquisite bridal piece tailored in plush silk velvet, detailed with intricate metallic embroidery.',
    'imageUrls': [],
    'tags': ['bridal', 'velvet', 'zardozi'],
    'searchKeywords': ['lehenga', 'bridal', 'red', 'zardozi'],
    'sortOrder': 1,
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  const design2Id = 'design_silk_saree';
  await db.collection('designs').doc(design2Id).set({
    'id': design2Id,
    'boutiqueId': boutiqueId,
    'categoryId': category2Id,
    'name': 'Pure Kanjeevaram Gold Silk Saree',
    'slug': 'pure-kanjeevaram-gold-silk-saree',
    'shortDescription': 'Traditional woven silk saree with pure zari border.',
    'description':
        'Woven with traditional heritage motifs in vibrant emerald green and gold.',
    'imageUrls': [],
    'tags': ['silk', 'saree', 'traditional'],
    'searchKeywords': ['saree', 'silk', 'emerald', 'kanjeevaram'],
    'sortOrder': 2,
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  debugPrint('Seeded Designs: $design1Id, $design2Id');

  // 5. Seed Curated Section
  const sectionId = 'sec_trending';
  await db.collection('sections').doc(sectionId).set({
    'id': sectionId,
    'boutiqueId': boutiqueId,
    'branchId': null,
    'title': 'Trending Collections',
    'subtitle': 'Handpicked bridal and luxury wear for this season',
    'type': 'manual',
    'designIds': [design1Id, design2Id],
    'sortOrder': 1,
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  debugPrint('Seeded Section: $sectionId');

  // 6. Seed Notifications
  const notif1Id = 'notif_welcome';
  await db.collection('notifications').doc(notif1Id).set({
    'id': notif1Id,
    'boutiqueId': boutiqueId,
    'title': 'Welcome to Kapada Creation',
    'body': 'Discover luxury bridal wear and custom tailor stitching services.',
    'type': 'announcement',
    'audienceType': 'allBoutiqueCustomers',
    'customerIds': [],
    'status': 'published',
    'publishedAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'createdBy': 'admin',
  });

  const notif2Id = 'notif_stitching_demo';
  await db.collection('notifications').doc(notif2Id).set({
    'id': notif2Id,
    'boutiqueId': boutiqueId,
    'title': 'Stitching Order Status: IN PROGRESS',
    'body':
        'Your custom tailoring order is currently being stitched by master tailors.',
    'type': 'stitchingUpdate',
    'audienceType': 'allBoutiqueCustomers',
    'customerIds': [],
    'status': 'published',
    'publishedAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'createdBy': 'admin',
  });
  debugPrint('Seeded Notifications: $notif1Id, $notif2Id');

  // 7. Seed Sample Stitching Orders
  const order1Id = 'order_demo_1';
  await db.collection('stitchingOrders').doc(order1Id).set({
    'id': order1Id,
    'boutiqueId': boutiqueId,
    'branchId': branchId,
    'customerId': 'cust_demo_1',
    'customerName': 'Priya Sharma',
    'customerPhone': '+91 98765 11111',
    'orderNumber': 'ORD-1001',
    'status': 'requested',
    'designReferences': [
      {
        'designId': design1Id,
        'designName': 'Royal Velvet Zardozi Lehenga',
        'quantity': 1,
        'notes': 'Custom heavy blouse padding requested',
      }
    ],
    'measurementSummary': {
      'chest': 36.0,
      'waist': 28.0,
      'hip': 38.0,
      'shoulder': 14.5,
      'unit': 'in',
    },
    'notes': 'Urgent delivery required before October wedding.',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  const order2Id = 'order_demo_2';
  await db.collection('stitchingOrders').doc(order2Id).set({
    'id': order2Id,
    'boutiqueId': boutiqueId,
    'branchId': branchId,
    'customerId': 'cust_demo_2',
    'customerName': 'Ananya Mehta',
    'customerPhone': '+91 98765 22222',
    'orderNumber': 'ORD-1002',
    'status': 'accepted',
    'designReferences': [
      {
        'designId': design2Id,
        'designName': 'Pure Kanjeevaram Gold Silk Saree',
        'quantity': 1,
        'notes': 'Designer matching blouse stitching',
      }
    ],
    'notes': 'In cutting and stitching stage at Central Studio.',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  const order3Id = 'order_demo_3';
  await db.collection('stitchingOrders').doc(order3Id).set({
    'id': order3Id,
    'boutiqueId': boutiqueId,
    'branchId': branchId,
    'customerId': 'cust_demo_3',
    'customerName': 'Ritu Verma',
    'customerPhone': '+91 98765 33333',
    'orderNumber': 'ORD-1003',
    'status': 'completed',
    'designReferences': [
      {
        'designId': null,
        'designName': 'Bespoke Anarkali Suit',
        'quantity': 1,
        'notes': 'Handcrafted dupatta border',
      }
    ],
    'notes': 'Quality check passed & handed over to customer.',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  debugPrint('Seeded Stitching Orders: $order1Id, $order2Id, $order3Id');

  debugPrint('--- Firestore Seeding Completed Successfully ---');
}
