import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '_service.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => const [];
}

class AuthStateInit extends AuthState {
  const AuthStateInit();
}

class AuthStatePending extends AuthState {
  const AuthStatePending();
}

class AuthStateFailure extends AuthState {
  const AuthStateFailure({
    required this.code,
    this.event,
  });

  final AuthEvent? event;
  final String code;
  @override
  List<Object?> get props => [event, code];
}

class AuthStateUserSigned extends AuthState {
  const AuthStateUserSigned({required this.user});
  final User user;
  @override
  List<Object?> get props => [user];
}

class AuthStatePasswordResetEmailSended extends AuthState {
  const AuthStatePasswordResetEmailSended();
}

class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

class AuthService extends ValueNotifier<AuthState> {
  AuthService([AuthState value = const AuthStateInit()]) : super(value);

  static AuthService? _instance;
  static AuthService instance([AuthState state = const AuthStateInit()]) {
    return _instance ??= AuthService(state);
  }

  Future<void> add(AuthEvent event) => event.handle(this);
}

abstract class AuthEvent {
  const AuthEvent();

  FirebaseAuth get firebaseAuth => FirebaseConfig.firebaseAuth;

  Future<void> handle(AuthService service);
}

class AuthEventCreateUserWithEmailAndPassword extends AuthEvent {
  const AuthEventCreateUserWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  Future<void> handle(AuthService service) async {
    try {
      service.value = const AuthStatePending();
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        password: password,
        email: email,
      );
      service.value = AuthStateUserSigned(user: credential.user!);
    } catch (error) {
      service.value = AuthStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class AuthEventSendPasswordResetEmail extends AuthEvent {
  const AuthEventSendPasswordResetEmail({
    required this.email,
  });

  final String email;

  @override
  Future<void> handle(AuthService service) async {
    try {
      service.value = const AuthStatePending();
      await firebaseAuth.sendPasswordResetEmail(email: email);
      service.value = const AuthStatePasswordResetEmailSended();
    } catch (error) {
      service.value = AuthStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class AuthEventSigninWithEmailPassword extends AuthEvent {
  const AuthEventSigninWithEmailPassword({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
  @override
  Future<void> handle(AuthService service) async {
    try {
      service.value = const AuthStatePending();
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        password: password,
        email: email,
      );
      service.value = AuthStateUserSigned(user: credential.user!);
    } on FirebaseAuthException catch (error) {
      service.value = AuthStateFailure(
        code: error.code,
        event: this,
      );
    }
  }
}

class AuthEventSignIn extends AuthEvent {
  AuthEventSignIn({
    required this.verificationId,
    required this.smsCode,
    this.credential,
  });

  AuthCredential? credential;
  final String verificationId;
  final String smsCode;

  @override
  Future<void> handle(AuthService service) async {
    try {
      service.value = const AuthStatePending();
      credential ??= PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await firebaseAuth.signInWithCredential(credential!);
      service.value = AuthStateUserSigned(user: firebaseAuth.currentUser!);
    } catch (error) {
      service.value = AuthStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}

class AuthEventSignOut extends AuthEvent {
  const AuthEventSignOut();

  FirebaseFirestore get firebaseFirestore => FirebaseConfig.firebaseFirestore;

  @override
  Future<void> handle(AuthService service) async {
    try {
      service.value = const AuthStatePending();
      UserService.currentUser.value = null;
      await firebaseAuth.signOut();
      await firebaseFirestore.clearPersistence();
      service.value = const AuthStateSignedOut();
    } catch (error) {
      service.value = AuthStateFailure(
        code: error.toString(),
        event: this,
      );
    }
  }
}
