import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../generated/l10n.dart';
import '../utils/app_style.dart';
import 'height_spacer.dart';

class DropValidate extends StatefulWidget {
  const DropValidate({
    super.key,
    required this.items,
    this.onChanged,
    this.selectedValue,
    this.text,
    required this.hintText,
    this.border,
    this.height,
    this.hintColor,
    this.validate,
    this.icon,
    this.radius,
    this.prefixIcon,
  });
  final List<DropdownMenuItem<dynamic>>? items;
  final Function(dynamic str)? onChanged;
  final dynamic selectedValue;
  final String? text;
  final Widget? icon;
  final Widget? prefixIcon;
  final String hintText;
  final double? border;
  final double? height;
  final double? radius;
  final Color? hintColor;
  final bool? validate;

  @override
  State<DropValidate> createState() => _DropValidateState();
}

class _DropValidateState extends State<DropValidate> {
  TextEditingController textEditingController = TextEditingController();

  bool customSearchMatch(String itemValue, String searchValue) {
    int itemIndex = 0;
    int searchIndex = 0;

    while (itemIndex < itemValue.length && searchIndex < searchValue.length) {
      if (itemValue[itemIndex].toLowerCase() ==
          searchValue[searchIndex].toLowerCase()) {
        searchIndex++;
      }
      itemIndex++;
    }
    return searchIndex == searchValue.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.text != null
            ? Row(
                children: [
                  widget.icon ??
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                  const WidthSpacer(size: 10),
                  Text(
                    widget.text!,
                    style: appStyle(context, 18, Colors.black, FontWeight.bold),
                  ),
                ],
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        const HeightSpacer(size: 10),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.radius ?? 30),
              border: Border.all(
                  color: widget.validate == true
                      ? Colors.red
                      : Colors.transparent),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade100,
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 0))
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<dynamic>(
                iconStyleData: IconStyleData(
                    icon: Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Colorz.blue,
                )),
                isExpanded: true,
                hint: Row(
                  children: [
                    widget.prefixIcon ?? Container(),
                    Text(
                      widget.hintText,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                items: widget.items,
                value: widget.selectedValue,
                onChanged: widget.onChanged,
                buttonStyleData: ButtonStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: widget.height ?? 25,
                  width: 200,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: "Search for an item...",
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return customSearchMatch(
                        item.value.toString(), searchValue);
                  },
                ),
                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),
        ),
        if (widget.validate == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeightSpacer(
                size: 10,
              ),
              Text(
                S.of(context).mustNotEmpty,
                style:
                    appStyle(context, 14, Colors.red.shade900, FontWeight.w400),
              ),
            ],
          ),
      ],
    );
  }
}

class DropValidateRow extends StatefulWidget {
  const DropValidateRow({
    super.key,
    required this.items,
    this.onChanged,
    this.selectedValue,
    this.text,
    required this.hintText,
    this.border,
    this.height,
    this.hintColor,
    this.validate,
    this.icon,
    this.radius,
    this.prefixIcon,
    this.textRow,
  });
  final List<DropdownMenuItem<dynamic>>? items;
  final Function(dynamic str)? onChanged;
  final dynamic selectedValue;
  final String? text;
  final String? textRow;
  final Widget? icon;
  final Widget? prefixIcon;
  final String hintText;
  final double? border;
  final double? height;
  final double? radius;
  final Color? hintColor;
  final bool? validate;

  @override
  State<DropValidateRow> createState() => _DropValidateRowState();
}

class _DropValidateRowState extends State<DropValidateRow> {
  TextEditingController textEditingController = TextEditingController();

  bool customSearchMatch(String itemValue, String searchValue) {
    int itemIndex = 0;
    int searchIndex = 0;

    while (itemIndex < itemValue.length && searchIndex < searchValue.length) {
      if (itemValue[itemIndex].toLowerCase() ==
          searchValue[searchIndex].toLowerCase()) {
        searchIndex++;
      }
      itemIndex++;
    }
    return searchIndex == searchValue.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.text != null
            ? Row(
                children: [
                  widget.icon ??
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                  const WidthSpacer(size: 10),
                  Text(
                    widget.text!,
                    style: appStyle(context, 18, Colors.grey, FontWeight.bold),
                  ),
                ],
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        const HeightSpacer(size: 10),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w)
                .copyWith(right: 0),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.radius ?? 30),
              border: Border.all(
                  color: widget.validate == true
                      ? Colors.red.shade900
                      : Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.textRow ?? "",
                  style: appStyle(context, 15, Colors.grey, FontWeight.bold),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<dynamic>(
                      isExpanded: true,
                      iconStyleData: IconStyleData(
                          icon: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.expand_more,
                          color: Colors.black,
                        ),
                      )),
                      hint: Row(
                        children: [
                          widget.prefixIcon ?? Container(),
                          Text(
                            widget.hintText,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      items: widget.items,
                      value: widget.selectedValue,
                      style:
                          appStyle(context, 15, Colors.black, FontWeight.w600)
                              .copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChanged: widget.onChanged,
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: widget.height ?? 25,
                        width: MediaQuery.sizeOf(context).width * 0.57,
                      ),
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: textEditingController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: textEditingController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: "Search for an item...",
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return customSearchMatch(
                              item.value.toString(), searchValue);
                        },
                      ),
                      //This to clear the search value when you close the menu
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          textEditingController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.validate == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeightSpacer(
                size: 10,
              ),
              Text(
                S.of(context).mustNotEmpty,
                style:
                    appStyle(context, 14, Colors.red.shade900, FontWeight.w400),
              ),
            ],
          ),
      ],
    );
  }
}

//////////////////////////////////////

class DropMain extends StatefulWidget {
  const DropMain({
    super.key,
    required this.items,
    this.onChanged,
    this.selectedValue,
    this.text,
    required this.hintText,
    this.border,
    this.height,
    this.width,
    this.hintColor,
    this.validate,
    this.icon,
    this.radius,
    this.prefixIcon,
  });
  final List<DropdownMenuItem<dynamic>>? items;
  final Function(dynamic str)? onChanged;
  final dynamic selectedValue;
  final String? text;
  final Widget? icon;
  final Widget? prefixIcon;
  final String hintText;
  final double? border;
  final double? height;
  final double? width;
  final double? radius;
  final Color? hintColor;
  final bool? validate;

  @override
  State<DropMain> createState() => _DropMainState();
}

class _DropMainState extends State<DropMain> {
  TextEditingController textEditingController = TextEditingController();

  bool customSearchMatch(String itemValue, String searchValue) {
    int itemIndex = 0;
    int searchIndex = 0;

    while (itemIndex < itemValue.length && searchIndex < searchValue.length) {
      if (itemValue[itemIndex].toLowerCase() ==
          searchValue[searchIndex].toLowerCase()) {
        searchIndex++;
      }
      itemIndex++;
    }
    return searchIndex == searchValue.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.text != null
            ? Row(
                children: [
                  widget.icon ??
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                  const WidthSpacer(size: 10),
                  Text(
                    widget.text!,
                    style: appStyle(context, 18, Colors.black, FontWeight.bold),
                  ),
                ],
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        const HeightSpacer(size: 10),
        Center(
          child: Container(
            width: widget.width,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.radius ?? 30),
              border: Border.all(
                  color: widget.validate == true
                      ? Colors.red.shade900
                      : Colors.transparent),
              // boxShadow: [BoxShadow(color: Colors.grey.shade100, spreadRadius: 2, blurRadius: 4, offset: const Offset(0, 0))],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<dynamic>(
                iconStyleData: IconStyleData(
                    icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ),
                )),
                isExpanded: true,
                hint: Row(
                  children: [
                    widget.prefixIcon ?? Container(),
                    Text(
                      widget.hintText,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                items: widget.items,
                value: widget.selectedValue,
                onChanged: widget.onChanged,
                buttonStyleData: ButtonStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: widget.height ?? 25,
                  width: 200,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: "Search for an item...",
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return customSearchMatch(
                        item.value.toString(), searchValue);
                  },
                ),
                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),
        ),
        if (widget.validate == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeightSpacer(
                size: 10,
              ),
              Text(
                S.of(context).mustNotEmpty,
                style:
                    appStyle(context, 14, Colors.red.shade900, FontWeight.w400),
              ),
            ],
          ),
      ],
    );
  }
}
