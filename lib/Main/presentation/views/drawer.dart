import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../manger/main_cubit.dart';
import '../manger/main_state.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        final mainCubit = MainCubit.get(context);
        final drawerGroups = mainCubit.drawerGroups;

        return Drawer(
          child: Column(
            children: [
              _buildUserInfo(context),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: drawerGroups.length,
                  itemBuilder: (context, groupIndex) {
                    final group = drawerGroups[groupIndex];
                    final isExpanded = mainCubit.isGroupExpanded(groupIndex);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group header (only if title exists - not for dashboard)
                        if (group.title != null) ...[
                          _buildGroupHeader(
                            context,
                            group,
                            groupIndex,
                            isExpanded,
                            mainCubit,
                          ),
                        ],

                        // Group items with animation
                        _buildGroupItems(
                          context,
                          group,
                          isExpanded,
                          mainCubit,
                        ),

                        // Add spacing between groups (except after last group)
                        if (groupIndex < drawerGroups.length - 1) _buildGroupDivider(group),
                      ],
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

  Widget _buildGroupHeader(
    BuildContext context,
    DrawerGroup group,
    int groupIndex,
    bool isExpanded,
    MainCubit mainCubit,
  ) {
    return InkWell(
      onTap: group.isCollapsible ? () => mainCubit.toggleGroupExpansion(groupIndex) : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                group.title!,
                style: appStyle(
                  context,
                  14,
                  Colorz.primaryColor,
                  FontWeight.w700,
                ),
              ),
            ),
            if (group.isCollapsible)
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isExpanded ? 0.5 : 0.0,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colorz.primaryColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItems(
    BuildContext context,
    DrawerGroup group,
    bool isExpanded,
    MainCubit mainCubit,
  ) {
    // For non-collapsible groups (dashboard), always show items
    if (!group.isCollapsible) {
      return Column(
        children: group.items.map((item) {
          return _buildDrawerItem(context, item, mainCubit, group);
        }).toList(),
      );
    }

    // For collapsible groups, use AnimatedSize for smoother transitions
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: isExpanded
          ? Column(
              children: group.items.map((item) {
                return _buildDrawerItem(context, item, mainCubit, group);
              }).toList(),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    DrawerItem item,
    MainCubit mainCubit,
    DrawerGroup group,
  ) {
    final bool isSelected = item.index == mainCubit.currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: group.title != null ? const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
      decoration: group.title != null && isSelected
          ? BoxDecoration(
              color: Colorz.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ListTile(
        leading: SvgPicture.asset(
          item.icon,
          color: isSelected ? Colorz.primaryColor : Colorz.black,
          width: 24,
          height: 24,
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
          mainCubit.currentIndex = item.index;
          Navigator.pop(context);
        },
        dense: group.title != null, // Make grouped items more compact
      ),
    );
  }

  Widget _buildGroupDivider(DrawerGroup group) {
    return Divider(
      height: group.title == null ? 20 : 16,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Container(
      color: Colorz.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
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
                                  image: NetworkImage(
                                      CacheHelper.getUser("user")?.image ?? "https://via.placeholder.com/150"),
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
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 0))
                              ],
                            ),
                            child: CacheHelper.getUser("user")?.name != null
                                ? Center(
                                    child: Text(CacheHelper.getUser("user")?.name?.split("")[0].toUpperCase() as String,
                                        style: appStyle(context, 50, Colors.grey.shade700, FontWeight.bold)))
                                : null,
                          ),
                    const WidthSpacer(size: 10),
                    Column(
                      children: [
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
                  ],
                ),
              ),
            ),
          ],
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
