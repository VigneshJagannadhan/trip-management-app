import 'package:flutter/material.dart';
import 'package:trippify/core/theme/app_styles.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: ts14CFFFW400,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(label: Text(label, style: ts14CFFFW400)),
    );
  }
}
