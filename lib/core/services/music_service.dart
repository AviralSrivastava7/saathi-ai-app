import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final AudioPlayer _player = AudioPlayer();
  static bool isPlaying = false;
  static String _currentMood = "default";

  // 1. Mood ke hisaab se Gana chalao
  static Future<void> playForMood(String moodLabel) async {
    // Agar mood same hai aur gana chal raha hai, to disturb mat karo
    if (isPlaying && _currentMood == moodLabel) return;

    _currentMood = moodLabel;
    String track = _getTrackForMood(moodLabel);

    try {
      await _player.stop(); // Purana gana roko
      await _player.setReleaseMode(ReleaseMode.loop); // Loop mein chalao
      await _player.play(AssetSource(track)); // Naya gana bajao
      isPlaying = true;
    } catch (e) {
      print("Music Error: $e");
    }
  }

  // 2. Mood aur Gane ki Mapping (Yahan apne filenames check karein)
  static String _getTrackForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'audio/happy_music.mp3';
      case 'sad':
        return 'audio/calm_piano.mp3'; // Sad ke liye soft music
      case 'angry':
        return 'audio/nature_sounds.mp3'; // Gusse ke liye relax karne wala
      case 'calm':
        return 'audio/meditation_track.mp3';
      default:
        return 'audio/default_chill.mp3'; // Agar kuch samajh na aaye
    }
  }

  static Future<void> toggle() async {
    if (isPlaying) {
      await _player.pause();
      isPlaying = false;
    } else {
      await _player.resume();
      isPlaying = true;
    }
  }
}
