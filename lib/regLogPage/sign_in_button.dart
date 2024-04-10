import 'package:flutter/material.dart';

class SignInButton extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function signIn;

  SignInButton({required this.formKey, required this.signIn});

  @override
  _SignInButtonState createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              if (widget.formKey.currentState != null &&
                  widget.formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                await widget.signIn();
                if (mounted) setState(() => _isLoading = false);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLoading
            ? Colors.blueGrey
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      child: _isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Text('Entrar'),
    );
  }
}