import 'package:flutter/material.dart';

class AccountSelector extends StatelessWidget {
  final String fromAccount;
  final String toAccount;
  final VoidCallback? onSelectFrom;
  final VoidCallback? onSelectTo;
  const AccountSelector({
    super.key,
    required this.fromAccount,
    required this.toAccount,
    this.onSelectFrom,
    this.onSelectTo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: onSelectFrom,
            child: Text(
              'Dari: $fromAccount',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: onSelectTo,
            child: Text(
              'Ke: $toAccount',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
