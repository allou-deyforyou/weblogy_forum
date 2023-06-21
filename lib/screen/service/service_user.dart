import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '_service.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => const [];
}

class UserStateInit extends UserState {
  const UserStateInit();
}

class UserStatePending extends UserState {
  const UserStatePending();
}

class UserStateFailure extends UserState {
  const UserStateFailure({
    required this.code,
    this.event,
  });
  final UserEvent? event;
  final String code;
  @override
  List<Object?> get props => [code, event];
}

class UserStateSubscription extends UserState {
  const UserStateSubscription({required this.subscription});
  final StreamSubscription subscription;
  @override
  List<Object?> get props => [subscription];
}

class UserStateUserSchemaList extends UserState {
  const UserStateUserSchemaList({required this.data});
  final List<UserSchema> data;
  @override
  List<Object?> get props => [data];
}

class UserStateUserSchema extends UserState {
  const UserStateUserSchema({required this.data});
  final UserSchema data;
  @override
  List<Object?> get props => [data];
}

class UserService extends ValueNotifier<UserState> {
  UserService([super.value = const UserStateInit()]);

  static Future<void> queryCurrentUser() async {
    final currentUser = FirebaseConfig.firebaseAuth.currentUser;
    if (currentUser != null) {
      final userService = UserService();
      await userService.add(UserEventQueryUser(id: currentUser.uid));
      final state = userService.value;
      if (state is UserStateUserSchema) UserService.currentUser.value = state.data;
    }
  }

  static final currentUser = ValueNotifier<UserSchema?>(null);

  static UserService? _instance;
  static UserService instance([UserState state = const UserStateInit()]) {
    return _instance ??= UserService(state);
  }

  Future<void> add(UserEvent event) => event.handle(this);
}

abstract class UserEvent {
  const UserEvent();

  FirebaseFirestore get firebaseFirestore => FirebaseConfig.firebaseFirestore;

  Future<void> handle(UserService service);
}

class UserEventQueryBulkUser extends UserEvent {
  const UserEventQueryBulkUser({
    this.subscription = false,
    this.group = false,
    this.collection,
    this.getOptions,
    // User Fields
    this.createdFrom,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.email,
  });

  final CollectionReference<UserSchema?>? collection;
  final GetOptions? getOptions;
  final bool subscription;
  final bool group;

  // User Fields
  final DateTime? createdFrom;
  final DateTime? createdAt;
  final String? firstName;
  final String? lastName;
  final String? email;

  @override
  Future<void> handle(UserService service) async {
    try {
      service.value = const UserStatePending();
      final collectionReference = collection ??
          (group
              ? UserSchema.toFirestoreQuery(
                  firebaseFirestore.collectionGroup(UserSchema.schema),
                )
              : UserSchema.toFirestoreCollection(
                  firebaseFirestore.collection(UserSchema.schema),
                ));
      var query = collectionReference
          .where(
            UserSchema.firstNameKey,
            isEqualTo: firstName,
          )
          .where(
            UserSchema.lastNameKey,
            isEqualTo: lastName,
          )
          .where(
            UserSchema.emailKey,
            isEqualTo: email,
          );
      if (createdFrom != null || createdAt != null) {
        query = query.startAt(
          [createdFrom],
        ).endAt(
          [createdAt],
        ).orderBy(
          UserSchema.createdAtKey,
        );
      } else if (createdAt != null) {
        query = query.where(
          UserSchema.createdAtKey,
          isEqualTo: createdAt,
        );
      }
      if (subscription) {
        final streamSubscription = query.snapshots().listen((snapshot) {
          final data = snapshot.docs.where((doc) => doc.exists).map((doc) => doc.data()).toList();
          service.value = UserStateUserSchemaList(data: data.cast());
        });
        service.value = UserStateSubscription(subscription: streamSubscription);
      } else {
        final snapshot = await query.get(getOptions);
        final data = snapshot.docs.where((doc) => doc.exists).map((doc) => doc.data()).toList();
        service.value = UserStateUserSchemaList(data: data.cast());
      }
    } catch (error) {
      service.value = UserStateFailure(code: error.toString());
    }
  }
}

class UserEventQueryUser extends UserEvent {
  const UserEventQueryUser({
    this.subscription = false,
    this.getOptions,
    this.document,
    this.id,
  });

  final DocumentReference<UserSchema?>? document;
  final GetOptions? getOptions;
  final bool subscription;
  final String? id;

  @override
  Future<void> handle(UserService service) async {
    try {
      service.value = const UserStatePending();
      final documentReference = document ??
          UserSchema.toFirestoreDocument(
            firebaseFirestore.doc('${UserSchema.schema}/$id'),
          );
      if (subscription) {
        final streamSubscription = documentReference.snapshots().listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            service.value = UserStateUserSchema(data: data);
          }
        });
        service.value = UserStateSubscription(subscription: streamSubscription);
      }
      final snapshot = await documentReference.get(getOptions);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        service.value = UserStateUserSchema(
            data: data.copyWith(
          document: documentReference,
        ));
      } else {
        service.value = const UserStateFailure(code: "no-found");
      }
    } catch (error) {
      service.value = UserStateFailure(code: error.toString());
    }
  }
}

class UserEventCreateUser extends UserEvent {
  const UserEventCreateUser({
    required this.data,
    required this.id,
    this.collection,
  });

  final CollectionReference<UserSchema?>? collection;
  final UserSchema data;
  final String id;

  @override
  Future<void> handle(UserService service) async {
    try {
      service.value = const UserStatePending();
      final document = collection?.doc(id) ??
          UserSchema.toFirestoreDocument(
            firebaseFirestore.doc('${UserSchema.schema}/$id'),
          );
      await document.set(data);
      service.value = UserStateUserSchema(data: data.copyWith(document: document));
    } catch (error) {
      service.value = UserStateFailure(code: error.toString());
    }
  }
}

class UserEventUpdateUser extends UserEvent {
  const UserEventUpdateUser({
    required this.data,
    // User Fields
    this.createdAt,
    this.firstName,
    this.lastName,
    this.email,
  });

  final UserSchema data;
  // User Fields
  final DateTime? createdAt;
  final String? firstName;
  final String? lastName;
  final String? email;

  @override
  Future<void> handle(UserService service) async {
    try {
      service.value = const UserStatePending();
      await data.document!.update({
        UserSchema.firstNameKey: firstName,
        UserSchema.lastNameKey: lastName,
        UserSchema.emailKey: email,
        UserSchema.createdAtKey: createdAt,
      }..removeWhere((key, value) => value == null));
      service.value = UserStateUserSchema(
        data: data.copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          createdAt: createdAt,
        ),
      );
    } catch (error) {
      service.value = UserStateFailure(code: error.toString());
    }
  }
}

class UserEventDeleteUser extends UserEvent {
  const UserEventDeleteUser({
    required this.data,
  });

  final UserSchema data;

  @override
  Future<void> handle(UserService service) async {
    try {
      service.value = const UserStatePending();
      await data.document!.delete();
      service.value = UserStateUserSchema(data: data);
    } catch (error) {
      service.value = UserStateFailure(code: error.toString());
    }
  }
}
