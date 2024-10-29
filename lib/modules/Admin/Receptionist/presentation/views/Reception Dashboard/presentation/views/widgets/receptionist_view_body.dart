import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/modules/Admin/Receptionist/presentation/views/Reception%20Dashboard/presentation/views/widgets/receptionist_card.dart';

import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../../core/widgets/text_field.dart';
import '../../../../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../../../../manger/Receptionist Details Cubit/receptionist_details_state.dart';

class ReceptionistViewBody extends StatefulWidget {
  const ReceptionistViewBody({super.key});

  @override
  State<ReceptionistViewBody> createState() => _ReceptionistViewBodyState();
}

class _ReceptionistViewBodyState extends State<ReceptionistViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceptionistCubit, ReceptionistState>(
      builder: (context, state) => Column(
        children: [
          _buildSearchField(ReceptionistCubit.get(context)),
          const HeightSpacer(size: 10),
          Expanded(
            child: CustomMaterialIndicator(
                onRefresh: () async {
                  try {
                    ReceptionistCubit.get(context).page = 1;
                    ReceptionistCubit.get(context).searchController.clear();
                    await ReceptionistCubit.get(context).getReceptionists();
                  } catch (e) {
                    log(e.toString());
                  }
                },
                indicatorBuilder: (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child: const ReceptionistListView()),
          )
        ],
      ),
    );
  }

  Widget _buildSearchField(ReceptionistCubit cubit) {
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
                controller: cubit.searchController,
                hintText: "Search...",
                hintStyle: TextStyle(color: Colorz.primaryColor, fontSize: 14.sp, fontWeight: FontWeight.w400),
                height: 7,
                fillColor: Colorz.primaryColor.withOpacity(0.03),
                color: Colorz.white,
                borderColor: Colorz.primaryColor,
                isShadow: false,
                radius: 30,
                prefixIcon: Icon(Icons.search, size: 30, color: Colorz.primaryColor),
                onTextFieldChanged: (value) {
                  cubit.getReceptionists();
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    cubit.searchController.clear();
                    cubit.getReceptionists();
                  },
                  icon: Icon(Icons.clear, color: Colorz.primaryColor),
                ),
                required: false,
              ),
            ),
            // const WidthSpacer(size: 5),
            // GestureDetector(
            //   onTap: () async {
            //     FocusScope.of(context).unfocus();
            //     bool isShow = false;
            //     //  isShow = await showFilterBottomSheet(context, dashboardCubit: OrderDashboardCubit.get(context));
            //     if (isShow) {
            //       setState(() {});
            //     }
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(15),
            //       color: Colorz.primaryColor.withOpacity(0.03),
            //     ),
            //     child: SvgPicture.asset(
            //       "assets/icons/filter.svg",
            //       color: Colorz.primaryColor,
            //       width: 25,
            //       height: 25,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
