import 'package:flutter/material.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';

enum QuadrantPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class QuadrantWidget extends StatefulWidget {
  final double size;
  final QuadrantPosition position;
  final VoidCallback onTap;
  final num tapCount;
  final List<Color> colorList;
  final String text;
  final TextStyle? textStyle;
  final int showTextAtCount; // At which tap count should text be shown

  const QuadrantWidget({
    super.key,
    required this.size,
    required this.position,
    required this.onTap,
    required this.tapCount,
    required this.colorList,
    this.text = "CF",
    this.textStyle = const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
    ),
    this.showTextAtCount = 2,
  });

  @override
  State<QuadrantWidget> createState() => _QuadrantWidgetState();
}

class _QuadrantWidgetState extends State<QuadrantWidget> {
  BorderRadius _getRadius() {
    switch (widget.position) {
      case QuadrantPosition.topLeft:
        return const BorderRadius.only(topLeft: Radius.circular(1000));
      case QuadrantPosition.topRight:
        return const BorderRadius.only(topRight: Radius.circular(1000));
      case QuadrantPosition.bottomLeft:
        return const BorderRadius.only(bottomLeft: Radius.circular(1000));
      case QuadrantPosition.bottomRight:
        return const BorderRadius.only(bottomRight: Radius.circular(1000));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current color based on tap count
    final currentColor = widget.colorList[int.parse(widget.tapCount.toString())];

    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {});
      },
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: _getRadius(),
        ),
        child: Center(
          child: Text(
            widget.tapCount == widget.showTextAtCount ? widget.text : "",
            style: widget.textStyle,
          ),
        ),
      ),
    );
  }
}

class QuadrantContainer extends StatelessWidget {
  final double containerSize;
  final List<num> tapCounts;
  final List<VoidCallback>? tapHandlers;
  final List<Color> colorList;
  final String side;
  final String? title;

  const QuadrantContainer({
    Key? key,
    required this.containerSize,
    required this.tapCounts,
    this.tapHandlers,
    required this.colorList,
    required this.side,
    this.title,
  })  : assert(tapCounts.length == 4),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final quadrantSize = containerSize * 0.26;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title ?? '', style: appStyle(context, 18, Colorz.black, FontWeight.bold)),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QuadrantWidget(
                    size: quadrantSize,
                    position: QuadrantPosition.topLeft,
                    onTap: tapHandlers?[0] ?? () {},
                    tapCount: tapCounts[0],
                    colorList: colorList,
                  ),
                  QuadrantWidget(
                    size: quadrantSize,
                    position: QuadrantPosition.topRight,
                    onTap: tapHandlers?[1] ?? () {},
                    tapCount: tapCounts[1],
                    colorList: colorList,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QuadrantWidget(
                    size: quadrantSize,
                    position: QuadrantPosition.bottomLeft,
                    onTap: tapHandlers?[2] ?? () {},
                    tapCount: tapCounts[2],
                    colorList: colorList,
                  ),
                  QuadrantWidget(
                    size: quadrantSize,
                    position: QuadrantPosition.bottomRight,
                    onTap: tapHandlers?[3] ?? () {},
                    tapCount: tapCounts[3],
                    colorList: colorList,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
