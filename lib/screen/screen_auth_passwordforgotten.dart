import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class AuthPasswordForgottenScreen extends StatefulWidget {
  const AuthPasswordForgottenScreen({super.key});

  static const name = "auth-passwordforgotten";
  static const path = "passwordforgotten";

  @override
  State<AuthPasswordForgottenScreen> createState() => _AuthPasswordForgottenScreenState();
}

class _AuthPasswordForgottenScreenState extends State<AuthPasswordForgottenScreen> {
  /// Assets
  late final TextEditingController _emailController;
  late final GlobalKey<FormState> _formkey;
  late ScaffoldMessengerState _scaffoldMessenger;

  void _pushAuthScreen() async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return const AuthPasswordForgottenSuccessModal();
      },
    );
    if (mounted) context.goNamed(AuthScreen.name);
  }

  void _showSnackbar(String data) {
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(data),
      ),
    );
  }

  /// AuthService
  late final AuthService _authService;

  void _listenAuthState(BuildContext context, AuthState state) {
    if (state is AuthStatePasswordResetEmailSended) {
      _pushAuthScreen();
    } else if (state is AuthStateFailure) {
      switch (state.code) {
        case "auth/user-not-found":
          _showSnackbar("Ce compte n'existe pas, verifiez votre email");
          break;
        default:
      }
      _showSnackbar("Une erreur s'est produite, merci de réessayer");
    }
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    return _authService.add(
      AuthEventSendPasswordResetEmail(
        email: email,
      ),
    );
  }

  /// UserService
  late final UserService _userService;

  void _listenUserState(BuildContext context, UserState state) {
    if (state is UserStateUserSchemaList) {
      if (state.data.isNotEmpty) {
        _sendPasswordResetEmail(state.data.first.email);
      } else {
        _showSnackbar("Ce compte n'existe pas, réessayez");
      }
    } else if (state is UserStateFailure) {
      _showSnackbar("Une erreur s'est produite, merci de réessayer");
    }
  }

  Future<void> _queryBulkUser() async {
    if (_formkey.currentState!.validate()) {
      return _userService.add(
        UserEventQueryBulkUser(
          email: _emailController.text,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _emailController = TextEditingController();

    _formkey = GlobalKey();

    /// AuthService
    _authService = AuthService();

    /// UserService
    _userService = UserService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthPasswordForgottenAppBar(),
      bottomNavigationBar: ValueListenableConsumer(
        listener: _listenUserState,
        valueListenable: _userService,
        builder: (context, userState, child) {
          return ValueListenableConsumer(
            listener: _listenAuthState,
            valueListenable: _authService,
            builder: (context, authState, child) {
              VoidCallback? onPressed = _queryBulkUser;
              if (authState is AuthStatePending || userState is UserStatePending) onPressed = null;
              return AuthPasswordForgottenSubmitButton(
                onPressed: onPressed,
              );
            },
          );
        },
      ),
      body: Form(
        key: _formkey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AuthPasswordForgottenEmailTextField(
                controller: _emailController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
