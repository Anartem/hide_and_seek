import 'dart:async';
import 'dart:math';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/models/ble_device.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleStatus {
  bluetoothDisabled,
  locationDisabled,
  permissionDenied,
  permissionGranted,
}

class BleUseCase extends Disposable {
  static const _uuid = "31E4A25E-659E-11ED-9022-0242AC120002";
  static const _identifier = "com.iamanart";

  final StreamController<BleStatus> _statusController = StreamController();
  Stream<BleStatus> get statusStream => _statusController.stream;

  final StreamController<List<BleDevice>> _deviceController = StreamController();
  Stream<List<BleDevice>> get deviceStream => _deviceController.stream;

  final StreamController<bool> _activeController = StreamController();
  Stream<bool> get activeStream => _activeController.stream;

  StreamSubscription<MonitoringResult>? _streamMonitoring;
  StreamSubscription<RangingResult>? _streamRanging;

  final Map<String, BleDevice> _map = {};

  void checkPermissions({bool needRequest = false}) async {
    bool isOn = BluetoothState.stateOn == await flutterBeacon.bluetoothState;
    if (!isOn) {
      _statusController.add(BleStatus.bluetoothDisabled);
      return;
    }

    ServiceStatus serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    if (serviceStatus == ServiceStatus.disabled) {
      _statusController.add(BleStatus.locationDisabled);
      return;
    }

    List<Permission> list = [];

    PermissionStatus status = await Permission.bluetoothScan.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.bluetoothScan);
    }

    status = await Permission.locationWhenInUse.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.locationWhenInUse);
    }

    status = await Permission.bluetoothConnect.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.bluetoothConnect);
    }

    status = await Permission.bluetoothAdvertise.status;

    if (status == PermissionStatus.denied) {
      list.add(Permission.bluetoothAdvertise);
    }

    status = await Permission.microphone.status;

    if (status == PermissionStatus.denied) {
      if (needRequest) status = await Permission.microphone.request();
    }

    if (list.isNotEmpty && needRequest) {
      status = (await list.request()).values.any((status) => status != PermissionStatus.granted)
          ? PermissionStatus.denied
          : PermissionStatus.granted;
    }

    if (status == PermissionStatus.denied) {
      _statusController.add(BleStatus.permissionDenied);
      return;
    }

    if (status == PermissionStatus.granted) {
      _statusController.add(BleStatus.permissionGranted);
    } else {
      _statusController.add(BleStatus.permissionDenied);
    }
  }

  void startScan() async {
    await flutterBeacon.initializeScanning;
    final regions = <Region>[Region(identifier: _identifier, proximityUUID: _uuid)];
    _activeController.add(true);
    _streamRanging ??= flutterBeacon.ranging(regions).listen((RangingResult result) {
      for (Beacon beacon in result.beacons) {
        _onBeacon(beacon);
      }
      int current = DateTime.now().millisecondsSinceEpoch;
      _map.removeWhere((key, value) => current - value.timestamp > 10000);
      _deviceController.add(_map.values.toList());
    });
  }

  void _onBeacon(final Beacon beacon) {
    if (beacon.macAddress == null || beacon.txPower == null) return;

    BleDevice? old = _map[beacon.macAddress!];
    int rssi = beacon.rssi;
    if (old != null) {
      rssi += old.rssi;
      rssi ~/= 2;
    }

    BleDevice device = BleDevice(
      name: beacon.macAddress!,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      rssi: beacon.rssi,
      distance: _calculateDistance(beacon.txPower!, beacon.rssi),
    );

    _map[beacon.macAddress!] = device;
  }

  void stopScan() {
    _activeController.add(false);
    _streamMonitoring?.cancel();
    _streamMonitoring = null;
    _streamRanging?.cancel();
    _streamRanging = null;
  }

  double _calculateDistance(int txPower, int rssi) {
    if (rssi == 0) {
      return -1.0;
    }

    double ratio = rssi * 1.0 / txPower;

    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    }

    else {
      return 0.89976 * pow(ratio, 7.7095) + 0.111;
    }

    //return pow(10.0, (txPower - rssi) / (10.0 * 2.0)) as double;
  }

  @override
  void dispose() {
    stopScan();
    _statusController.close();
    _deviceController.close();
    _activeController.close();
  }
}
