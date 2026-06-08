import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';

class AddressService {
  AddressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _addresses(String uid) {
    return _firestore.collection('users').doc(uid).collection('addresses');
  }

  Future<List<AddressModel>> getAddresses(String uid) async {
    _checkUid(uid);

    final snapshot = await _addresses(uid).get();
    final addresses = snapshot.docs.map(AddressModel.fromFirestore).toList();
    addresses.sort((first, second) {
      if (first.isDefault != second.isDefault) {
        return first.isDefault ? -1 : 1;
      }
      final firstDate =
          first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondDate =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondDate.compareTo(firstDate);
    });
    return addresses;
  }

  Future<AddressModel?> getDefaultAddress(String uid) async {
    final addresses = await getAddresses(uid);
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  Future<String> saveAddress(String uid, AddressModel address) async {
    _checkUid(uid);

    final collection = _addresses(uid);
    final docRef = address.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(address.id);

    if (address.isDefault) {
      await _clearDefault(uid, exceptId: docRef.id);
    }

    await docRef.set({
      ...address.copyWith(id: docRef.id).toMap(),
      'id': docRef.id,
      'createdAt': address.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  Future<void> setDefaultAddress(String uid, String addressId) async {
    _checkUid(uid);
    if (addressId.trim().isEmpty) return;

    final batch = _firestore.batch();
    final snapshot = await _addresses(uid).get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isDefault': doc.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    _checkUid(uid);
    if (addressId.trim().isEmpty) return;
    await _addresses(uid).doc(addressId).delete();
  }

  Future<void> _clearDefault(String uid, {required String exceptId}) async {
    final snapshot =
        await _addresses(uid).where('isDefault', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.id == exceptId) continue;
      batch.update(doc.reference, {
        'isDefault': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  void _checkUid(String uid) {
    if (uid.trim().isEmpty) {
      throw ArgumentError('User id is required for addresses.');
    }
  }
}
