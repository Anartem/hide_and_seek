import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/modules/app/chooser_page.dart';
import 'package:hide_and_seek/modules/hide/hide_module.dart';
import 'package:hide_and_seek/modules/seek/seek_module.dart';

class AppModule extends Module {
  static const route = "/";

  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
    ChildRoute(ChooserPage.route, child:(_, __) => const ChooserPage()),
    ModuleRoute(HideModule.route, module: HideModule()),
    ModuleRoute(SeekModule.route, module: SeekModule()),
  ];
}