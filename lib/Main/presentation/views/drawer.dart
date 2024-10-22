import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';

import '../manger/main_cubit.dart';
import '../manger/main_state.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        final mainCubit = MainCubit.get(context);
        final drawerItems = mainCubit.drawerItems;

        return Drawer(
          child: Column(
            children: [
              _buildUserInfo(context),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: drawerItems.length,
                  itemBuilder: (context, index) {
                    final item = drawerItems[index];
                    final bool isSelected = index == mainCubit.currentIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ListTile(
                        leading: SvgPicture.asset(
                          item.icon,
                          color: isSelected ? Colorz.primaryColor : Colorz.black,
                        ),
                        title: Text(
                          item.title,
                          style: appStyle(
                            context,
                            16,
                            isSelected ? Colorz.primaryColor : Colorz.black,
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          mainCubit.currentIndex = index;
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              _buildLogoutButton(context, mainCubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Container(
      color: Colorz.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    HeightSpacer(size: 0),
                    Text(
                      "Name",
                      style: appStyle(context, 18, Colors.black, FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const HeightSpacer(size: 5),
                    Text(
                      "Dentist",
                      style: appStyle(context, 16, Colors.grey, FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const HeightSpacer(size: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item, MainCubit cubit, int index) {
    final bool isSelected = index == cubit.selectedIndex;
    return ListTile(
      leading: SvgPicture.asset(
        item.icon,
        color: isSelected ? Colorz.primaryColor : Colorz.black,
      ),
      title: Text(
        item.title,
        style: appStyle(
          context,
          16,
          isSelected ? Colorz.primaryColor : Colorz.black,
          isSelected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      // tileColor: isSelected ? Colorz.primaryColor.withOpacity(0.1) : null,
      onTap: () {
        log(cubit.pages[item.index].toString());
        log(item.index.toString());
        cubit.navigateToPage(context, item.index);
        //  Navigator.pop(context);
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, MainCubit cubit) {
    return InkWell(
      onTap: () => cubit.logOut(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(bottom: 30),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colorz.primaryColor),
            const SizedBox(width: 10),
            Text(
              "Log Out",
              style: appStyle(context, 16, Colorz.primaryColor, FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
