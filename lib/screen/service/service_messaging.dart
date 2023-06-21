import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '_service.dart';

abstract class MessagingState extends Equatable {
  const MessagingState();
  @override
  List<Object?> get props => const [];
}

class MessagingStateInit extends MessagingState {
  const MessagingStateInit();
}

class MessagingStatePending extends MessagingState {
  const MessagingStatePending();
}

class MessagingStateFailure extends MessagingState {
  const MessagingStateFailure({
    required this.code,
    this.event,
  });
  final MessagingEvent? event;
  final String code;
  @override
  List<Object?> get props => [code, event];
}

class MessagingStateSubscription extends MessagingState {
  const MessagingStateSubscription({required this.subscription});
  final StreamSubscription subscription;
  @override
  List<Object?> get props => [subscription];
}

class MessagingStateMessageSchemaList extends MessagingState {
  const MessagingStateMessageSchemaList({required this.data});
  final List<MessageSchema> data;
  @override
  List<Object?> get props => [data];
}

class MessagingStateMessageSchema extends MessagingState {
  const MessagingStateMessageSchema({required this.data});
  final MessageSchema data;
  @override
  List<Object?> get props => [data];
}

class MessagingService extends ValueNotifier<MessagingState> {
  MessagingService([super.value = const MessagingStateInit()]);

  static MessageSchema? currentMessaging;

  static MessagingService? _instance;
  static MessagingService instance([MessagingState state = const MessagingStateInit()]) {
    return _instance ??= MessagingService(state);
  }

  Future<void> add(MessagingEvent event) => event.handle(this);
}

abstract class MessagingEvent {
  const MessagingEvent();

  FirebaseFirestore get firebaseFirestore => FirebaseConfig.firebaseFirestore;

  Future<void> handle(MessagingService service);
}

class MessagingEventQueryBulkMessage extends MessagingEvent {
  const MessagingEventQueryBulkMessage({
    this.subscription = false,
    this.group = false,
    this.collection,
    this.getOptions,
    // Messaging Fields
    this.descendingCreatedAt,
    this.createdFrom,
    this.createdAt,
    this.content,
    this.type,
  });

  final CollectionReference<MessageSchema?>? collection;
  final GetOptions? getOptions;
  final bool subscription;
  final bool group;

  // Messaging Fields
  final bool? descendingCreatedAt;
  final DateTime? createdFrom;
  final DateTime? createdAt;
  final MessageType? type;
  final String? content;

  @override
  Future<void> handle(MessagingService service) async {
    try {
      service.value = const MessagingStatePending();
      final collectionReference = collection ??
          (group
              ? MessageSchema.toFirestoreQuery(
                  firebaseFirestore.collectionGroup(MessageSchema.schema),
                )
              : MessageSchema.toFirestoreCollection(
                  firebaseFirestore.collection(MessageSchema.schema),
                ));
      var query = collectionReference
          .where(
            MessageSchema.contentKey,
            isEqualTo: content,
          )
          .where(
            MessageSchema.typeKey,
            isEqualTo: type?.name,
          );
      if (createdFrom != null || createdAt != null) {
        query = query.startAt(
          [createdFrom],
        ).endAt(
          [createdAt],
        ).orderBy(
          MessageSchema.createdAtKey,
        );
      } else if (createdAt != null) {
        query = query.where(
          MessageSchema.createdAtKey,
          isEqualTo: createdAt,
        );
      }
      if (descendingCreatedAt != null) {
        query = query.orderBy(
          MessageSchema.createdAtKey,
          descending: descendingCreatedAt!,
        );
      }
      if (subscription) {
        final streamSubscription = query.snapshots().listen((snapshot) {
          final data = snapshot.docs.where((doc) => doc.exists).map((doc) => doc.data()!.copyWith(document: doc.reference)).toList();
          service.value = MessagingStateMessageSchemaList(data: data.cast());
        });
        service.value = MessagingStateSubscription(subscription: streamSubscription);
      } else {
        final snapshot = await query.get(getOptions);
        final data = snapshot.docs.where((doc) => doc.exists).map((doc) => doc.data()).toList();
        service.value = MessagingStateMessageSchemaList(data: data.cast());
      }
    } catch (error) {
      service.value = MessagingStateFailure(code: error.toString());
    }
  }
}

class MessagingEventQueryMessage extends MessagingEvent {
  const MessagingEventQueryMessage({
    this.subscription = false,
    this.getOptions,
    this.document,
    this.id,
  });

  final DocumentReference<MessageSchema?>? document;
  final GetOptions? getOptions;
  final bool subscription;
  final String? id;

  @override
  Future<void> handle(MessagingService service) async {
    try {
      service.value = const MessagingStatePending();
      final documentReference = document ??
          MessageSchema.toFirestoreDocument(
            firebaseFirestore.doc('${MessageSchema.schema}/$id'),
          );
      if (subscription) {
        final streamSubscription = documentReference.snapshots().listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            service.value = MessagingStateMessageSchema(data: data);
          }
        });
        service.value = MessagingStateSubscription(subscription: streamSubscription);
      }
      final snapshot = await documentReference.get(getOptions);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        service.value = MessagingStateMessageSchema(data: data);
      } else {
        service.value = const MessagingStateFailure(code: "no-found");
      }
    } catch (error) {
      service.value = MessagingStateFailure(code: error.toString());
    }
  }
}

class MessagingEventCreateMessage extends MessagingEvent {
  const MessagingEventCreateMessage({
    required this.data,
    this.collection,
  });

  final CollectionReference<MessageSchema?>? collection;
  final MessageSchema data;

  @override
  Future<void> handle(MessagingService service) async {
    try {
      service.value = const MessagingStatePending();
      final collectionReference = collection ??
          MessageSchema.toFirestoreCollection(
            firebaseFirestore.collection(MessageSchema.schema),
          );
      final document = await collectionReference.add(data);
      service.value = MessagingStateMessageSchema(data: data.copyWith(document: document));
    } catch (error) {
      service.value = MessagingStateFailure(code: error.toString());
    }
  }
}

class MessagingEventUpdateMessage extends MessagingEvent {
  const MessagingEventUpdateMessage({
    required this.data,
    // Messaging Fields
    this.createdAt,
    this.content,
    this.type,
  });

  final MessageSchema data;
  // Messaging Fields
  final DateTime? createdAt;
  final MessageType? type;
  final String? content;

  @override
  Future<void> handle(MessagingService service) async {
    try {
      service.value = const MessagingStatePending();
      await data.document!.update({
        MessageSchema.createdAtKey: createdAt,
        MessageSchema.contentKey: content,
        MessageSchema.typeKey: type?.name,
      }..removeWhere((key, value) => value == null));
      service.value = MessagingStateMessageSchema(
        data: data.copyWith(
          content: content,
          type: type,
          createdAt: createdAt,
        ),
      );
    } catch (error) {
      service.value = MessagingStateFailure(code: error.toString());
    }
  }
}

class MessagingEventDeleteMessage extends MessagingEvent {
  const MessagingEventDeleteMessage({
    required this.data,
  });

  final MessageSchema data;

  @override
  Future<void> handle(MessagingService service) async {
    try {
      service.value = const MessagingStatePending();
      await data.document!.delete();
      service.value = MessagingStateMessageSchema(data: data);
    } catch (error) {
      service.value = MessagingStateFailure(code: error.toString());
    }
  }
}
