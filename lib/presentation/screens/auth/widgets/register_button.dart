import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final bool isLoading; //menandakan apakah proses pendaftaran sedang berlangsung
  final VoidCallback onPressed; //fungsi yang dipanggil saat tombol ditekan

  const RegisterButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

// button
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.black)
          : const Text(
              'Daftar',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
  
}
