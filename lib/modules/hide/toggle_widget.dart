import 'package:flutter/material.dart';

class ToggleWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const ToggleWidget({required this.title, required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Text(title),
        ],
      ),
    );
  }
}
