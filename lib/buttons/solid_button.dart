import 'package:flutter/material.dart';

class SolidButton extends StatelessWidget {
  const SolidButton({
    required this.onPressed,
    required this.label,
    this.icon,
    super.key,
  });

  final void Function() onPressed;
  final Widget? icon;
  final String label;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon,
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[100],
      foregroundColor: Colors.blue[900],
      padding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
