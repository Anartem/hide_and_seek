import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/modules/hide/hide_module.dart';
import 'package:hide_and_seek/modules/seek/seek_module.dart';

class ChooserPage extends StatelessWidget {
  static const route = "/chooser";

  const ChooserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Modular.to.pushReplacementNamed(HideModule.route),
                child: const Text("Спрятаться"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Modular.to.pushReplacementNamed(SeekModule.route),
                child: const Text("Искать"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
