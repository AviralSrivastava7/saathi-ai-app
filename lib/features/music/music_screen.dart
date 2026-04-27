import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import 'package:audioplayers/audioplayers.dart';

class CalmMusicScreen extends StatefulWidget {
  const CalmMusicScreen({super.key});

  @override
  State<CalmMusicScreen> createState() => _CalmMusicScreenState();
}

class _CalmMusicScreenState extends State<CalmMusicScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int? _currentIndex;

  final List<MusicTrack> _tracks = [
    MusicTrack(titleKey: 'track_calm_piano_title', subtitleKey: 'track_calm_piano_sub', assetPath: 'audio/calm_piano.mp3', color: Colors.blue, icon: Icons.music_note_rounded),
    MusicTrack(titleKey: 'track_deep_meditation_title', subtitleKey: 'track_deep_meditation_sub', assetPath: 'audio/meditation_track.mp3', color: Colors.purple, icon: Icons.self_improvement_rounded),
    MusicTrack(titleKey: 'track_nature_serenity_title', subtitleKey: 'track_nature_serenity_sub', assetPath: 'audio/nature_sounds.mp3', color: Colors.green, icon: Icons.nature_people_rounded),
    MusicTrack(titleKey: 'track_happy_vibes_title', subtitleKey: 'track_happy_vibes_sub', assetPath: 'audio/happy_music.mp3', color: Colors.orange, icon: Icons.wb_sunny_rounded),
    MusicTrack(titleKey: 'track_chill_lofi_title', subtitleKey: 'track_chill_lofi_sub', assetPath: 'audio/default_chill.mp3', color: Colors.teal, icon: Icons.nightlight_round),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) { if (mounted) setState(() => _duration = d); });
    _audioPlayer.onPositionChanged.listen((p) { if (mounted) setState(() => _position = p); });
    _audioPlayer.onPlayerStateChanged.listen((state) { if (mounted) setState(() => _isPlaying = state == PlayerState.playing); });
    _audioPlayer.onPlayerComplete.listen((_) { if (mounted) { setState(() { _isPlaying = false; _position = Duration.zero; }); _playNext(); } });
  }

  @override
  void dispose() { _audioPlayer.dispose(); super.dispose(); }

  Future<void> _playTrack(int index) async {
    if (_currentIndex == index) {
      _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
    } else {
      await _audioPlayer.stop();
      setState(() { _currentIndex = index; _position = Duration.zero; });
      await _audioPlayer.play(AssetSource(_tracks[index].assetPath));
    }
  }

  void _playNext() { _playTrack(_currentIndex != null && _currentIndex! < _tracks.length - 1 ? _currentIndex! + 1 : 0); }
  void _playPrevious() { _playTrack(_currentIndex != null && _currentIndex! > 0 ? _currentIndex! - 1 : _tracks.length - 1); }

  String _fmt(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final track = _currentIndex != null ? _tracks[_currentIndex!] : null;
    final activeColor = track?.color ?? colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.t('calming_music'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 10),
              // Player Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [activeColor, activeColor.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(track?.icon ?? Icons.music_note_rounded, size: 52, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(track != null ? loc.t(track.titleKey) : loc.t('select_track'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(track != null ? loc.t(track.subtitleKey) : loc.t('relax_mind'), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                        onChanged: (v) async => await _audioPlayer.seek(Duration(seconds: v.toInt())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(_position), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                          Text(_fmt(_duration), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36), onPressed: _currentIndex != null ? _playPrevious : null),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _currentIndex != null ? () => _playTrack(_currentIndex!) : () => _playTrack(0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: activeColor, size: 36),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36), onPressed: _currentIndex != null ? _playNext : null),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Track List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(alignment: Alignment.centerLeft, child: Text(loc.t('playlist'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface, letterSpacing: -0.5))),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _tracks.length,
                  itemBuilder: (context, i) {
                    final t = _tracks[i];
                    final sel = _currentIndex == i;
                    return GestureDetector(
                      onTap: () => _playTrack(i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: sel ? t.color.withOpacity(0.1) : colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: sel ? t.color.withOpacity(0.3) : colorScheme.onSurface.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: t.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                              child: Icon(t.icon, color: t.color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.t(t.titleKey), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colorScheme.onSurface)),
                                  const SizedBox(height: 2),
                                  Text(loc.t(t.subtitleKey), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(
                              sel && _isPlaying ? Icons.equalizer_rounded : (sel ? Icons.play_circle_filled_rounded : Icons.play_circle_outline_rounded),
                              color: sel ? t.color : colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicTrack {
  final String titleKey, subtitleKey, assetPath;
  final Color color;
  final IconData icon;
  MusicTrack({required this.titleKey, required this.subtitleKey, required this.assetPath, required this.color, required this.icon});
}
