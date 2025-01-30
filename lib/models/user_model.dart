import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.createdAt,
    this.updatedAt,
  });

  // Conversão para Firestore (CREATE)
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Atualização parcial (UPDATE)
  Map<String, dynamic> toUpdateFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Criação a partir de Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.metadata.creationTime,
      updatedAt: user.metadata.lastSignInTime,
    );
  }

  // Criação a partir de DocumentSnapshot do Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Cópia com alterações (para atualizações)
  UserModel copyWith({
    String? email,
    String? displayName,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
