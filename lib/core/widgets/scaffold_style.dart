import 'package:flutter/material.dart';

import '../../Main/presentation/views/drawer.dart';
import '../utils/app_style.dart';
import '../utils/colors.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showTitle;
  final Widget? leading;

  const CustomScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.showTitle = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
          // backgroundColor: HexColor("#F7FAFF"),
          appBar: AppBar(
            // backgroundColor: Colorz.white,
            scrolledUnderElevation: 0,
            title: Text(
              title,
              style: appStyle(
                  context,
                  22,
                  showTitle ? Colorz.primaryColor : Colors.transparent,
                  FontWeight.bold),
            ),
            actions: actions,
            centerTitle: true,
            leading: leading ??
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colorz.primaryColor,
                      ), // Change this to your custom icon
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
          ),
          drawer: CustomDrawer(),
          body: body),
    );
  }
}
