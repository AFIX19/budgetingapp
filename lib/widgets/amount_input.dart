import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const AmountInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        hintText: '0',
        hintStyle: TextStyle(color: Colors.grey[700], fontSize: 32, fontWeight: FontWeight.bold),
        border: InputBorder.none,
      ),
    );
  }
}
