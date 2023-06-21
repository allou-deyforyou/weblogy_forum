import 'package:jiffy/jiffy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_tools/service_tools.dart';

import 'screen/_screen.dart';

void main() => runService(const MyService()).whenComplete(() => UserService.queryCurrentUser()).whenComplete(() => runApp(const MyApp()));

class MyService extends FlutterService {
  const MyService();
  @override
  Future<void> development() {
    return Future.wait([
      FirebaseConfig.development(),
      Jiffy.setLocale("Fr"),
    ]);
  }

  @override
  Future<void> production() {
    return Future.wait([
      FirebaseConfig.production(),
      Jiffy.setLocale("Fr"),
    ]);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Assets
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      refreshListenable: UserService.currentUser,
      routes: [
        GoRoute(
          path: HomeScreen.path,
          name: HomeScreen.name,
          pageBuilder: (context, state) {
            return const CupertinoPage(
              child: HomeScreen(),
            );
          },
          redirect: (context, state) {
            if (UserService.currentUser.value == null) return AuthScreen.path;
            return null;
          },
        ),
        GoRoute(
          path: AuthScreen.path,
          name: AuthScreen.name,
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: AuthScreen(),
            );
          },
          routes: [
            GoRoute(
              path: AuthSignupScreen.path,
              name: AuthSignupScreen.name,
              pageBuilder: (context, state) {
                return const CupertinoPage(
                  child: AuthSignupScreen(),
                );
              },
            ),
            GoRoute(
              path: AuthPasswordForgottenScreen.path,
              name: AuthPasswordForgottenScreen.name,
              pageBuilder: (context, state) {
                return const CupertinoPage(
                  child: AuthPasswordForgottenScreen(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: Themes.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
