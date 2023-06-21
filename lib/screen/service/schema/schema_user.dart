import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '_schema.dart';

class UserSchema extends Equatable {
  const UserSchema({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImage,
    this.createdAt,
    this.document,
  });

  static const String schema = 'users';

  static const String firstNameKey = 'first_name';
  static const String lastNameKey = 'last_name';
  static const String emailKey = 'email';
  static const String createdAtKey = 'created_at';
  static const String profileImageKey = 'profile_image';

  final DocumentReference<UserSchema?>? document;

  CollectionReference<MessageSchema?> get messages => MessageSchema.toFirestoreCollection(
        document!.collection(MessageSchema.schema),
      );

  final String firstName;
  final String lastName;
  final String email;
  final DateTime? createdAt;
  final String? profileImage;

  @override
  List<Object?> get props {
    return [
      firstName,
      lastName,
      email,
      createdAt,
      document,
      profileImage,
    ];
  }

  UserSchema copyWith({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? createdAt,
    String? profileImage,
    DocumentReference<UserSchema?>? document,
  }) {
    return UserSchema(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      document: document ?? this.document,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  UserSchema clone() {
    return copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      createdAt: createdAt,
      document: document,
      profileImage: profileImage,
    );
  }

  static UserSchema fromMap(Map<String, dynamic> data) {
    return UserSchema(
      firstName: data[firstNameKey],
      lastName: data[lastNameKey],
      email: data[emailKey],
      profileImage: data[profileImageKey],
      createdAt: (data[createdAtKey] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      firstNameKey: firstName,
      lastNameKey: lastName,
      emailKey: email,
      createdAtKey: createdAt ?? FieldValue.serverTimestamp(),
      profileImageKey: profileImage,
    }..removeWhere((key, value) => value == null);
  }

  static List<UserSchema> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static UserSchema fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  static String toListJson(List<UserSchema> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static DocumentReference<UserSchema?> toFirestoreDocument(DocumentReference<Map<String, dynamic>> document) {
    return document.withConverter<UserSchema?>(
      fromFirestore: (snapshot, options) {
        final data = snapshot.data();
        return data != null ? fromMap(data) : null;
      },
      toFirestore: (value, options) {
        return value!.toMap();
      },
    );
  }

  static CollectionReference<UserSchema?> toFirestoreCollection(CollectionReference<Map<String, dynamic>> document) {
    return document.withConverter<UserSchema?>(
      fromFirestore: (snapshot, options) {
        final data = snapshot.data();
        return data != null ? fromMap(data) : null;
      },
      toFirestore: (value, options) {
        return value!.toMap();
      },
    );
  }

  static Query<UserSchema?> toFirestoreQuery(Query<Map<String, dynamic>> query) {
    return query.withConverter<UserSchema?>(
      fromFirestore: (snapshot, options) {
        final data = snapshot.data();
        return data != null ? fromMap(data) : null;
      },
      toFirestore: (value, options) {
        return value!.toMap();
      },
    );
  }
}
