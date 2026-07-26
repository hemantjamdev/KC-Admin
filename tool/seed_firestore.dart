import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:kc_admin/firebase_options.dart';

/// Standalone development-only Firestore database seed utility for KC-Admin.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    'description': 'Handcrafted designer lehengas for weddings and grand events.',
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
    'shortDescription': 'Rich crimson velvet lehenga with handcrafted gold zardozi.',
    'description': 'An exquisite bridal piece tailored in plush silk velvet, detailed with intricate metallic embroidery.',
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
    'description': 'Woven with traditional heritage motifs in vibrant emerald green and gold.',
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

  debugPrint('--- Firestore Seeding Completed Successfully ---');
}
