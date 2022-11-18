import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioUseCase implements Disposable {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final Completer<Uint8List> _completer = Completer();

  AudioUseCase() {
    _player.openPlayer();
    rootBundle.load("assets/song.wav").then((data) => _completer.complete(data.buffer.asUint8List()));
  }

  Future<void> startPlay() {
    return _completer.future.then((data) => _player.startPlayer(fromDataBuffer: data, whenFinished: startPlay));
  }

  Future<void> stopPlay() {
    return _player.stopPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
  }
}