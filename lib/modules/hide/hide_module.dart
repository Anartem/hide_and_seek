import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/bl/use_cases/advert_use_case.dart';
import 'package:hide_and_seek/bl/use_cases/audio_use_case.dart';
import 'package:hide_and_seek/modules/hide/hide_bloc.dart';
import 'package:hide_and_seek/modules/hide/hide_page.dart';

class HideModule extends Module {
  static const route = "/hide";

  @override
  List<Bind<Object>> get binds => [
    Bind((i) => AudioUseCase()),
    Bind((i) => AdvertUseCase()),
    Bind((i) => HideBloc(Modular.get(), Modular.get())),
  ];

  @override
  List<ModularRoute> get routes => [
    RedirectRoute(route, to: "$route/"),
    ChildRoute("/", child: (_, __) => const HidePage()),
  ];
}