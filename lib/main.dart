import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/modules/app/app_module.dart';
import 'package:hide_and_seek/modules/app/app_page.dart';
import 'package:hide_and_seek/modules/app/chooser_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Modular.setInitialRoute(ChooserPage.route);

  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppPage(),
    ),
  );
}
