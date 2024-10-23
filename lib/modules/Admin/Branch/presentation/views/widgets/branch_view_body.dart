import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../core/widgets/text_field.dart';
import 'branch_card.dart';

class BranchViewBody extends StatefulWidget {
  const BranchViewBody({super.key});

  @override
  State<BranchViewBody> createState() => _BranchViewBodyState();
}

class _BranchViewBodyState extends State<BranchViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildSearchField(), const HeightSpacer(size: 10), const BranchListView()],
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: Colorz.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
        ).copyWith(bottom: 10, top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField2(
                controller: searchController,
                hintText: "Search...",
                hintStyle: TextStyle(color: Colorz.primaryColor, fontSize: 14.sp, fontWeight: FontWeight.w400),
                height: 7,
                fillColor: Colorz.primaryColor.withOpacity(0.03),
                radius: 30,
                prefixIcon: Icon(Icons.search, size: 30, color: Colorz.primaryColor),
                onTextFieldChanged: (value) {
                  // cubit.getConditions();
                },
                required: false,
              ),
            ),
            WidthSpacer(size: 5),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                bool isShow = false;
                //  isShow = await showFilterBottomSheet(context, dashboardCubit: OrderDashboardCubit.get(context));
                if (isShow) {
                  setState(() {});
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colorz.primaryColor.withOpacity(0.03),
                ),
                child: SvgPicture.asset(
                  "assets/icons/filter.svg",
                  color: Colorz.primaryColor,
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
