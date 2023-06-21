import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:widget_tools/widget_tools.dart';

import '_widget.dart';

class HomeAppBar extends CustomAppBar {
  const HomeAppBar({
    super.key,
    required this.name,
    this.onLeadingPressed,
    this.onTrailingPressed,
  });

  final String name;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      centerTitle: true,
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      leading: IconButton(
        onPressed: onLeadingPressed,
        icon: CircleAvatar(
          radius: 15.0,
          child: FittedBox(
            child: Text(name),
          ),
        ),
      ),
      title: const Text("Weblogy Forum"),
      actions: [
        IconButton(
          splashRadius: 20.0,
          onPressed: onTrailingPressed,
          icon: const Icon(
            Icons.logout,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ],
    );
  }
}

class HomeLogoutModal extends StatelessWidget {
  const HomeLogoutModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Deconnexion"),
      content: const Text("Êtes-vous sûr(e) de vouloir vous deconnecter maintenant ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Deconnecter"),
        ),
      ],
    );
  }
}

class HomeBottomAppBar extends StatelessWidget {
  const HomeBottomAppBar({
    super.key,
    required this.controller,
    this.onSenderPressed,
  });

  final TextEditingController controller;
  final VoidCallback? onSenderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        Flexible(
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 4,
                    minLines: 1,
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Tapez ici...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, textValue, child) {
                    return IconButton.filled(
                      onPressed: textValue.text.trim().isNotEmpty ? onSenderPressed : null,
                      icon: const Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomeMessageWidget extends StatelessWidget {
  const HomeMessageWidget({
    super.key,
    required this.content,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.isSender = false,
  });

  final bool isSender;
  final String? firstName;
  final String? lastName;
  final DateTime? createdAt;
  final String content;

  String _getDateTimeFormat(BuildContext context) {
    final now = DateTime.now();
    final isSameDay = DateUtils.isSameDay(createdAt, now);
    final isSameWeek = CustomDateUtils.isSameWeek(createdAt!, now);
    final jiffy = Jiffy.parseFromDateTime(createdAt!);

    return isSameDay
        ? TimeOfDay.fromDateTime(createdAt!).format(context)
        : isSameWeek
            ? DateFormat('EEEE').format(createdAt!)
            : jiffy.yMEd;
  }

  Widget _circleAvatarChild() {
    return Visibility(
      visible: firstName != null && lastName != null,
      child: Builder(
        builder: (context) {
          return Text(
            "${lastName![0]}${firstName![0]}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              child: _circleAvatarChild(),
            ),
          ),
        Flexible(
          child: MessagingBubbleBackground(
            isSender: isSender,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Visibility(
                      visible: firstName != null && lastName != null,
                      child: Builder(
                        builder: (context) {
                          return Text(
                            "$lastName $firstName",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      _getDateTimeFormat(context),
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                ],
              ),
              subtitle: Text(content),
            ),
          ),
        ),
        if (isSender)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              child: _circleAvatarChild(),
            ),
          ),
        if (!isSender) const SizedBox(width: 16.0),
      ],
    );
  }
}

class MessagingBubbleBackground extends StatelessWidget {
  const MessagingBubbleBackground({
    super.key,
    this.isSender = true,
    required this.child,
  });

  final bool isSender;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Container(
          color: isSender ? CupertinoColors.systemGrey5 : const Color(0xFFBBF0FE),
          child: child,
        ),
      ),
    );
  }
}
