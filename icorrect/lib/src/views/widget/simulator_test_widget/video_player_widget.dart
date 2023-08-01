import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/test_room_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({
    super.key,
    required this.startToPlayVideo,
    required this.pauseToPlayVideo,
    required this.restartToPlayVideo,
    required this.continueToPlayVideo,
  });

  final Function startToPlayVideo;
  final Function pauseToPlayVideo;
  final Function restartToPlayVideo;
  final Function continueToPlayVideo;

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

    SimulatorTestProvider prepareSimulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);

    CircleLoading? loading = CircleLoading();

    return Consumer<TestRoomProvider>(
      builder: (context, testProvider, child) {
        if (null == testProvider.playController) {
          return SizedBox(
            width: w,
            height: h,
            child: Center(
              child: testProvider.isLoadingVideo
                  ? const DefaultLoadingIndicator(
                      color: AppColor.defaultPurpleColor,
                    )
                  : const SizedBox(),
            ),
          );
        }

        Widget buttonsControllerSubView = SizedBox(
          width: w,
          height: h,
          child: Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: InkWell(
                onTap: () {
                  //Update reviewing status from none -> playing
                  testProvider.updateReviewingStatus(ReviewingStatus.playing);

                  //Start to do the test
                  startToPlayVideo();
                },
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColor.defaultAppColor,
                  size: 50,
                ),
              ),
            ),
          ),
        );
        //For spint 1
        // Widget buttonsControllerSubView = Container();

        // switch (testProvider.reviewingStatus.get) {
        //   case -1: //None
        //     {
        //       buttonsControllerSubView = SizedBox(
        //         width: w,
        //         height: h,
        //         child: Center(
        //           child: SizedBox(
        //             width: 50,
        //             height: 50,
        //             child: InkWell(
        //               onTap: () {
        //                 //Update reviewing status from none -> playing
        //                 testProvider
        //                     .updateReviewingStatus(ReviewingStatus.playing);

        //                 //Start to do the test
        //                 startToPlayVideo();
        //               },
        //               child: const Icon(
        //                 Icons.play_arrow,
        //                 color: AppColor.defaultAppColor,
        //                 size: 50,
        //               ),
        //             ),
        //           ),
        //         ),
        //       );
        //       break;
        //     }
        //   case 0: //Playing
        //     {
        //       buttonsControllerSubView = SizedBox(
        //         width: w,
        //         height: h,
        //         child: GestureDetector(onTap: () {
        //           //Update reviewing status from playing -> pause
        //           //show/hide pause button
        //           if (prepareSimulatorTestProvider.doingStatus !=
        //               DoingStatus.doing) {
        //             if (testProvider.reviewingStatus ==
        //                 ReviewingStatus.playing) {
        //               testProvider.updateReviewingStatus(ReviewingStatus.pause);
        //             }
        //           }
        //         }),
        //       );
        //       break;
        //     }
        //   case 1: //Pause
        //     {
        //       buttonsControllerSubView = InkWell(
        //         onTap: () {
        //           if (testProvider.reviewingStatus == ReviewingStatus.pause) {
        //             testProvider.updateReviewingStatus(ReviewingStatus.playing);
        //           }
        //         },
        //         child: SizedBox(
        //           width: w,
        //           height: h,
        //           child: Center(
        //             child: SizedBox(
        //               width: 50,
        //               height: 50,
        //               child: InkWell(
        //                 onTap: () {
        //                   //Update reviewing status from pause -> restart
        //                   testProvider
        //                       .updateReviewingStatus(ReviewingStatus.restart);
        //                   pauseToPlayVideo();
        //                 },
        //                 child: const Icon(
        //                   Icons.pause,
        //                   color: AppColor.defaultAppColor,
        //                   size: 50,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       );
        //       break;
        //     }
        //   case 2: //Restart
        //     {
        //       buttonsControllerSubView = SizedBox(
        //         width: w,
        //         height: h,
        //         child: Center(
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               SizedBox(
        //                 width: 50,
        //                 height: 50,
        //                 child: InkWell(
        //                   onTap: () {
        //                     restartToPlayVideo();
        //                   },
        //                   child: const Icon(
        //                     Icons.restart_alt,
        //                     color: AppColor.defaultAppColor,
        //                     size: 50,
        //                   ),
        //                 ),
        //               ),
        //               const SizedBox(width: 10),
        //               SizedBox(
        //                 width: 50,
        //                 height: 50,
        //                 child: InkWell(
        //                   onTap: () {
        //                     continueToPlayVideo();
        //                   },
        //                   child: const Icon(
        //                     Icons.play_arrow,
        //                     color: AppColor.defaultAppColor,
        //                     size: 50,
        //                   ),
        //                 ),
        //               )
        //             ],
        //           ),
        //         ),
        //       );
        //       break;
        //     }
        // }

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

            //Play video controller buttons
            Visibility(
              visible: testProvider.reviewingStatus == ReviewingStatus.none,
              child: buttonsControllerSubView),

            Visibility(
              visible: testProvider.isReviewingPlayAnswer,
              child: playAudioBackground(w, h),
            )
          ],
        );
      },
    );
  }

  Widget playAudioBackground(double w, double h) {
    return Stack(
      children: [
        SizedBox(
          width: w,
          height: h + 80,
          child: const Image(
            image: AssetImage(AppAsset.playAnswerBackground),
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(
          width: w,
          height: h + 80,
          child: const Center(
            child: Image(
              image: AssetImage(AppAsset.defaultAvt),
              width: 80,
              height: 80,
            ),
          ),
        ),
      ],
    );
  }
}
