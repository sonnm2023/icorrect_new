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
  // ignore: library_private_types_in_public_api
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    const double fontSize_15 = 15.0;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: fontSize_15,
                  fontWeight: FontWeight.bold,
                  color: AppColor.defaultPurpleColor,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: fontSize_15),
                ),
              ),
              const SizedBox(height: 5),
              const Divider(
                thickness: 0.5,
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
                            child: SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  widget.cancelButtonTitle ?? "Cancel",
                                  style: const TextStyle(
                                    fontSize: fontSize_15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.defaultGrayColor,
                                  ),
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
                            child: SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  widget.okButtonTitle ?? "OK",
                                  style: const TextStyle(
                                    fontSize: fontSize_15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.defaultPurpleColor,
                                  ),
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
                        child: SizedBox(
                          width: 150,
                          child: Center(
                            child: Text(
                              widget.okButtonTitle ?? "OK",
                              style: const TextStyle(
                                fontSize: fontSize_15,
                                fontWeight: FontWeight.bold,
                                color: AppColor.defaultPurpleColor,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (widget.hasCloseButton)
            Positioned(
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
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
