import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/models/ble_device.dart';
import 'package:hide_and_seek/bl/use_cases/ble_use_case.dart';
import 'package:hide_and_seek/bl/use_cases/mic_use_case.dart';

class SeekBloc implements Disposable {
  final BleUseCase _bleUseCase;
  final MicUseCase _micUseCase;

  Stream<bool> get activeStream => _bleUseCase.activeStream;
  Stream<BleStatus> get bleStatusStream => _bleUseCase.statusStream;
  Stream<List<BleDevice>> get bleStream => _bleUseCase.deviceStream;
  Stream<double> get noiseStream => _micUseCase.noiseStream;

  SeekBloc(this._bleUseCase, this._micUseCase);

  void checkPermissions({needRequest = false}) {
    _bleUseCase.checkPermissions(needRequest: needRequest);
  }

  void start() {
    _bleUseCase.startScan();
    _micUseCase.start();
  }

  void stop() {
    _bleUseCase.stopScan();
    _micUseCase.stop();
  }

  @override
  void dispose() {
  }
}