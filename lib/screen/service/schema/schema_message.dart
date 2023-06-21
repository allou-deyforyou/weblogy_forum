import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '_schema.dart';

enum MessageType {
  text,
  audio,
  image,
  video,
  document,
  unknown;

  static MessageType fromString(String value) {
    switch (value) {
      case 'text':
        return text;
      case 'audio':
        return audio;
      case 'image':
        return image;
      case 'video':
        return video;
      case 'document':
        return document;
      default:
        return unknown;
    }
  }

  @override
  String toString() {
    return name;
  }
}

class MessageSchema extends Equatable {
  const MessageSchema({
    this.document,

    ///
    this.type,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  static const String schema = 'messaging';

  static const String typeKey = 'type';
  static const String contentKey = 'content';
  static const String createdAtKey = 'created_at';
  static const String updatedAtKey = 'updated_at';

  final DocumentReference<MessageSchema?>? document;

  DocumentReference<UserSchema?> get user => UserSchema.toFirestoreDocument(
        document!.parent.parent!,
      );

  final String? content;
  final MessageType? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        document,
        // content,
        type,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return toMap().toString();
  }

  MessageSchema copyWith({
    DocumentReference<MessageSchema?>? document,

    ///
    String? content,
    MessageType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageSchema(
      document: document ?? this.document,

      ///
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  MessageSchema clone() {
    return copyWith(
      document: document,

      ///
      type: type,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<MessageSchema> fromMapList(List<Map<String, dynamic>> data) {
    return List.of(data.map((data) => fromMap(data)));
  }

  static MessageSchema fromMap(Map<String, dynamic> data) {
    return MessageSchema(
      content: data[contentKey],
      type: MessageType.fromString(data[typeKey]),
      createdAt: (data[createdAtKey] as Timestamp?)?.toDate(),
      updatedAt: (data[updatedAtKey] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      contentKey: content,
      typeKey: type?.name,
      createdAtKey: createdAt ?? FieldValue.serverTimestamp(),
      updatedAtKey: updatedAt ?? FieldValue.serverTimestamp(),
    }..removeWhere((key, value) => value == null);
  }

  static List<MessageSchema> fromJsonList(List<Map<String, dynamic>> data) {
    return List.of(data.map((data) => fromMap(data)));
  }

  static MessageSchema fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static DocumentReference<MessageSchema?> toFirestoreDocument(DocumentReference<Map<String, dynamic>> reference) {
    return reference.withConverter<MessageSchema?>(
      toFirestore: (value, options) {
        return value!.toMap();
      },
      fromFirestore: (snapshot, options) {
        final data = snapshot.data();
        return data != null ? fromMap(data) : null;
      },
    );
  }

  static CollectionReference<MessageSchema?> toFirestoreCollection(CollectionReference<Map<String, dynamic>> reference) {
    return reference.withConverter<MessageSchema?>(
      toFirestore: (value, options) {
        return value!.toMap();
      },
      fromFirestore: (snapshot, options) {
        final data = snapshot.data();
        return data != null ? fromMap(data) : null;
      },
    );
  }

  static Query<MessageSchema?> toFirestoreQuery(Query<Map<String, dynamic>> query) {
    return query.withConverter<MessageSchema?>(
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
