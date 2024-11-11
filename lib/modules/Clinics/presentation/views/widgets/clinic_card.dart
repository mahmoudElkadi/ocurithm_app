import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/app_style.dart';
import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../core/widgets/pagination.dart';
import '../../../../../../core/widgets/width_spacer.dart';
import '../../../data/model/clinics_model.dart';
import '../../manager/clinic_cubit.dart';
import '../../manager/clinic_state.dart';
import 'edit_clinic_method.dart';

class ClinicCard extends StatefulWidget {
  const ClinicCard({
    super.key,
    required this.isLoading,
    this.clinic,
  });
  final bool isLoading;
  final Clinic? clinic;

  @override
  State<ClinicCard> createState() => _ClinicCardState();
}

class _ClinicCardState extends State<ClinicCard> {
  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClinicCubit.get(context);
    return BlocBuilder<ClinicCubit, ClinicState>(
      builder: (context, state) => GestureDetector(
        onTap: () {
          editClinic(context, ClinicCubit.get(context), widget.clinic?.id ?? "");
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
            decoration: BoxDecoration(color: Colorz.white, borderRadius: BorderRadius.circular(10), boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ]),
            child: Row(children: [
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
                            widget.clinic?.name ?? "N/A",
                            maxLines: 2,
                            style: GoogleFonts.inter(
                                textStyle: appStyle(context, 18, HexColor("#2A282F"), FontWeight.w700).copyWith(overflow: TextOverflow.ellipsis)),
                          ),
                    const HeightSpacer(size: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.isLoading
                            ? _buildShimmer(Container(
                                width: 100,
                                height: 20,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Colors.white,
                                ),
                              ))
                            : Text(
                                '${widget.clinic?.description ?? "N/A"} ',
                                style: appStyle(context, 18, Colorz.grey, FontWeight.w500),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () async {
                    showConfirmationDialog(
                      context: context,
                      title: "Delete Clinic",
                      message: "Do you want to Delete ${widget.clinic?.name ?? "this Clinic"}?",
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
                          await cubit.deleteClinic(id: widget.clinic!.id.toString(), context: context);
                        }
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                  icon: Icon(Icons.delete_forever, color: Colorz.redColor, size: 30.w))
            ]),
          ),
        ),
      ),
    );
  }
}

class ClinicListView extends StatefulWidget {
  const ClinicListView({super.key});

  @override
  State<ClinicListView> createState() => _ClinicListViewState();
}

class _ClinicListViewState extends State<ClinicListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicCubit, ClinicState>(
      builder: (context, state) {
        final cubit = context.read<ClinicCubit>();
        bool isLoading = cubit.clinics == null;
        bool isEmpty = cubit.clinics?.clinics.isEmpty ?? true;
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
      itemBuilder: (context, index) => const ClinicCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildOrderList(ClinicCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ClinicCard(
            clinic: cubit.clinics!.clinics?[index],
            isLoading: false,
          ),
          cubit.clinics!.clinics?.length != index + 1
              ? const SizedBox.shrink()
              : cubit.clinics?.totalPages != null && cubit.clinics!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: cubit.page,
                          totalPages: int.parse('${cubit.clinics?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            cubit.page = newPage;
                            cubit.getClinics();
                            setState(() {});
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.clinics!.clinics!.length,
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeightSpacer(size: 30),
            Icon(Icons.inbox_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Examination Type found',
              style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Examination Type will appear here',
              style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
