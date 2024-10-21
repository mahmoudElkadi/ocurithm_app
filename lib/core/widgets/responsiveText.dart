import 'package:flutter/material.dart';

double getResponsiveFontSize(BuildContext context, {required fontSize}) {
  double scaleFactor = getScaleFactor(context);
  double responsiveFontSize = fontSize * scaleFactor;
  double lowerLimit = fontSize * 0.8;
  double upperLimit = fontSize * 1.2;
  return responsiveFontSize.clamp(lowerLimit, upperLimit);
}

double getScaleFactor(BuildContext context) {
  double width = MediaQuery.sizeOf(context).width;
  if (width < 390) {
    return width / 500;
  } else if (width < 600) {
    return width / 480;
  } else if (width < 900) {
    return width / 460;
  } else {
    return width / 1000;
  }
}

double getResponsiveHeight(BuildContext context, {required double heightFactor}) {
  double scaleFactor = getHeightScaleFactor(context);
  double responsiveHeight = heightFactor * scaleFactor;
  double lowerLimit = heightFactor * 0.2;
  double upperLimit = heightFactor * 1.8;
  return responsiveHeight.clamp(lowerLimit, upperLimit);
}

double getHeightScaleFactor(BuildContext context) {
  double height = MediaQuery.of(context).size.height;
  if (height < 600) {
    return height / 800;
  } else if (height < 700) {
    return height / 540;
  } else if (height < 810) {
    return height / 790;
  } else if (height < 855) {
    return height / 880;
  } else if (height < 857) {
    return height / 940;
  } else if (height < 1200) {
    return height / 1500;
  } else if (height < 1400) {
    return height / 2150;
  } else {
    return height / 1200;
  }
}
