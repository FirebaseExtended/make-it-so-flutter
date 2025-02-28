import 'package:flutter/material.dart';

class HollowButton extends StatelessWidget {
  const HollowButton({required this.onPressed, required this.label, super.key});

  final void Function() onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.purple[700],
      padding: const EdgeInsets.all(24),
      side: BorderSide(color: Colors.purple[700]!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
