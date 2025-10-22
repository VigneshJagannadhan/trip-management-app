import 'package:flutter/material.dart';
import 'package:trippify/core/theme/app_styles.dart';

class PasswordFormField extends StatefulWidget {
  PasswordFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  String? Function(String?)? validator;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: ts14CFFFW400,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      decoration: InputDecoration(
        label: Text(widget.label, style: ts14CFFFW400),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
