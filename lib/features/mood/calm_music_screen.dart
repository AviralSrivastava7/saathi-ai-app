import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';

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
    MusicTrack(
      titleKey: 'calm_piano',
      subtitleKey: 'calm_piano_sub',
      assetPath: 'audio/calm_piano.mp3',
      color: Colors.blue,
      icon: Icons.music_note_rounded,
    ),
    MusicTrack(
      titleKey: 'deep_meditation_track',
      subtitleKey: 'deep_meditation_track_sub',
      assetPath: 'audio/meditation_track.mp3',
      color: Colors.purple,
      icon: Icons.self_improvement_rounded,
    ),
    MusicTrack(
      titleKey: 'nature_serenity',
      subtitleKey: 'nature_serenity_sub',
      assetPath: 'audio/nature_sounds.mp3',
      color: Colors.green,
      icon: Icons.nature_people_rounded,
    ),
    MusicTrack(
      titleKey: 'happy_vibes',
      subtitleKey: 'happy_vibes_sub',
      assetPath: 'audio/happy_music.mp3',
      color: Colors.orange,
      icon: Icons.wb_sunny_rounded,
    ),
    MusicTrack(
      titleKey: 'chill_lofi',
      subtitleKey: 'chill_lofi_sub',
      assetPath: 'audio/default_chill.mp3',
      color: Colors.teal,
      icon: Icons.nightlight_round,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        _playNext();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(int index) async {
    if (_currentIndex == index) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      await _audioPlayer.stop();
      setState(() {
        _currentIndex = index;
        _position = Duration.zero;
      });
      await _audioPlayer.play(AssetSource(_tracks[index].assetPath));
    }
  }

  void _playNext() {
    if (_currentIndex != null && _currentIndex! < _tracks.length - 1) {
      _playTrack(_currentIndex! + 1);
    } else {
      _playTrack(0);
    }
  }

  void _playPrevious() {
    if (_currentIndex != null && _currentIndex! > 0) {
      _playTrack(_currentIndex! - 1);
    } else {
      _playTrack(_tracks.length - 1);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final MusicTrack? selectedTrack = _currentIndex != null ? _tracks[_currentIndex!] : null;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).t('calming_music'),
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: Stack(
          children: [
            // Subtle accent light based on track
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: selectedTrack?.color.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            // Bottom accent glow
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  color: (selectedTrack?.color ?? AppColors.primaryPurple).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight - 20),
                  // Current Player Card
                  _buildPlayerCard(context),
                  const SizedBox(height: 32),
                  // Tracks List
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).t('your_playlist'),
                            style: AppTextStyles.headingSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _tracks.length,
                              itemBuilder: (context, index) {
                                return _buildTrackItem(index, context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context) {
    final track = _currentIndex != null ? _tracks[_currentIndex!] : null;
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Album Art Placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: track != null
                          ? [track.color, track.color.withOpacity(0.5)]
                          : [Colors.grey, Colors.grey.withOpacity(0.5)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (track?.color ?? Colors.transparent).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    track?.icon ?? Icons.music_note_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  track != null ? loc.t(track.titleKey) : loc.t('select_a_track'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  track != null ? loc.t(track.subtitleKey) : loc.t('relax_your_mind'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Progress Bar
                Slider(
                  activeColor: track?.color ?? AppColors.primaryPurple,
                  inactiveColor: Colors.white.withOpacity(0.1),
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded,
                          color: Colors.white, size: 40),
                      onPressed: _currentIndex != null ? _playPrevious : null,
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _currentIndex != null ? () => _playTrack(_currentIndex!) : () => _playTrack(0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: track?.color ?? AppColors.primaryPurple,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded,
                          color: Colors.white, size: 40),
                      onPressed: _currentIndex != null ? _playNext : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackItem(int index, BuildContext context) {
    final track = _tracks[index];
    final isSelected = _currentIndex == index;
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _playTrack(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? track.color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? track.color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: track.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(track.icon, color: track.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t(track.titleKey),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.t(track.subtitleKey),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected && _isPlaying)
                    Icon(Icons.equalizer_rounded, color: track.color)
                  else if (isSelected)
                    Icon(Icons.play_circle_filled_rounded, color: track.color)
                  else
                    Icon(Icons.play_circle_outline_rounded,
                        color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class MusicTrack {
  final String titleKey;
  final String subtitleKey;
  final String assetPath;
  final Color color;
  final IconData icon;

  MusicTrack({
    required this.titleKey,
    required this.subtitleKey,
    required this.assetPath,
    required this.color,
    required this.icon,
  });
}
