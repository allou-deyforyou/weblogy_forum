import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthIcon extends StatelessWidget {
  const AuthIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Icon(Icons.mail, size: 60.0),
        const SizedBox(height: 12.0),
        Text(
          "Weblogy Forum",
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class AuthEmailTextField extends StatelessWidget {
  const AuthEmailTextField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
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
    );
  }
}

class AuthPasswordForgottenListTile extends StatelessWidget {
  const AuthPasswordForgottenListTile({
    super.key,
    this.onPressed,
  });
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: TextButton(
        onPressed: onPressed,
        child: const Text("Mot de passe oublié ?"),
      ),
    );
  }
}

class AuthPasswordTextField extends StatelessWidget {
  const AuthPasswordTextField({
    super.key,
    this.controller,
    this.obscureText = false,
    this.onSuffixIconPressed,
  });

  final TextEditingController? controller;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value == null || value.isEmpty) return "Le mot de passe est obligatoire";
          if (value.length < 8) return "Mot de passe doit être au moins de 8 caractères";
          return null;
        },
        decoration: InputDecoration(
          labelText: "Mot de passe",
          hintText: "Entrez un mot de passe",
          suffixIcon: ExcludeFocus(
            child: IconButton(
              onPressed: onSuffixIconPressed,
              icon: Visibility(
                visible: obscureText,
                replacement: const Icon(CupertinoIcons.eye_slash_fill),
                child: const Icon(CupertinoIcons.eye_fill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FilledButton(
        onPressed: onPressed,
        child: Visibility(
          visible: onPressed != null,
          replacement: SizedBox.fromSize(
            size: const Size.fromRadius(12.0),
            child: const CircularProgressIndicator(strokeWidth: 2.0),
          ),
          child: const Text("Me Connecter"),
        ),
      ),
    );
  }
}

class AuthSignupButton extends StatelessWidget {
  const AuthSignupButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: OutlinedButton(
        onPressed: onPressed,
        child: const Text("Créer un compte Weblogy"),
      ),
    );
  }
}
