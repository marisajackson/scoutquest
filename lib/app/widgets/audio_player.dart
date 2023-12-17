import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:scoutquest/utils/logger.dart';

class AudioControlWidget extends StatefulWidget {
  final String audioAsset;

  const AudioControlWidget({Key? key, required this.audioAsset})
      : super(key: key);

  @override
  AudioControlWidgetState createState() => AudioControlWidgetState();
}

class AudioControlWidgetState extends State<AudioControlWidget> {
  final AudioPlayer audioPlayer = AudioPlayer();
  late Stream<PlayerState> playerStateStream;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    playerStateStream = audioPlayer.onPlayerStateChanged;
  }

  void playAudio(String audioAsset) async {
    if (!isPlaying) {
      await audioPlayer.play(UrlSource(audioAsset));
      setState(() {
        isPlaying = true;
      });
    } else {
      audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;

        // Determine the icon based on the player state
        IconData icon;
        Logger.log(playerState.toString());
        if (playerState == PlayerState.playing) {
          icon = Icons.pause;
        } else {
          icon = Icons.play_arrow;
        }

        return FloatingActionButton(
          onPressed: () {
            playAudio(widget.audioAsset);
          },
          child: Icon(icon),
        );
      },
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
