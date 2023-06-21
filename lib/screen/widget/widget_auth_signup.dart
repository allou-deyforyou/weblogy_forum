import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widget_tools/widget_tools.dart';

class AuthSignupAppBar extends CustomAppBar {
  const AuthSignupAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Créer un compte"),
    );
  }
}

class AuthEditAppBar extends CustomAppBar {
  const AuthEditAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Modifier mon compte"),
    );
  }
}

class AuthSignUpFirstNameTextField extends StatelessWidget {
  const AuthSignUpFirstNameTextField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        controller: controller,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) return "Le prénom est obligatoire";
          return null;
        },
        decoration: const InputDecoration(
          labelText: "Prénom *",
          hintText: "Entrez votre prénom",
        ),
      ),
    );
  }
}

class AuthSignUpLastNameTextField extends StatelessWidget {
  const AuthSignUpLastNameTextField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        controller: controller,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) return "Le nom est obligatoire";
          return null;
        },
        decoration: const InputDecoration(
          labelText: "Nom *",
          hintText: "Entrez votre nom",
        ),
      ),
    );
  }
}

class AuthSignUpEmailTextField extends StatelessWidget {
  const AuthSignUpEmailTextField({
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
          labelText: "Email *",
          hintText: "Entrez votre email",
        ),
      ),
    );
  }
}

class AuthSignUpPasswordTextField extends StatelessWidget {
  const AuthSignUpPasswordTextField({
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
        obscureText: obscureText,
        controller: controller,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value == null || value.isEmpty) return "Le mot de passe est obligatoire";
          if (value.length < 8) return "Mot de passe doit être au moins de 8 caractères";
          return null;
        },
        decoration: InputDecoration(
          labelText: "Mot de passe *",
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

class AuthSignUpConfirmPasswordTextField extends StatelessWidget {
  const AuthSignUpConfirmPasswordTextField({
    super.key,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.onSuffixIconPressed,
  });

  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool obscureText;

  final VoidCallback? onSuffixIconPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        obscureText: obscureText,
        controller: controller,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value == null || value.isEmpty) return "La confirmation du mot de passe est obligatoire";
          return validator?.call(value);
        },
        decoration: InputDecoration(
          labelText: "Confirmer le mot de passe *",
          hintText: "confirmer le mot de passe",
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

class AuthSignUpSubmitButton extends StatelessWidget {
  const AuthSignUpSubmitButton({
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

class AuthSignupSuccessModal extends StatelessWidget {
  const AuthSignupSuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("L'inscription a reussi"),
      content: const Text("Votre inscription s'est passsée avec succès, vous serez redirigé(e) vers la page de connexion"),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Ok"),
        ),
      ],
    );
  }
}
