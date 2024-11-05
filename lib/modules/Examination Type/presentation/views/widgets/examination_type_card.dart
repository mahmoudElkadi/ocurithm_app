import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../data/model/examination_type_model.dart';
import '../../manager/examination_type_cubit.dart';
import '../../manager/examination_type_state.dart';
import 'edit_examination_type.dart';

class ExaminationTypeCard extends StatefulWidget {
  const ExaminationTypeCard({
    super.key,
    required this.isLoading,
    this.examinationType,
  });
  final bool isLoading;
  final ExaminationType? examinationType;

  @override
  State<ExaminationTypeCard> createState() => _ExaminationTypeCardState();
}

class _ExaminationTypeCardState extends State<ExaminationTypeCard> {
  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ExaminationTypeCubit.get(context);
    return BlocBuilder<ExaminationTypeCubit, ExaminationTypeState>(
      builder: (context, state) => GestureDetector(
        onTap: () {
          editExaminationType(context, ExaminationTypeCubit.get(context), widget.examinationType?.id ?? "");
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
                            widget.examinationType?.name ?? "N/A",
                            maxLines: 2,
                            style: GoogleFonts.inter(
                                textStyle: appStyle(context, 18, HexColor("#2A282F"), FontWeight.w700).copyWith(overflow: TextOverflow.ellipsis)),
                          ),
                    const HeightSpacer(size: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            await Clipboard.setData(ClipboardData(text: '${widget.examinationType?.price ?? "N/A"} '));
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
                                  '${widget.examinationType?.price ?? "N/A"} ',
                                  style: appStyle(context, 18, Colorz.grey, FontWeight.w500),
                                ),
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
                      title: "Delete ExaminationType",
                      message: "Do you want to Delete ${widget.examinationType?.name ?? "this Examination Type"}?",
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
                          await cubit.deleteExaminationType(id: widget.examinationType!.id.toString(), context: context);
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

class ExaminationTypeListView extends StatefulWidget {
  const ExaminationTypeListView({Key? key}) : super(key: key);

  @override
  State<ExaminationTypeListView> createState() => _ExaminationTypeListViewState();
}

class _ExaminationTypeListViewState extends State<ExaminationTypeListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExaminationTypeCubit, ExaminationTypeState>(
      builder: (context, state) {
        final cubit = context.read<ExaminationTypeCubit>();
        bool isLoading = cubit.examinationTypes == null;
        bool isEmpty = cubit.examinationTypes?.examinationTypes?.isEmpty ?? true;
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
      itemBuilder: (context, index) => const ExaminationTypeCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildOrderList(ExaminationTypeCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ExaminationTypeCard(
            examinationType: cubit.examinationTypes!.examinationTypes?[index],
            isLoading: false,
          ),
          cubit.examinationTypes!.examinationTypes?.length != index + 1
              ? const SizedBox.shrink()
              : cubit.examinationTypes?.totalPages != null && cubit.examinationTypes!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: cubit.page,
                          totalPages: int.parse('${cubit.examinationTypes?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            cubit.page = newPage;
                            cubit.getExaminationTypes();
                            setState(() {});
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.examinationTypes!.examinationTypes!.length,
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
