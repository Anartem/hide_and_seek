import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hide_and_seek/models/ble_device.dart';

class BleWidget extends StatelessWidget {
  final BleDevice device;

  const BleWidget({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double ratio = (max(1, min(8, device.distance)) - 1) / 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(device.name),
            ),
            Text(
              "~${device.distance.toStringAsFixed(1)} м",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ColorTween(
                      begin: Theme.of(context).colorScheme.tertiary,
                      end: Theme.of(context).colorScheme.surfaceVariant,
                    ).lerp(ratio),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
