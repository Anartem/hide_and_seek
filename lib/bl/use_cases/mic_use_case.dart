import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

enum MicStatus {
  permissionDenied,
  permissionGranted,
}

class MicUseCase extends Disposable {
  final StreamController<MicStatus> _statusController = StreamController();
  Stream<MicStatus> get statusStream => _statusController.stream;

  final StreamController<double> _noiseController = StreamController();
  Stream<double> get noiseStream => _noiseController.stream;

  StreamSubscription<NoiseReading>? _noiseSubscription;
  final NoiseMeter _noiseMeter = NoiseMeter();

  void checkPermissions({bool needRequest = false}) async {
    PermissionStatus status = await Permission.microphone.status;

    if (status == PermissionStatus.denied) {
      if (needRequest) status = await Permission.microphone.request();
    }

    if (status == PermissionStatus.granted) {
      _statusController.add(MicStatus.permissionGranted);
    } else {
      _statusController.add(MicStatus.permissionDenied);
    }
  }

  void start() {
    _noiseSubscription ??= _noiseMeter.noiseStream.listen(_onData);
  }

  void stop() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
  }

  void _onData(NoiseReading data) {
    _noiseController.add(data.meanDecibel);
  }

  @override
  void dispose() {
    _statusController.close();
  }
}