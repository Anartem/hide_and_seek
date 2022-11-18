import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:permission_handler/permission_handler.dart';

enum AdvertStatus {
  bluetoothDisabled,
  notSupported,
  locationDisabled,
  permissionDenied,
  permissionGranted,
}

class AdvertUseCase extends Disposable {
  static const _uuid = "31E4A25E-659E-11ED-9022-0242AC120002";
  static const _identifier = "com.iamanart";

  final StreamController<AdvertStatus> _statusController = StreamController();
  Stream<AdvertStatus> get statusStream => _statusController.stream;

  void checkPermissions({bool needRequest = false}) async {
    bool isOn = BluetoothState.stateOn == await flutterBeacon.bluetoothState;
    if (!isOn) {
      _statusController.add(AdvertStatus.bluetoothDisabled);
      return;
    }

    ServiceStatus serviceStatus = await Permission.location.serviceStatus;
    if (serviceStatus == ServiceStatus.disabled) {
      _statusController.add(AdvertStatus.locationDisabled);
      return;
    }

    List<Permission> list = [];

    PermissionStatus status = await Permission.bluetoothAdvertise.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.bluetoothAdvertise);
    }

    status = await Permission.bluetoothConnect.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.bluetoothConnect);
    }

    status = await Permission.location.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.location);
    }

    if (list.isNotEmpty && needRequest) {
      status = (await list.request()).values.any((status) => status != PermissionStatus.granted)
          ? PermissionStatus.denied
          : PermissionStatus.granted;
    }

    if (status == PermissionStatus.denied) {
      _statusController.add(AdvertStatus.permissionDenied);
      return;
    }

    if (status == PermissionStatus.granted) {
      _statusController.add(AdvertStatus.permissionGranted);
    } else {
      _statusController.add(AdvertStatus.permissionDenied);
    }
  }

  void startAdvert() {
    flutterBeacon.startBroadcast(
      BeaconBroadcast(
        identifier: _identifier,
        proximityUUID: _uuid,
        advertisingTxPowerLevel: AdvertisingTxPowerLevel.mid,
        major: 1,
        minor: 100,
      ),
    );
  }

  void stopAdvert() {
    flutterBeacon.stopBroadcast();
  }

  @override
  void dispose() {
    stopAdvert();
    _statusController.close();
  }
}
