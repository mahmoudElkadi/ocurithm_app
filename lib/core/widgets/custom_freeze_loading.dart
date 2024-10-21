import 'package:flutter/material.dart';

import '../utils/app_style.dart';
import 'height_spacer.dart';

customLoading(context, String text) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PopScope(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              width: MediaQuery.sizeOf(context).width,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: appStyle(context, 20, Colors.white, FontWeight.w700),
                  ),
                  const HeightSpacer(
                    size: 30,
                  ),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          onPopInvoked: (h) async => false);
    },
  );
}
