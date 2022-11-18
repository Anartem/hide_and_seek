import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/modules/seek/seek_bloc.dart';

class NoiseWidget extends StatelessWidget {
  static const Duration _duration = Duration(milliseconds: 100);

  SeekBloc get _bloc => Modular.get();

  const NoiseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        StreamBuilder(
          stream: _bloc.noiseStream,
          builder: (context, snapshot) {
            double noise = snapshot.data ?? 0;
            double ratio = (max(40.0, min(80.0, noise)) - 40.0) / 40.0;
            return Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              child: AnimatedContainer(
                margin: const EdgeInsets.all(16),
                duration: _duration,
                width: 48.0 * ratio + 48.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTween(
                    begin: Theme.of(context).colorScheme.surfaceVariant,
                    end: Theme.of(context).colorScheme.tertiary,
                  ).lerp(ratio),
                ),
              ),
            );
          },
        ),
        Icon(Icons.mic, color: Theme.of(context).colorScheme.onTertiary),
      ],
    );
  }
}
