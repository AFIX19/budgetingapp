import 'package:flutter/material.dart';

class LoginFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleVisibility;
  final Widget? suffixIcon;
  

  const LoginFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.validator,
    this.onToggleVisibility,
    this.suffixIcon,
    });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller : controller,
      obscureText: isPassword ? obscureText : false,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.yellow),
        //kalau field password, menampilkan tombol mata untuk toggle visibility
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.yellow,
                ),
                onPressed: onToggleVisibility,
              )
            : suffixIcon,

        // border saat tidak aktif
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
          borderRadius: BorderRadius.circular(10),
        ),

        // border saat aktif
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.yellow),
          borderRadius: BorderRadius.circular(10),
        ),

        // border saat error
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),

        // border saat error dan aktif
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      )
    );
  }
}