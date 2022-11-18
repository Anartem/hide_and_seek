import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/bl/use_cases/advert_use_case.dart';
import 'package:hide_and_seek/modules/hide/hide_bloc.dart';
import 'package:hide_and_seek/modules/hide/toggle_widget.dart';

class HidePage extends StatefulWidget {
  const HidePage({Key? key}) : super(key: key);

  @override
  State<HidePage> createState() => _HidePageState();
}

class _HidePageState extends State<HidePage> with WidgetsBindingObserver {
  late final HideBloc _bloc = Modular.get();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _bloc.checkPermissions(needRequest: true);
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bloc.checkPermissions();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<HideMode>(
          stream: _bloc.modeStream,
          builder: (context, snapshot) {
            HideMode? mode = snapshot.data;

            if (mode == null) {
              return const SizedBox.shrink();
            }

            return StreamBuilder<AdvertStatus>(
              stream: _bloc.advertStatusStream,
              builder: (context, snapshot) {
                AdvertStatus? status = snapshot.data;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: mode == HideMode.none
                          ? ElevatedButton(
                              onPressed: _bloc.toggleAudio,
                              child: const Text("Спрятаться"),
                            )
                          : ElevatedButton(
                              onPressed: _bloc.stopAll,
                              child: const Text("Перестать играть"),
                            ),
                    ),
                    Container(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
                    if (status == AdvertStatus.permissionDenied)
                      const MaterialBanner(
                        content: Text("Приложению нужна локацию и блютус для беззвучных пряток"),
                        actions: [
                          TextButton(
                            onPressed: AppSettings.openAppSettings,
                            child: Text("Настройки"),
                          ),
                        ],
                      ),
                    if (status == AdvertStatus.bluetoothDisabled)
                      const MaterialBanner(
                        content: Text("Включите блютус для беззвучных пряток"),
                        actions: [
                          TextButton(
                            onPressed: AppSettings.openBluetoothSettings,
                            child: Text("Настройки"),
                          ),
                        ],
                      ),
                    if (status == AdvertStatus.locationDisabled)
                      const MaterialBanner(
                        content: Text("Включите локацию для беззвучных пряток"),
                        actions: [
                          TextButton(
                            onPressed: AppSettings.openLocationSettings,
                            child: Text("Настройки"),
                          ),
                        ],
                      ),
                    if (status == AdvertStatus.notSupported)
                      const MaterialBanner(
                        content: Text("Телефон не поддерживает блютус объявления :("),
                        actions: [],
                      ),
                    Expanded(
                      child: Center(
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(12),
                          textStyle: Theme.of(context).textTheme.titleSmall,
                          isSelected: [mode == HideMode.audio, mode == HideMode.advert],
                          onPressed: (index) => index == 0 ? _onAudio() : _onAdvert(status),
                          children: const [
                            ToggleWidget(title: "Чирикать", icon: Icons.music_note),
                            ToggleWidget(title: "Без звука", icon: Icons.bluetooth),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onAudio() {
    _bloc.toggleAudio();
  }

  void _onAdvert(AdvertStatus? status) {
    if (status == AdvertStatus.permissionGranted) {
      _bloc.toggleAdvert();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Сейчас не доступно"),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
