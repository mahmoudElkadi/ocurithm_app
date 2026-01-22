import 'package:flutter/material.dart';
import '../utils/app_style.dart';
import 'height_spacer.dart';

customProgressLoading(BuildContext context,
    {required String text, required double progress}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              body: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: appStyle(
                            context,
                            18,
                            Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black,
                            FontWeight.bold),
                      ),
                      const HeightSpacer(size: 20),
                      CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        color: Theme.of(context).primaryColor,
                      ),
                      const HeightSpacer(size: 16),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: appStyle(context, 16,
                            Theme.of(context).primaryColor, FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
