import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/bl/use_cases/ble_use_case.dart';
import 'package:hide_and_seek/bl/use_cases/mic_use_case.dart';
import 'package:hide_and_seek/modules/seek/seek_bloc.dart';
import 'package:hide_and_seek/modules/seek/seek_page.dart';

class SeekModule extends Module {
  static const route = "/seek";

  @override
  List<Bind<Object>> get binds => [
    Bind((i) => BleUseCase()),
    Bind((i) => MicUseCase()),
    Bind((i) => SeekBloc(Modular.get(), Modular.get())),
  ];

  @override
  List<ModularRoute> get routes => [
    RedirectRoute(route, to: "$route/"),
    ChildRoute("/", child: (_, __) => const SeekPage()),
  ];
}