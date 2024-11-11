import 'package:flutter/material.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../utils/app_style.dart';
import '../utils/colors.dart';

Future showConfirmationDialog({
  required BuildContext context,
  String? message,
  Widget? text,
  String? title,
  Function()? onConfirm,
  Function()? onCancel,
}) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30),
        contentPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        title: Center(
          child: Text(title ?? 'Confirmation', style: appStyle(context, 22, Colorz.black, FontWeight.w700)),
        ),
        content: text ??
            Text(
              message ?? 'Do you want to remove this item?',
              style: appStyle(context, 18, Colorz.black, FontWeight.w500),
              textAlign: TextAlign.center,
            ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Yes button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colorz.primaryColor),
                      backgroundColor: Colorz.primaryColor, // Green border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: onConfirm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colorz.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const WidthSpacer(size: 10),
                // No button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colorz.primaryColor), // Green border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colorz.primaryColor,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
