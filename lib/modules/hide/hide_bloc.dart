import 'package:flutter_modular/flutter_modular.dart';
import 'package:hide_and_seek/bl/use_cases/advert_use_case.dart';
import 'package:hide_and_seek/bl/use_cases/audio_use_case.dart';
import 'package:rxdart/rxdart.dart';

enum HideMode {
  audio,
  advert,
  none,
}

class HideBloc implements Disposable {
  final AudioUseCase _audioUseCase;
  final AdvertUseCase _advertUseCase;

  final BehaviorSubject<HideMode> _modeController = BehaviorSubject.seeded(HideMode.none);
  Stream<HideMode> get modeStream => _modeController.stream;

  Stream<AdvertStatus> get advertStatusStream => _advertUseCase.statusStream;

  HideBloc(this._audioUseCase, this._advertUseCase);

  void checkPermissions({bool needRequest = false}) {
    _advertUseCase.checkPermissions(needRequest: needRequest);
  }

  void toggleAudio() {
    _modeController.add(HideMode.audio);
    _advertUseCase.stopAdvert();
    _audioUseCase.startPlay();
  }

  void toggleAdvert() {
    _modeController.add(HideMode.advert);
    _advertUseCase.startAdvert();
    _audioUseCase.stopPlay();
  }

  void stopAll() {
    _modeController.add(HideMode.none);
    _advertUseCase.stopAdvert();
    _audioUseCase.stopPlay();
  }

  @override
  void dispose() {
    _modeController.close();
  }
}