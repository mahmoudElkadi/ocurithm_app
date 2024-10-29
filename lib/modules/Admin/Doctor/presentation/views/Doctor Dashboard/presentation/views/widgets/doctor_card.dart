import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Admin/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Admin/Doctor/presentation/views/Doctor%20Details/presentation/view/doctor_details_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/utils/app_style.dart';
import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../../core/widgets/pagination.dart';
import '../../../../../../../../../core/widgets/width_spacer.dart';
import '../../../../../manager/doctor_cubit.dart';
import '../../../../../manager/doctor_state.dart';

class DoctorCard extends StatefulWidget {
  const DoctorCard({
    super.key,
    required this.isLoading,
    this.doctor,
  });
  final bool isLoading;
  final Doctor? doctor;

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
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) => GestureDetector(
        onTap: () {
          Get.to(() => DoctorDetailsView(cubit: DoctorCubit.get(context), id: widget.doctor!.id!));
        },
        child: Padding(
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
                      child: widget.doctor?.image != null
                          ? AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  image: DecorationImage(
                                      image: NetworkImage(widget.doctor?.image ?? "https://via.placeholder.com/150"),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center),
                                ),
                              ))
                          : Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 0))],
                              ),
                              child: widget.doctor?.name != null
                                  ? Center(
                                      child: Text(widget.doctor?.name?.split("")[0].toUpperCase() as String,
                                          style: appStyle(context, 30, Colors.grey.shade700, FontWeight.bold)))
                                  : null,
                            ),
                    ),
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
                            widget.doctor?.name ?? "N/A",
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
                                  widget.doctor?.phone ?? "N/A",
                                  style: appStyle(context, 18, Colorz.grey, FontWeight.w400),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              widget.isLoading
                  ? _buildShimmer(Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ))
                  : IconButton(
                      onPressed: () async {
                        showConfirmationDialog(
                          context: context,
                          title: "Delete Doctor",
                          message: "Do you want to Delete ${widget.doctor?.name ?? "this Doctor"}?",
                          onConfirm: () async {
                            customLoading(context, "");
                            bool connection = await InternetConnection().hasInternetAccess;
                            if (!connection) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                  "No Internet Connection",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              await DoctorCubit.get(context).deleteDoctor(id: widget.doctor!.id.toString(), context: context);
                            }
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colorz.redColor,
                      )),
            ]),
          ),
        ),
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
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        final cubit = context.read<DoctorCubit>();
        bool isLoading = DoctorCubit.get(context).doctors == null;
        bool isEmpty = DoctorCubit.get(context).doctors?.doctors?.isEmpty ?? true;
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

  Widget _buildOrderList(DoctorCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          DoctorCard(
            doctor: cubit.doctors!.doctors?[index],
            isLoading: false,
          ),
          cubit.doctors!.doctors?.length != index + 1
              ? const SizedBox.shrink()
              : cubit.doctors?.totalPages != null && cubit.doctors!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: cubit.page,
                          totalPages: int.parse('${cubit.doctors?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            cubit.page = newPage;
                            cubit.getDoctors();
                            setState(() {});
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.doctors!.doctors!.length,
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
