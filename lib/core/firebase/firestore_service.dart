import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_list/models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Contact> contactsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('contacts').withConverter<Contact>(
          fromFirestore: (snapshot, _) => Contact.fromMap(snapshot.data()!),
          toFirestore: (contact, _) => contact.toMap(),
        );
  }

  Stream<List<Contact>> getContacts(String userId) {
    return contactsRef(userId).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addContact(String userId, Contact contact) async {
    final docRef = await contactsRef(userId).add(contact);
    await docRef.update({'id': docRef.id});
  }

  Future<void> deleteContact(String userId, String contactId) async {
    await contactsRef(userId).doc(contactId).delete();
  }
}
