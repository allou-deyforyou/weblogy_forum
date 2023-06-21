import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const name = "auth";
  static const path = "/auth";

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  /// Assets
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final ValueNotifier<bool> _obscuredPasswordController;
  late ScaffoldMessengerState _scaffoldMessenger;

  late final GlobalKey<FormState> _formkey;

  void _showSnackbar(String data) {
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(data),
      ),
    );
  }

  void _pushAuthSignup() {
    context.pushNamed(AuthSignupScreen.name);
  }

  void _pushAuthPasswordForgotten() {
    context.pushNamed(AuthPasswordForgottenScreen.name);
  }

  /// AuthService
  late final AuthService _authService;

  void _listenAuthState(BuildContext context, AuthState state) {
    if (state is AuthStateUserSigned) {
      _queryUser(state.user);
    } else if (state is AuthStateFailure) {
      switch (state.code) {
        case "user-not-found":
          _showSnackbar("Ce compte n'existe pas, créez-en.");
          break;
        case "wrong-password":
          _showSnackbar("L'email et le mot de passe ne correspondent pas.");
          break;
        default:
      }
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (_formkey.currentState!.validate()) {
      return _authService.add(
        AuthEventSigninWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  /// UserService
  late final UserService _userService;

  void _listenUserState(BuildContext context, UserState state) {
    if (state is UserStateUserSchema) {
      UserService.currentUser.value = state.data;
      context.goNamed(HomeScreen.name);
    } else if (state is UserStateFailure) {}
  }

  Future<void> _queryUser(User user) {
    return _userService.add(
      UserEventQueryUser(id: user.uid),
    );
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _obscuredPasswordController = ValueNotifier(true);

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
      body: Center(
        heightFactor: 4.0,
        child: Form(
          key: _formkey,
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              const SliverToBoxAdapter(
                child: AuthIcon(),
              ),
              const SliverToBoxAdapter(child: AspectRatio(aspectRatio: 10.0)),
              SliverToBoxAdapter(
                child: AuthEmailTextField(
                  controller: _emailController,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: _obscuredPasswordController,
                  builder: (context, obscured, child) {
                    return AuthPasswordTextField(
                      obscureText: obscured,
                      controller: _passwordController,
                      onSuffixIconPressed: () {
                        _obscuredPasswordController.value = !obscured;
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: AuthPasswordForgottenListTile(
                  onPressed: _pushAuthPasswordForgotten,
                ),
              ),
              const SliverToBoxAdapter(child: AspectRatio(aspectRatio: 5.0)),
              SliverToBoxAdapter(
                child: ValueListenableConsumer(
                  listener: _listenUserState,
                  valueListenable: _userService,
                  builder: (context, userState, child) {
                    return ValueListenableConsumer(
                      listener: _listenAuthState,
                      valueListenable: _authService,
                      builder: (context, authState, child) {
                        VoidCallback? onPressed = _signInWithEmailPassword;
                        if (authState is AuthStatePending || userState is UserStatePending) onPressed = null;
                        return AuthSubmitButton(
                          onPressed: onPressed,
                        );
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: AuthSignupButton(
                  onPressed: _pushAuthSignup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
