import 'dart:async';

enum CelebrationType { sparkle, mascotDance, kingdomGrow, sticker }

class CelebrationService {
  static final CelebrationService _instance = CelebrationService._internal();
  factory CelebrationService() => _instance;
  CelebrationService._internal();

  final _controller = StreamController<CelebrationType>.broadcast();
  Stream<CelebrationType> get stream => _controller.stream;

  void trigger(CelebrationType type) {
    _controller.add(type);
  }
}