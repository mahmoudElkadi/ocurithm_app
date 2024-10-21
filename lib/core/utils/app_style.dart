import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/responsiveText.dart';

TextStyle appStyle(BuildContext context,double size,Color color,FontWeight fw,){
  return GoogleFonts.poppins(fontSize:getResponsiveFontSize(context,fontSize: size.sp),color:color,fontWeight:fw);
}