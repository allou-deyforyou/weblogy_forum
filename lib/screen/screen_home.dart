import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:listenable_tools/listenable_tools.dart';

import '_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const name = "home";
  static const path = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Assets
  late final TextEditingController _messageTextController;
  late final ScrollController _scrollController;

  void _goToBottomScrollView() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceIn,
    );
  }

  void _onLeadingPressed() async {}

  void _onTrailingPressed() async {
    final data = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const HomeLogoutModal();
      },
    );

    if (data != null && data) {
      _logoutUser();
    }
  }

  /// UserService
  late UserSchema _currentUser;

  /// MessagingService
  late final MessagingService _messagingReceiverService;
  late final MessagingService _messagingSenderService;

  void _listenMessagingState(BuildContext context, MessagingState state) {
    if (state is MessagingStateInit) {
      _queryBulkMessage();
    }
  }

  void _queryBulkMessage() {
    _messagingReceiverService.add(const MessagingEventQueryBulkMessage(
      descendingCreatedAt: false,
      subscription: true,
      group: true,
    ));
  }

  void _sendMessage() async {
    final content = _messageTextController.text;
    await _messagingSenderService.add(MessagingEventCreateMessage(
      data: MessageSchema(content: content, type: MessageType.text),
      collection: _currentUser.messages,
    ));
    _messageTextController.clear();
    _goToBottomScrollView();
  }

  /// AuthService
  late final AuthService _authService;

  void _listenAuthState(BuildContext context, AuthState state) {
    if (state is AuthStateSignedOut) {
      context.goNamed(HomeScreen.name);
    }
  }

  Future<void> _logoutUser() {
    return _authService.add(const AuthEventSignOut());
  }

  @override
  void initState() {
    super.initState();

    /// Assets
    _messageTextController = TextEditingController();
    _scrollController = ScrollController();

    /// UserService
    _currentUser = UserService.currentUser.value!;

    /// MessagingService
    _messagingReceiverService = MessagingService();
    _messagingSenderService = MessagingService();

    /// AuthService
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableListener(
      listener: _listenAuthState,
      valueListenable: _authService,
      child: Scaffold(
        appBar: HomeAppBar(
          onLeadingPressed: _onLeadingPressed,
          onTrailingPressed: _onTrailingPressed,
          name: "${_currentUser.lastName[0]}${_currentUser.firstName[0]}",
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  ValueListenableConsumer(
                    autoListen: true,
                    listener: _listenMessagingState,
                    valueListenable: _messagingReceiverService,
                    builder: (context, state, child) {
                      return switch (state) {
                        MessagingStateMessageSchemaList(data: List<MessageSchema> data) => SliverVisibility(
                            visible: data.isNotEmpty,
                            replacementSliver: const SliverFillRemaining(
                              child: Center(
                                child: Text("Aucun poste"),
                              ),
                            ),
                            sliver: SliverPadding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              sliver: SliverList.separated(
                                itemBuilder: (context, index) {
                                  final item = data[index];
                                  final isSender = item.user.path == _currentUser.document!.path;
                                  return HomeMessageListTile(
                                    isSender: isSender,
                                    message: item,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 12.0);
                                },
                                itemCount: data.length,
                              ),
                            ),
                          ),
                        MessagingStatePending() => const SliverToBoxAdapter(),
                        _ => const SliverToBoxAdapter(),
                      };
                    },
                  ),
                ],
              ),
            ),
            HomeBottomAppBar(
              controller: _messageTextController,
              onSenderPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
