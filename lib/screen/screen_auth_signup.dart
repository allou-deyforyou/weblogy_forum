import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class AuthSignupScreen extends StatefulWidget {
  const AuthSignupScreen({super.key, this.user});

  final UserSchema? user;

  static const name = "auth-signup";
  static const path = "signup";

  @override
  State<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends State<AuthSignupScreen> {
  /// Assets
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final ValueNotifier<bool> _obscuredPasswordController;
  late final ValueNotifier<bool> _obscuredconfirmPasswordController;

  late final GlobalKey<FormState> _formkey;
  late ScaffoldMessengerState _scaffoldMessenger;

  void _pushAuthScreen() async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return const AuthSignupSuccessModal();
      },
    );
    if (mounted) context.goNamed(HomeScreen.name);
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
  late User _currentAuthUser;

  void _listenAuthState(BuildContext context, AuthState state) {
    if (state is AuthStateUserSigned) {
      _currentAuthUser = state.user;
      _queryUser(_currentAuthUser);
    } else if (state is AuthStateFailure) {
      _showSnackbar("Oops, cet utilisateur existe déjà, connectez-vous");
    }
  }

  Future<void> _createAuthUser() async {
    if (_formkey.currentState!.validate()) {
      return _authService.add(
        AuthEventCreateUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  Future<void> _updateAuthUser() async {
    if (_formkey.currentState!.validate()) {
      return _authService.add(
        AuthEventCreateUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  /// UserService
  late final UserService _userService;
  late final UserService _userQueryService;

  void _listenUserQueryState(BuildContext context, UserState state) {
    if (state is UserStateUserSchema) {
      _showSnackbar("Oops, cet utilisateur existe déjà. Connectez-vous");
    } else if (state is UserStateFailure) {
      switch (state.code) {
        case "no-found":
          _createUser(_currentAuthUser);
          break;
        default:
      }
    }
  }

  void _listenUserState(BuildContext context, UserState state) {
    if (state is UserStateUserSchema) {
      _pushAuthScreen();
    } else if (state is UserStateFailure) {
      _showSnackbar("Une erreur s'est produite, merci de réessayer");
    }
  }

  Future<void> _queryUser(User user) {
    return _userQueryService.add(
      UserEventQueryUser(id: user.uid),
    );
  }

  Future<void> _createUser(User user) {
    return _userService.add(
      UserEventCreateUser(
        data: UserSchema(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: user.email!,
        ),
        id: user.uid,
      ),
    );
  }

  Future<void> _updateUser() {
    return _userQueryService.add(
      UserEventUpdateUser(
        data: widget.user!,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _emailController = TextEditingController(text: widget.user?.email);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _obscuredPasswordController = ValueNotifier(true);
    _obscuredconfirmPasswordController = ValueNotifier(true);

    _formkey = GlobalKey();

    /// AuthService
    _authService = AuthService();

    /// UserService
    _userService = UserService();
    _userQueryService = UserService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.user != null ? const AuthEditAppBar() : const AuthSignupAppBar(),
      bottomNavigationBar: ValueListenableConsumer(
        listener: _listenUserQueryState,
        valueListenable: _userQueryService,
        builder: (context, userQueryState, child) {
          return ValueListenableConsumer(
            listener: _listenUserState,
            valueListenable: _userService,
            builder: (context, userState, child) {
              return ValueListenableConsumer(
                listener: _listenAuthState,
                valueListenable: _authService,
                builder: (context, authState, child) {
                  VoidCallback? onPressed = _createAuthUser;
                  if (authState is AuthStatePending || userState is UserStatePending) onPressed = null;
                  return AuthSignUpSubmitButton(
                    onPressed: onPressed,
                  );
                },
              );
            },
          );
        },
      ),
      body: Form(
        key: _formkey,
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverToBoxAdapter(
              child: AuthSignUpFirstNameTextField(
                controller: _firstNameController,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 6.0)),
            SliverToBoxAdapter(
              child: AuthSignUpLastNameTextField(
                controller: _lastNameController,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 6.0)),
            SliverToBoxAdapter(
              child: AuthSignUpEmailTextField(
                controller: _emailController,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 6.0)),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: _obscuredPasswordController,
                builder: (context, obscured, child) {
                  return AuthSignUpPasswordTextField(
                    obscureText: obscured,
                    controller: _passwordController,
                    onSuffixIconPressed: () {
                      _obscuredPasswordController.value = !obscured;
                    },
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 6.0)),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: _obscuredconfirmPasswordController,
                builder: (context, obscured, child) {
                  return AuthSignUpConfirmPasswordTextField(
                    obscureText: obscured,
                    controller: _confirmPasswordController,
                    onSuffixIconPressed: () {
                      _obscuredconfirmPasswordController.value = !obscured;
                    },
                    validator: (value) {
                      if (value != _passwordController.text) return "Les mots de passe ne correspondent pas";
                      return null;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
