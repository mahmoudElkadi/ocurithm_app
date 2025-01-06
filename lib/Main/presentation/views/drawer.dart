import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/Network/shared.dart';
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
    return SafeArea(
      child: Container(
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
                      CacheHelper.getUser("user")?.image != null
                          ? Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                    image: NetworkImage(CacheHelper.getUser("user")?.image ?? "https://via.placeholder.com/150"),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center),
                              ),
                            )
                          : Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 0))],
                              ),
                              child: CacheHelper.getUser("user")?.name != null
                                  ? Center(
                                      child: Text(CacheHelper.getUser("user")?.name?.split("")[0].toUpperCase() as String,
                                          style: appStyle(context, 50, Colors.grey.shade700, FontWeight.bold)))
                                  : null,
                            ),
                      const HeightSpacer(size: 10),
                      Text(
                        CacheHelper.getUser("user")?.name ?? "Unknown",
                        style: appStyle(context, 18, Colors.black, FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const HeightSpacer(size: 5),
                      Text(
                        CacheHelper.getUser("user")?.clinic?.name ?? "Clinic",
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
      ),
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
