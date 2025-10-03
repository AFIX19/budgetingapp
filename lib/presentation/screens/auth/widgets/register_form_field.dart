import 'package:flutter/material.dart';
import 'package:budgetting_app/services/auth_service.dart';

class RegisterFormField extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  const RegisterFormField({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
  });

  @override
  State<RegisterFormField> createState() => _RegisterFormFieldState();
}

class _RegisterFormFieldState extends State<RegisterFormField> {
  //untuk mengatur visibilitas password (true = tertutup/hidden)
  bool _isObscure = true;
  bool _isObscure2 = true;

  // fungsi untuk styling input field biar rapi
  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.yellow),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[800]!), //border default
        borderRadius: BorderRadius.circular(10),
      ),

      // border saat aktif
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellow),
        borderRadius: BorderRadius.circular(10),
      ),

      // border saat error
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),

      // border saat error dan aktif
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // field email
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Email", Icons.email),
          validator: (value) => AuthService.validateEmail(value ?? ''),
        ),
        const SizedBox(height: 20),

        // field password
        TextFormField(
          controller: widget.passwordController,
          obscureText: _isObscure,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            "Password",
            Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.yellow,
              ),
              onPressed: () {
                setState(() => _isObscure = !_isObscure);
              },
            ),
          ),
          validator: (value) => AuthService.validatePassword(value ?? ''),
        ),
        const SizedBox(height: 20),

        // field confirm password
        TextFormField(
          controller: widget.confirmController,
          obscureText: _isObscure2,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            "Konfirmasi Password",
            Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                // tombol toggle show & hide password
                _isObscure2 
                ? Icons.visibility_off 
                : Icons.visibility,
                color: Colors.yellow,
              ),
              onPressed: () {
                setState(() => _isObscure2 = !_isObscure2);
              },
            ),
          ),
          validator: (value) => AuthService.validateConfirmPassword(
            value ?? '',  //nilai yang dimasukkan user
            widget.passwordController.text,   //mencocokkan dengan password utama
          ),
        ),
      ],
    );
  }
}
