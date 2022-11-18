class BleDevice {
  final String name;
  final int timestamp;
  final int rssi;
  final double distance;

  BleDevice({required this.name, required this.timestamp, required this.rssi, required this.distance});
}