import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetting_app/providers/user_provider.dart';
import 'package:budgetting_app/presentation/screens/auth/register_page.dart';
import 'package:budgetting_app/services/auth_service.dart';
import 'widgets/login_form_field.dart';
import 'widgets/login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();              //key untuk validasi form
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();

  // String? _emailError;
  // String? _passwordError;
  
  bool _isObscure = true;
  bool _isLoading = false;


  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

  final validation = AuthService.validateLogin(
    _emailController.text.trim(),
    _passwordController.text.trim(),
);


if (validation != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(validation)),
  );
  return; // stop di sini
}

    setState(() => _isLoading = true);
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    // panggil authservice sign in
    final error = await AuthService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Berhasil! Selamat Datang Gaes!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // pindah ke halaman home
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Kelola keuanganmu dengan mudah!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),

              // form email
              LoginFormField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                isPassword: false,
                obscureText: false,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Email tidak boleh kosong"
                    : null,
              ),
              const SizedBox(height: 20),

              // form password
              LoginFormField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock,
                isPassword: true,
                obscureText: _isObscure,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Password tidak boleh kosong"
                    : null,
                onToggleVisibility: () {
                  setState(() => _isObscure = !_isObscure);
                },
              ),

              const SizedBox(height: 20),

              // tombol login
              LoginButton(
                isLoading: _isLoading, 
                onPressed: _submitAuthForm
                ),

              const SizedBox(height: 15),

              // tombol ke arah register
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );

                  //reset form & field  ketika kembali dari register
                  _formKey.currentState?.reset();
                  _emailController.clear();
                  _passwordController.clear();

                  setState(() {
                    _isObscure = true;
                    _isLoading = false;
                  });
                },
                child: const Text(
                  'Belum punya akun? Daftar Sekarang',
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
