import 'package:just_audio/just_audio.dart';

class NotificationSoundPlayer {
  static final NotificationSoundPlayer _instance = NotificationSoundPlayer._internal();
  factory NotificationSoundPlayer() => _instance;
  NotificationSoundPlayer._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentSound;

  Future<void> playSound(String soundFile) async {
    if (_isPlaying) {
      await stopSound();
    }

    try {
      _currentSound = soundFile;
      await _audioPlayer.setAsset('assets/sounds/notification_sounds/$soundFile');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      print('Error al reproducir sonido: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSound = null;
    } catch (e) {
      print('Error al detener sonido: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  bool get isPlaying => _isPlaying;
  String? get currentSound => _currentSound;
}
