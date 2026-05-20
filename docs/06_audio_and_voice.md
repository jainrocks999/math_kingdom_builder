# Step 6 — Audio & Voice System

---

## 6.1 Audio Service

Create a singleton audio service that all features use:

```dart
// lib/core/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  Future<void> init() async {
    // Configure TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);   // Slow for young children
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);          // Slightly warm/high

    // Start background music
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await playMusic('assets/audio/music/background_1.mp3');
  }

  // Play a pre-recorded voice file
  Future<void> playVoice(String fileName) async {
    await _sfxPlayer.play(AssetSource('audio/voice/$fileName'));
  }

  // Speak a number name (uses pre-recorded file if available, TTS fallback)
  Future<void> speakNumber(int number) async {
    final names = ['zero','one','two','three','four','five',
                   'six','seven','eight','nine','ten'];
    if (number >= 0 && number <= 10) {
      await playVoice('numbers/${names[number]}.mp3');
    }
  }

  // Speak counting: "one", "two", "three"...
  Future<void> speakCount(int count) async {
    await speakNumber(count);
  }

  // Correct feedback — randomize to avoid repetition
  Future<void> playCorrectFeedback() async {
    final options = [
      'feedback/great_job.mp3',
      'feedback/amazing.mp3',
      'feedback/wonderful.mp3',
      'feedback/you_did_it.mp3',
    ];
    options.shuffle();
    await playVoice(options.first);
    await playSfx('sfx/correct.mp3');
  }

  Future<void> playWrongFeedback() async {
    await playSfx('sfx/wrong_soft.mp3');
  }

  Future<void> playSfx(String fileName) async {
    if (!_sfxEnabled) return;
    await _sfxPlayer.play(AssetSource(fileName));
  }

  Future<void> playMusic(String fileName) async {
    if (!_musicEnabled) return;
    await _musicPlayer.play(AssetSource(fileName));
  }

  // Parent controls
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) _musicPlayer.pause();
    else _musicPlayer.resume();
  }

  void setSfxEnabled(bool enabled) => _sfxEnabled = enabled;

  // Set speech rate: 'slow' | 'normal'
  void setSpeechRate(String rate) {
    _tts.setSpeechRate(rate == 'slow' ? 0.3 : 0.45);
  }
}
```

---

## 6.2 Voice File Checklist

Organize voice files by folder. Minimum required:

```
audio/voice/numbers/
  zero.mp3, one.mp3, two.mp3, three.mp3, four.mp3,
  five.mp3, six.mp3, seven.mp3, eight.mp3, nine.mp3, ten.mp3

audio/voice/feedback/
  great_job.mp3, amazing.mp3, wonderful.mp3, you_did_it.mp3,
  keep_counting.mp3, try_again.mp3, almost_there.mp3

audio/voice/instructions/
  find_the_number.mp3          "Can you find the number...?"
  tap_to_count.mp3             "Tap each one to count!"
  drag_together.mp3            "Drag them all together!"
  what_comes_next.mp3          "What comes next?"
  tap_to_remove.mp3            "Tap [N] to take away!"
  session_break.mp3            "You've done amazing math! Let's rest."
  welcome_back.mp3             "Welcome back! Ready to build your kingdom?"

audio/voice/addition/
  2_and_1_make_3.mp3  ... (pre-record all combinations within 5)

audio/voice/subtraction/
  4_take_away_2_leaves_2.mp3 ... (all combinations within 5)
```

> **Tip:** For addition/subtraction voice lines, you need all combinations within 5:  
> 0+0 through 5+0, 0+5... That's about 21 unique sentences. Record them all.

---

## 6.3 Audio in Features

Use the service in any feature controller:

```dart
// In a Riverpod provider
final audioService = AudioService();

// On number tap:
await audioService.speakNumber(tappedNumber);

// On correct answer:
await audioService.playCorrectFeedback();

// On wrong answer:
await audioService.playWrongFeedback();
await audioService.speakNumber(targetNumber); // Repeat the target
```

---

## 6.4 Audio Latency Target

Per doc: < 100ms between tap and voice feedback.

To achieve this:
- Pre-load all audio files at app startup (not lazily)
- Use `audioplayers` with `AssetSource` (local files, not network)
- Avoid heavy processing on the main thread before playing

```dart
// Pre-load in AudioService.init():
await AudioCache.instance.loadAll([
  'audio/sfx/correct.mp3',
  'audio/sfx/wrong_soft.mp3',
  'audio/voice/numbers/one.mp3',
  // ... all frequently used files
]);
```

---

## ✅ Checklist

- [ ] `AudioService` singleton created
- [ ] TTS configured (slow rate, warm pitch)
- [ ] All number voice files recorded and added
- [ ] Feedback voice files (4+ variations) recorded
- [ ] Instruction voice files recorded
- [ ] SFX files sourced (correct, wrong, confetti, tap)
- [ ] Background music looping correctly
- [ ] Audio latency < 100ms verified on device
- [ ] Parent controls: music toggle, SFX toggle, speech rate work
