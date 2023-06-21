import 'package:flutter/material.dart';
import 'package:listenable_tools/listenable_tools.dart';
import '_screen.dart';

class HomeMessageListTile extends StatefulWidget {
  const HomeMessageListTile({
    super.key,
    required this.message,
    this.isSender = false,
  });

  final MessageSchema message;
  final bool isSender;

  @override
  State<HomeMessageListTile> createState() => _HomeMessageListTileState();
}

class _HomeMessageListTileState extends State<HomeMessageListTile> {
  /// Assets
  late MessageSchema _message;

  /// UserService
  late UserService _userService;
  UserSchema? _user;

  Future<void> _queryUser() {
    return _userService.add(UserEventQueryUser(document: _message.user));
  }

  void _listenUserState(BuildContext context, UserState state) {
    if (state is UserStateUserSchema) _user = state.data;
  }

  void _initialize() {
    /// Assets
    _message = widget.message;

    /// UserService
    _userService = UserService();

    _queryUser();
  }

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  @override
  void didUpdateWidget(covariant HomeMessageListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableConsumer(
      listener: _listenUserState,
      valueListenable: _userService,
      builder: (context, state, child) {
        return HomeMessageWidget(
          firstName: _user?.firstName,
          lastName: _user?.lastName,
          createdAt: _message.createdAt,
          isSender: widget.isSender,
          content: _message.content!,
        );
      },
    );
  }
}
