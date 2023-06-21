import 'package:flutter/material.dart';
import 'package:widget_tools/widget_tools.dart';

class AuthPasswordForgottenAppBar extends CustomAppBar {
  const AuthPasswordForgottenAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      title: const Text("Mot de passe oublié ?"),
    );
  }
}

class AuthPasswordForgottenEmailTextField extends StatelessWidget {
  const AuthPasswordForgottenEmailTextField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        "Entrer votre email pour recevoir un lien de modification de votre mot de passe.",
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) return "L'email est obligatoire";
            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
              return "Cet email est invalide";
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: "Email",
            hintText: "Entrez votre email",
          ),
        ),
      ),
    );
  }
}

class AuthPasswordForgottenSubmitButton extends StatelessWidget {
  const AuthPasswordForgottenSubmitButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Divider(),
        Flexible(
          child: ListTile(
            title: FilledButton(
              onPressed: onPressed,
              child: Visibility(
                visible: onPressed != null,
                replacement: SizedBox.fromSize(
                  size: const Size.fromRadius(12.0),
                  child: const CircularProgressIndicator(strokeWidth: 2.0),
                ),
                child: const Text("Suivant"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPasswordForgottenSuccessModal extends StatelessWidget {
  const AuthPasswordForgottenSuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modification de mot de passe"),
      content: const Text("Un lien vous a été envoyé pour la réinitialisation de votre mot de passe."),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Ok"),
        ),
      ],
    );
  }
}
