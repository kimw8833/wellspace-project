import 'package:just_audio/just_audio.dart';

/// Handles ONLY the ambient "room music".
/// - Loads asset once
/// - Loops continuously
/// - Exposes volume + play/pause/stop
class RoomAudioService {
  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  String? _loadedAssetPath;

  /// Call once on app start or when entering the room the first time.
  Future<void> init({
    String assetPath = 'assets/sound/music/wellspace.wav',
    double initialVolume = 0.6,
    bool loop = true,
  }) async {
    if (_initialized && _loadedAssetPath == assetPath) {
      // Still apply volume in case settings changed.
      await _player.setVolume(_clamp01(initialVolume));
      return;
    }

    _loadedAssetPath = assetPath;

    // Load the audio asset.
    await _player.setAsset(assetPath);

    // Loop forever (or not).
    await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);

    // Set initial volume.
    await _player.setVolume(_clamp01(initialVolume));

    _initialized = true;
  }

  bool get isInitialized => _initialized;
  bool get isPlaying => _player.playing;

  double get volume => _player.volume;

  Future<void> play() async {
    if (!_initialized) {
      throw StateError('RoomAudioService.play() called before init().');
    }
    await _player.play();
  }

  Future<void> pause() async {
    if (!_initialized) return;
    await _player.pause();
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _player.stop();
  }

  Future<void> setVolume(double value) async {
    await _player.setVolume(_clamp01(value));
  }

  /// Optional: nice for room transitions.
  Future<void> fadeTo(double targetVolume,
      {Duration duration = const Duration(milliseconds: 400),
      int steps = 20}) async {
    final start = _player.volume;
    final end = _clamp01(targetVolume);

    if (steps <= 0) {
      await _player.setVolume(end);
      return;
    }

    final stepMs = (duration.inMilliseconds / steps).round().clamp(1, 1000000);
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final v = start + (end - start) * t;
      await _player.setVolume(_clamp01(v));
      await Future.delayed(Duration(milliseconds: stepMs));
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  double _clamp01(double v) => v.clamp(0.0, 1.0);
}
