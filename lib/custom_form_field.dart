import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD8E7FF)),
        prefixIcon: Icon(icon, color: const Color(0xFFD8E7FF)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.14),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        errorStyle: const TextStyle(color: Color(0xFFFFCC00)),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFCC00)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
