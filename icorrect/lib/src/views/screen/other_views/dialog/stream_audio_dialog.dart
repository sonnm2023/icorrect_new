// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:provider/provider.dart';

class SliderAudio extends StatefulWidget {
  String url;
  SliderAudio({super.key, required this.url});

  @override
  State<SliderAudio> createState() => _SliderAudioState();
}

class _SliderAudioState extends State<SliderAudio> {
  MyTestProvider? _provider;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<MyTestProvider>(context, listen: false);

    _audioPlayer.onPlayerStateChanged.listen((event) {
      _provider!.setSampleAudioPlaying(event == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _provider!.setDurationAudioSample(newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _provider!
          .setPositionAudioSample(newPosition + const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _provider!.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Consumer<MyTestProvider>(
        builder: (context, provider, child) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _audioPlayer.pause();
                      _audioPlayer.dispose();
                      _provider!.clearSampleAudioCache();
                    },
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColor.defaultGrayColor,
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultText(
                      text: Utils.multiLanguage(StringConstants.sample_audio),
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    Slider(
                        min: 0,
                        activeColor: AppColor.defaultPurpleColor,
                        inactiveColor: AppColor.defaultLightGrayColor,
                        max: provider.durationAudioSample.inSeconds.toDouble(),
                        value:
                            provider.positionAudioSample.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(position);
                          await _audioPlayer.resume();
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DefaultText(
                          text: Utils.formatTime(provider.durationAudioSample -
                              provider.positionAudioSample),
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        DefaultText(
                          text: Utils.formatTime(provider.durationAudioSample),
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ],
                    ),
                    (provider.isSamplePlaying)
                        ? InkWell(
                            onTap: () async {
                              _provider!.setSampleAudioPlaying(false);
                              await _audioPlayer.pause();
                            },
                            child: const Icon(
                              Icons.pause_circle_filled_rounded,
                              size: 60,
                              color: AppColor.defaultPurpleColor,
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              _provider!.setSampleAudioPlaying(true);
                              await _audioPlayer.play(UrlSource(widget.url));
                            },
                            child: const Icon(
                              Icons.play_circle_fill,
                              size: 60,
                              color: AppColor.defaultPurpleColor,
                            ),
                          )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
