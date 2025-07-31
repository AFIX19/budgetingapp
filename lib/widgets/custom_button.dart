import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const Custombutton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = Colors.yellow,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          ),
        ),
      onPressed: onPressed,
      child: Text(
        label,
        style:TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }
}