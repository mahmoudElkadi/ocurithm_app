import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

Widget defaultTextFormField(
    {required TextEditingController controller,
    required TextInputType type,
    Widget? suffixIcon,
    bool isPass = false,
    Function()? showPass,
    Function()? onTab,
    List<TextInputFormatter>? inputFormatters,
    String? label,
    String? hintText,
    Widget? prefixIcon,
    Color? borderColor,
    Color? border,
    Color? fillColor,
    bool? required,
    bool? isValid,
    bool? readOnly,
    double? height,
    double? radius,
    TextStyle? hintStyle,
    required String kind,
    Function(String value)? onChange,
    int maxLines = 1,
    context,
    String? Function(String?)? validator,
    Function(String value)? onSubmit}) {
  return TextFormField(
    maxLines: maxLines,
    controller: controller,
    inputFormatters: inputFormatters,
    onTap: onTab,
    onFieldSubmitted: onSubmit,
    keyboardType: type,
    obscureText: isPass,
    onChanged: onChange,
    validator: validator,
    readOnly: readOnly ?? false,
    textAlign: TextAlign.start,
    cursorColor: Colors.black,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: height ?? 15.h, horizontal: 12.w),
      isDense: true,
      focusColor: Colors.black,
      filled: true,
      fillColor: fillColor ?? HexColor("#DEDEDE").withOpacity(0.9),
      iconColor: Colors.black,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)), borderSide: BorderSide(color: borderColor ?? Colors.black, width: 1)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)), borderSide: BorderSide(color: border ?? Colors.transparent, width: 1)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)), borderSide: BorderSide(color: border ?? Colors.transparent, width: 1)),
      hintText: hintText,
      hintStyle: hintStyle ??
          TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
      labelText: label,
      suffixIcon: Padding(padding: const EdgeInsets.only(right: 8.0), child: suffixIcon ?? SizedBox()),
      prefixIcon: prefixIcon != null ? prefixIcon : null,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixStyle: const TextStyle(backgroundColor: Colors.white),
    ),
  );
}
