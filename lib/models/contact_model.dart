import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String? id;
  final String name;
  final String cpf;
  final String phone;
  final String address;
  final double lat;
  final double lng;

  Contact({
    this.id,
    required this.name,
    required this.cpf,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'address': address,
      'lat': lat,
      'lng': lng,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      cpf: map['cpf'],
      phone: map['phone'],
      address: map['address'],
      lat: map['lat'],
      lng: map['lng'],
    );
  }

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? '',
      cpf: data['cpf'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
