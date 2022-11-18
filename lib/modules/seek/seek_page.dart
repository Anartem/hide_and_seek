import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/models/ble_device.dart';
import 'package:hide_and_seek/bl/use_cases/ble_use_case.dart';
import 'package:hide_and_seek/modules/seek/ble_widget.dart';
import 'package:hide_and_seek/modules/seek/noise_widget.dart';
import 'package:hide_and_seek/modules/seek/seek_bloc.dart';

class SeekPage extends StatefulWidget {
  const SeekPage({Key? key}) : super(key: key);

  @override
  State<SeekPage> createState() => _SeekPageState();
}

class _SeekPageState extends State<SeekPage> with WidgetsBindingObserver {
  late final SeekBloc _bloc = Modular.get();

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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _bloc.bleStatusStream,
                builder: (context, snapshot) {
                  final BleStatus? status = snapshot.data;

                  if (status == null) {
                    return const SizedBox.shrink();
                  }

                  if (status == BleStatus.permissionGranted) {
                    return StreamBuilder(
                      stream: _bloc.bleStream,
                      builder: (context, snapshot) {
                        List<BleDevice> list = snapshot.data ?? [];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: StreamBuilder(
                                stream: _bloc.activeStream,
                                builder: (context, snapshot) {
                                  return snapshot.data == true
                                      ? ElevatedButton(
                                          onPressed: _bloc.stop,
                                          child: const Text("Остановить поиск"),
                                        )
                                      : ElevatedButton(
                                          onPressed: _bloc.start,
                                          child: const Text("Начать поиск"),
                                        );
                                },
                              ),
                            ),
                            Container(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                "Ищите устройства, ориентируясь на примерное расстояние и индикатор шума",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.all(16),
                                children: List.generate(
                                  list.length,
                                  (index) => BleWidget(device: list[index]),
                                ),
                              ),
                            ),
                            Container(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
                            const NoiseWidget(),
                          ],
                        );
                      },
                    );
                  }

                  if (status == BleStatus.locationDisabled) {
                    return const MaterialBanner(
                      padding: EdgeInsets.all(16),
                      content: Text("Включите локацию для поиска"),
                      actions: [
                        TextButton(
                          onPressed: AppSettings.openLocationSettings,
                          child: Text("Настройки"),
                        ),
                      ],
                    );
                  }

                  if (status == BleStatus.bluetoothDisabled) {
                    return const MaterialBanner(
                      padding: EdgeInsets.all(16),
                      content: Text("Включите блютус для поиска"),
                      actions: [
                        TextButton(
                          onPressed: AppSettings.openBluetoothSettings,
                          child: Text("Настройки"),
                        ),
                      ],
                    );
                  }

                  return const MaterialBanner(
                    padding: EdgeInsets.all(16),
                    content: Text("Для поиска приложению требуется доступ к локации, блютусу и микрофону"),
                    actions: [
                      TextButton(
                        onPressed: AppSettings.openAppSettings,
                        child: Text("Настройки"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
