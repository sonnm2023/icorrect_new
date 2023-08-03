import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.okButtonTitle,
    required this.cancelButtonTitle,
    required this.borderRadius,
    required this.hasCloseButton,
    required this.okButtonTapped,
    required this.cancelButtonTapped,
  }) : super(key: key);

  final String title;
  final String description;
  final String? okButtonTitle;
  final String? cancelButtonTitle;
  final double borderRadius;
  final bool hasCloseButton;
  final Function? okButtonTapped;
  final Function? cancelButtonTapped;

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColor.defaultPurpleColor,
                ),
              ),
              const SizedBox(height: 15),
              Text(widget.description),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: widget.cancelButtonTitle != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(widget.borderRadius),
                            ),
                            highlightColor: Colors.grey[200],
                            onTap: () {
                              widget.cancelButtonTapped!();
                            },
                            child: Center(
                              child: Text(
                                widget.cancelButtonTitle ?? "Cancel",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.defaultGrayColor,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(widget.borderRadius),
                            ),
                            highlightColor: Colors.grey[200],
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.okButtonTapped!();
                            },
                            child: Center(
                              child: Text(
                                widget.okButtonTitle ?? "OK",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.defaultPurpleColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(widget.borderRadius),
                          bottomRight: Radius.circular(widget.borderRadius),
                        ),
                        highlightColor: Colors.grey[200],
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            widget.okButtonTitle ?? "OK",
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppColor.defaultPurpleColor,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (widget.hasCloseButton) Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Image(
                    image: AssetImage("assets/images/ic_close_black.png"),
                    width: 15,
                    height: 15,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ) else const SizedBox(),
        ],
      ),
    );
  }
}