import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/app_style.dart';
import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../core/widgets/width_spacer.dart';
import '../../manager/doctor_cubit.dart';
import '../../manager/doctor_state.dart';

class DoctorCard extends StatefulWidget {
  const DoctorCard({
    super.key,
    required this.isLoading,
    this.Doctor,
  });
  final bool isLoading;
  final Doctor;

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
        decoration: BoxDecoration(color: Colorz.white, borderRadius: BorderRadius.circular(20), boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ]),
        child: Row(children: [
          widget.isLoading
              ? _buildShimmer(Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ))
              :
              // : widget.item?.image != null
              //     ?
              Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      "widget.item!.image.toString()",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/icons/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
          // : Expanded(
          //     flex: 1,
          //     child: Image.asset(
          //       "assets/icons/logo.png",
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          ,
          const WidthSpacer(size: 10),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeightSpacer(size: 5),
                widget.isLoading
                    ? _buildShimmer(Container(
                        width: 170,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                      ))
                    : Text(
                        "N/A",
                        maxLines: 2,
                        style: GoogleFonts.inter(
                            textStyle: appStyle(context, 16, HexColor("#2A282F"), FontWeight.w600).copyWith(overflow: TextOverflow.ellipsis)),
                      ),
                const HeightSpacer(size: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: "widget.item!.sku.toString()"));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Copied"),
                          ),
                        );
                      },
                      child: widget.isLoading
                          ? _buildShimmer(Container(
                              width: 100,
                              height: 20,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                              ),
                            ))
                          : Text(
                              "N/A",
                              style: appStyle(context, 18, Colorz.grey, FontWeight.w400),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class DoctorListView extends StatefulWidget {
  const DoctorListView({Key? key}) : super(key: key);

  @override
  State<DoctorListView> createState() => _DoctorListViewState();
}

class _DoctorListViewState extends State<DoctorListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDoctorCubit, AdminDoctorState>(
      builder: (context, state) {
        final cubit = context.read<AdminDoctorCubit>();
        bool isLoading = AdminDoctorCubit.get(context).doctor == null;
        bool isEmpty = AdminDoctorCubit.get(context).doctor?.orders.isEmpty ?? true;
        if (isLoading) {
          return _buildLoadingList();
        } else if (isEmpty) {
          return _buildEmptyState();
        } else {
          return _buildOrderList(cubit);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const DoctorCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildOrderList(AdminDoctorCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => DoctorCard(
        Doctor: cubit.doctor!.orders[index],
        isLoading: false,
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.doctor!.orders.length,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 30),
          Icon(Icons.inbox_outlined, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Doctor found',
            style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Doctor will appear here',
            style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
