import 'package:budgetting_app/presentation/screens/auth/widgets/register_button.dart';
import 'package:budgetting_app/presentation/screens/auth/widgets/register_form_field.dart';
import 'package:flutter/material.dart';
import 'package:budgetting_app/services/auth_service.dart';
import 'package:budgetting_app/presentation/screens/main/main_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // panggil authservice register
    final result = await AuthService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _confirmController.text.trim(),
    );

    if (mounted) {
      if (result == null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
      } else {
        setState(() => _errorMessage = result);
      }
    }

    setState(() => _isLoading = false);
  }

  // membersihkan controller saat widget di dispose biar tidak bocor memory
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Daftar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, //validasi form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              //form input modular
              RegisterFormField(
                emailController: _emailController,
                passwordController: _passwordController,
                confirmController: _confirmController,
              ),

              const SizedBox(height: 20),

              //menampilkan message error jia ada
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              //button
              RegisterButton(isLoading: _isLoading, onPressed: _register),
              
              SizedBox(height: 10),

              // tombol ke arah login
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Sudah punya akun? Login",
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
