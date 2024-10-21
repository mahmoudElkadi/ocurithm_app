import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/widgets/text_field_form.dart';

import '../utils/app_style.dart';
import '../utils/colors.dart';
import 'height_spacer.dart';
import 'width_spacer.dart';

class TextField2 extends StatelessWidget {
  const TextField2(
      {super.key,
      this.text,
      required this.controller,
      required this.required,
      required this.hintText,
      this.icon,
      this.type,
      this.onTextFieldChanged,
      this.onSubmit,
      this.kind,
      this.borderColor,
      this.fillColor,
      this.suffixIcon,
      this.isPassword,
      this.height,
      this.radius,
      this.prefixIcon,
      this.border,
      this.isShadow,
      this.validator,
      this.hintStyle});
  final String? text;
  final String? kind;
  final String hintText;
  final TextEditingController controller;
  final bool required;
  final bool? isPassword;
  final bool? isShadow;
  final Widget? icon;
  final Color? borderColor;
  final Color? border;
  final Color? fillColor;
  final TextInputType? type;
  final Function(dynamic)? onTextFieldChanged;
  final Function(dynamic)? onSubmit;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? height;
  final double? radius;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text != null
            ? Row(
                children: [
                  const WidthSpacer(size: 5),
                  icon ?? SizedBox(),
                  const WidthSpacer(size: 10),
                  Text(
                    text!,
                    style: appStyle(context, 18, Colors.black, FontWeight.bold),
                  ),
                ],
              )
            : Container(
                height: 0,
              ),
        if (text != null) const HeightSpacer(size: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 10),
            color: fillColor ?? Colors.white,
            boxShadow: isShadow != null
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: defaultTextFormField(
              context: context,
              isPass: isPassword ?? false,
              controller: controller,
              onChange: onTextFieldChanged,
              type: type ?? TextInputType.text,
              kind: kind ?? "",
              hintText: hintText,
              radius: radius,
              onSubmit: onSubmit,
              borderColor: borderColor,
              border: border,
              height: height,
              hintStyle: hintStyle,
              validator: required
                  ? validator ??
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }
                  : null,
              fillColor: fillColor,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

// class PasswordTextField extends StatelessWidget {
//   const PasswordTextField(
//       {super.key,
//       this.text,
//       required this.controller,
//       required this.required,
//       required this.hintText,
//       this.icon,
//       this.type,
//       this.onTextFieldChanged,
//       this.onSubmit,
//       this.kind,
//       this.borderColor,
//       this.fillColor,
//       this.suffixIcon,
//       this.isPassword,
//       this.widthBorder});
//   final String? text;
//   final String? kind;
//   final String hintText;
//   final TextEditingController controller;
//   final bool required;
//   final bool? isPassword;
//   final Widget? icon;
//   final Color? borderColor;
//   final Color? fillColor;
//   final double? widthBorder;
//   final TextInputType? type;
//   final Function(dynamic)? onTextFieldChanged;
//   final Function(dynamic)? onSubmit;
//   final Widget? suffixIcon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         text != null
//             ? Row(
//                 children: [
//                   const WidthSpacer(size: 5),
//                   icon ?? SizedBox(),
//                   const WidthSpacer(size: 10),
//                   Text(
//                     text!,
//                     style: appStyle(context, 18, Colors.black, FontWeight.bold),
//                   ),
//                 ],
//               )
//             : Container(
//                 height: 0,
//               ),
//         const HeightSpacer(size: 10),
//         defaultTextFormField(
//             context: context,
//             controller: controller,
//             isPass: isPassword ?? false,
//             onChange: onTextFieldChanged,
//             type: type ?? TextInputType.text,
//             kind: kind ?? "",
//             hintText: hintText,
//             onSubmit: onSubmit,
//             borderColor: borderColor,
//             fillColor: fillColor,
//             widthBorder: widthBorder,
//             suffixIcon: suffixIcon,
//             required: required),
//       ],
//     );
//   }
// }

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      this.hintText,
      required this.keyboardType,
      this.validator,
      this.suffixIcon,
      this.obscureText,
      this.color,
      this.hintColor,
      this.onChanged,
      this.onEditingComplete,
      this.textColor,
      this.cursorColor,
      this.label,
      this.width,
      this.maxLines,
      this.prefixIcon,
      this.borderColor});
  final TextEditingController controller;
  final String? hintText;
  final String? label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscureText;
  final Color? color;
  final Color? hintColor;
  final Color? textColor;
  final Color? cursorColor;
  final Color? borderColor;
  final Function(String str)? onChanged;
  final Function()? onEditingComplete;
  final double? width;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 15),
      width: width,
      child: TextFormField(
        onEditingComplete: onEditingComplete,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText ?? false,
        cursorColor: cursorColor ?? Colors.black,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          prefixIconConstraints: const BoxConstraints(
            maxWidth: 24, // Adjust minimum width as needed
            maxHeight: 24, // Adjust minimum height as needed
          ),
          labelText: label,
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: color ?? Colors.grey,
          hintText: hintText,
          suffixIcon: suffixIcon,
          hintStyle: appStyle(context, 16, hintColor ?? Colors.grey, FontWeight.w500),
          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 1), borderRadius: BorderRadius.circular(10.h)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colorz.blue, width: 1), borderRadius: BorderRadius.circular(10.h)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 1), borderRadius: BorderRadius.circular(10.h)),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: borderColor ?? Colors.black54, width: 1), borderRadius: BorderRadius.circular(10.h)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: borderColor ?? Colors.black54, width: 1), borderRadius: BorderRadius.circular(10.h)),
          border: InputBorder.none,
        ),
        controller: controller,
        cursorHeight: 25,
        style: appStyle(context, 18, textColor ?? Colors.black, FontWeight.w500),
        validator: validator,
      ),
    );
  }
}
