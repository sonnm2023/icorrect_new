import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/provider/rating_provider.dart';
import 'package:provider/provider.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _showRatingDialog(context);
            },
            child: const Text('Hiển Thị Đánh Giá'),
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    double w = MediaQuery.of(context).size.width - 30;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text(
                'Did you like the service',
                style: TextStyle(color: AppColor.defaultBlackColor),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Let us know what you think",
                style:
                    TextStyle(color: AppColor.defaultGrayColor, fontSize: 15.0),
              ),
            ],
          ),
          content: SizedBox(
            height: 325,
            width: w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: RatingBar.builder(
                    initialRating: 5,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: AppColor.defaultPurpleColor,
                    ),
                    onRatingUpdate: (rating) {
                      Provider.of<RatingProvider>(context, listen: false)
                          .updateRating(rating);
                    },
                  ),
                ),
                Text(
                  Provider.of<RatingProvider>(context).ratingText,
                  style: const TextStyle(
                    color: AppColor.defaultPurpleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const TextField(
                  maxLines: 5,
                  maxLength: 1024,
                  decoration: InputDecoration(
                    labelText: 'Please write your comment here',
                    labelStyle: TextStyle(
                        fontSize: 13.0, color: AppColor.defaultGrayColor),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.defaultGraySlightColor),
                    ),
                    fillColor: AppColor.defaultGraySlightColor,
                    filled: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                      child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColor.defaultGrayColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                      child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text(
                          'Commit',
                          style: TextStyle(color: AppColor.defaultPurpleColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          alignment: Alignment.center,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the radius here
          ),
        );
      },
    );
  }
}
