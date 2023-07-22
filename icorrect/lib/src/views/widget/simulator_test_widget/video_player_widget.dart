import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key, required this.playVideo});

  final Function playVideo;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = 200;

    double videoContainerRatio = (w - 60) / h;

    double getScale(VideoPlayerController videoPlayerController) {
      double videoRatio = 16 / 9;
      // double videoRatio = videoPlayerController.value.aspectRatio;

      if (videoRatio < videoContainerRatio) {
        return videoContainerRatio / videoRatio;
      } else {
        return videoRatio / videoContainerRatio;
      }
    }

    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        if (null == testProvider.playController) {
          return
            //Loading video
            Visibility(
              visible: testProvider.isLoadingVideo,
              child: SizedBox(
                width: w,
                height: h,
                child: const Center(
                  child: DefaultLoadingIndicator(
                    color: AppColor.defaultPurpleColor,
                  ),
                ),
              ),
            );
        }

        return Stack(
          children: [
            //Video
            Transform.scale(
              scale: getScale(testProvider.playController!),
              child: AspectRatio(
                aspectRatio: videoContainerRatio,
                child: VideoPlayer(testProvider.playController!),
              ),
            ),

            //Play video button
            Visibility(
              visible: testProvider.isShowPlayVideoButton,
              child: SizedBox(
                width: w,
                height: h,
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        testProvider.setIsShowPlayVideoButton(false);
                        playVideo();
                      },
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColor.defaultAppColor,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
