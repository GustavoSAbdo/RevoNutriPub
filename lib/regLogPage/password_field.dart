import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText; // Adicionando o parâmetro para o texto do rótulo
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
    required this.labelText, // Tornando o labelText obrigatório
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText, // Usando o labelText fornecido
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      obscureText: _obscureText,
      validator: widget.validator,
    );
  }
}
