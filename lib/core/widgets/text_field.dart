import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      this.color,
      this.suffixIcon,
      this.isPassword,
      this.height,
      this.radius,
      this.prefixIcon,
      this.border,
      this.isShadow,
      this.readOnly,
      this.validator,
      this.hintStyle,
      this.maxLines});
  final String? text;
  final String? kind;
  final String hintText;
  final TextEditingController controller;
  final bool required;
  final bool? isPassword;
  final bool? readOnly;
  final bool? isShadow;
  final Widget? icon;
  final Color? borderColor;
  final Color? border;
  final Color? color;
  final Color? fillColor;
  final TextInputType? type;
  final Function(dynamic)? onTextFieldChanged;
  final Function(dynamic)? onSubmit;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? height;
  final double? radius;
  final int? maxLines;
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
            color: color ?? Colors.transparent,
            boxShadow: isShadow != false
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
              readOnly: readOnly,
              maxLines: maxLines ?? 1,
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

// class CustomTextField extends StatelessWidget {
//   const CustomTextField(
//       {super.key,
//       required this.controller,
//       this.hintText,
//       required this.keyboardType,
//       this.validator,
//       this.suffixIcon,
//       this.obscureText,
//       this.color,
//       this.hintColor,
//       this.onChanged,
//       this.onEditingComplete,
//       this.textColor,
//       this.cursorColor,
//       this.label,
//       this.width,
//       this.maxLines,
//       this.prefixIcon,
//       this.borderColor});
//   final TextEditingController controller;
//   final String? hintText;
//   final String? label;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final bool? obscureText;
//   final Color? color;
//   final Color? hintColor;
//   final Color? textColor;
//   final Color? cursorColor;
//   final Color? borderColor;
//   final Function(String str)? onChanged;
//   final Function()? onEditingComplete;
//   final double? width;
//   final int? maxLines;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       //padding: EdgeInsets.symmetric(horizontal: 15),
//       width: width,
//       child: TextFormField(
//         onEditingComplete: onEditingComplete,
//         onChanged: onChanged,
//         keyboardType: keyboardType,
//         obscureText: obscureText ?? false,
//         cursorColor: cursorColor ?? Colors.black,
//         maxLines: maxLines ?? 1,
//         decoration: InputDecoration(
//           prefixIconConstraints: const BoxConstraints(
//             maxWidth: 24, // Adjust minimum width as needed
//             maxHeight: 24, // Adjust minimum height as needed
//           ),
//           labelText: label,
//           prefixIcon: prefixIcon,
//           filled: true,
//           fillColor: color ?? Colors.grey,
//           hintText: hintText,
//           suffixIcon: suffixIcon,
//           hintStyle: appStyle(context, 16, hintColor ?? Colors.grey, FontWeight.w500),
//           errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 1), borderRadius: BorderRadius.circular(10.h)),
//           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colorz.blue, width: 1), borderRadius: BorderRadius.circular(10.h)),
//           focusedErrorBorder:
//               OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 1), borderRadius: BorderRadius.circular(10.h)),
//           disabledBorder:
//               OutlineInputBorder(borderSide: BorderSide(color: borderColor ?? Colors.black54, width: 1), borderRadius: BorderRadius.circular(10.h)),
//           enabledBorder:
//               OutlineInputBorder(borderSide: BorderSide(color: borderColor ?? Colors.black54, width: 1), borderRadius: BorderRadius.circular(10.h)),
//           border: InputBorder.none,
//         ),
//         controller: controller,
//         cursorHeight: 25,
//         style: appStyle(context, 18, textColor ?? Colors.black, FontWeight.w500),
//         validator: validator,
//       ),
//     );
//   }
// }

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    this.controller,
    this.errorText,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                if (errorText == null)
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.blue,
                    width: 1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EnhancedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? text;
  final String? errorText;
  final String hintText;
  final bool required;
  final bool isPassword;
  final bool? isShadow;
  final Widget? icon;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? borderColor;
  final Color? border;
  final Color? fillColor;
  final double? height;
  final double? radius;
  final TextInputType? keyboardType;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final int maxLines;

  const EnhancedTextField({
    Key? key,
    required this.controller,
    this.text,
    this.errorText,
    required this.hintText,
    this.required = false,
    this.isPassword = false,
    this.isShadow,
    this.icon,
    this.suffixIcon,
    this.prefixIcon,
    this.borderColor,
    this.border,
    this.fillColor,
    this.height,
    this.radius,
    this.keyboardType,
    this.hintStyle,
    this.inputFormatters,
    this.onChanged,
    this.onSubmit,
    this.onTap,
    this.validator,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != null)
          Row(
            children: [
              const SizedBox(width: 5),
              if (icon != null) icon!,
              const SizedBox(width: 10),
              Text(
                text!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        if (text != null) const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 30),
            color: fillColor ?? Colors.white,
            boxShadow: [
              // Only show shadow if isShadow is true AND there's no error
              if (isShadow == false)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: isPassword,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onFieldSubmitted: onSubmit,
            onTap: onTap,
            validator: required
                ? validator ??
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    }
                : validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: hintStyle ??
                  TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
              contentPadding: EdgeInsets.symmetric(
                vertical: height ?? 15,
                horizontal: 12,
              ),
              isDense: true,
              filled: true,
              fillColor: fillColor ?? Colors.grey[200]?.withOpacity(0.9),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: suffixIcon,
              ),
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? 30),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : border ?? Colors.transparent,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? 30),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : border ?? Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? 30),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : borderColor ?? Colors.blue,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? 30),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? 30),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class MultilineTextInput extends StatefulWidget {
  final String hint;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final double? maxHeight;
  final void Function(String)? onSubmitted;
  final TextEditingController controller;
  final bool? isShadow;
  final bool? readOnly;
  final String? Function(String?)? validator;
  final Color? color;
  final Color? borderColor;
  final double? radius;

  const MultilineTextInput({
    Key? key,
    this.hint = 'Type your text here...',
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.maxHeight,
    this.onSubmitted,
    required this.controller,
    this.isShadow,
    this.color,
    this.radius,
    this.borderColor,
    this.validator,
    this.readOnly,
  }) : super(key: key);

  @override
  State<MultilineTextInput> createState() => _MultilineTextInputState();
}

class _MultilineTextInputState extends State<MultilineTextInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listener for keyboard events
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _handleSubmit();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.controller.text.isNotEmpty) {
      widget.onSubmitted?.call(widget.controller.text);
      widget.controller.text += '\n'; // Add new line
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius ?? 10),
        color: widget.color ?? Colors.transparent,
        boxShadow: widget.isShadow != false
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: widget.textStyle,
        minLines: 3,
        maxLines: null,
        readOnly: widget.readOnly ?? false,
        textInputAction: TextInputAction.newline,
        decoration: widget.decoration ??
            InputDecoration(
              hintText: widget.hint,
              hintStyle: widget.hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.borderColor ?? Colors.transparent,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
        validator: widget.validator,
        cursorColor: Colorz.black,
        onFieldSubmitted: (value) {
          _handleSubmit();
        },
      ),
    );
  }
}
