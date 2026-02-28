import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../../../../../core/utils/app_style.dart';
import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../../core/widgets/pagination.dart';
import '../../../../../../../../../core/utils/snackbar_service.dart';
import '../../../../../../../../../core/widgets/width_spacer.dart';
import '../../../../../../../../core/Network/shared.dart';
import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../data/model/doctor_model.dart';
import '../../../../../manager/get_doctors_cubit/get_doctors_cubit.dart';
import '../../../../../manager/doctor_actions_cubit/doctor_actions_cubit.dart';
import '../../../../doctor_form/doctor_form_page.dart';

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
  Widget _buildShimmer(Widget child, ThemeData theme, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
      builder: (context, state) => GestureDetector(
        onTap: () async {
          final result = await Get.to(() => DoctorFormPage(
                mode: DoctorFormMode.view,
                doctorId: widget.doctor!.id!,
              ));
          // Refresh list if doctor was updated
          if (result == true && context.mounted) {
            context.read<GetDoctorsCubit>().add(GetAllDoctorsEvent());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
            decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ]),
            child: Row(children: [
              widget.isLoading
                  ? _buildShimmer(
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.cardColor,
                        ),
                      ),
                      theme,
                      isDark,
                    )
                  :
                  // : widget.item?.image != null
                  //     ?
                  Expanded(
                      flex: 1,
                      child: widget.doctor?.image != null &&
                              widget.doctor!.image!.isNotEmpty
                          ? AspectRatio(
                              aspectRatio: 1,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: widget.doctor!.image!,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: Text(
                                      widget.doctor?.name != null
                                          ? widget.doctor!.name![0].toUpperCase()
                                          : 'D',
                                      style: appStyle(
                                        context,
                                        25,
                                        Colors.grey.shade700,
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      widget.doctor?.name != null
                                          ? widget.doctor!.name![0].toUpperCase()
                                          : 'D',
                                      style: appStyle(
                                        context,
                                        25,
                                        Colors.grey.shade700,
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.cardColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.grey.shade200,
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 0))
                                ],
                              ),
                              child: widget.doctor?.name != null
                                  ? Center(
                                      child: Text(
                                          widget.doctor?.name
                                              ?.split("")[0]
                                              .toUpperCase() as String,
                                          style: appStyle(
                                              context,
                                              30,
                                              Colors.grey.shade700,
                                              FontWeight.bold)))
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
                        ? _buildShimmer(
                            Container(
                              width: 170,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: theme.cardColor,
                              ),
                            ),
                            theme,
                            isDark,
                          )
                        : Text(
                            widget.doctor?.name ?? "N/A",
                            maxLines: 2,
                            style: GoogleFonts.inter(
                                textStyle: appStyle(
                                        context,
                                        16,
                                        theme.textTheme.bodyLarge?.color ??
                                            HexColor("#2A282F"),
                                        FontWeight.w600)
                                    .copyWith(overflow: TextOverflow.ellipsis)),
                          ),
                    const HeightSpacer(size: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            await Clipboard.setData(ClipboardData(
                                text: "widget.item!.sku.toString()"));
                            SnackbarService.showSuccess(
                              context,
                              message: "Copied",
                            );
                          },
                          child: widget.isLoading
                              ? _buildShimmer(
                                  Container(
                                    width: 100,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Colors.white,
                                    ),
                                  ),
                                  theme,
                                  isDark,
                                )
                              : Text(
                                  widget.doctor?.phone ?? "N/A",
                                  style: appStyle(context, 18, Colorz.grey,
                                      FontWeight.w400),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (CacheHelper.getStringList(key: "capabilities")
                  .contains("manageDoctors"))
                widget.isLoading
                    ? _buildShimmer(
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.cardColor,
                          ),
                        ),
                        theme,
                        isDark,
                      )
                    : IconButton(
                        onPressed: () async {
                          showConfirmationDialog(
                            context: context,
                            title: "Delete Doctor",
                            message:
                                "Are you sure you want to delete ${widget.doctor?.name ?? "this doctor"}?",
                            onConfirm: () async {
                              customLoading(context, "Deleting Doctor...");
                              // Use DoctorActionsCubit for delete
                              context.read<DoctorActionsCubit>().add(
                                    DeleteDoctorEvent(widget.doctor!.id!),
                                  );
                            },
                            onCancel: () {},
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
    return BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
        builder: (context, state) {
          bool isLoading = state.isLoading;
          bool isEmpty = state.doctors?.doctors.isEmpty ?? true;

          if (isLoading) {
            return _buildLoadingList();
          } else if (isEmpty && state.isSuccess) {
            return _buildEmptyState();
          } else if (state.isSuccess) {
            return _buildDoctorList(state);
          } else if (state.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load doctors'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
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

  Widget _buildDoctorList(GetDoctorsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          DoctorCard(
            doctor: state.doctors!.doctors[index],
            isLoading: false,
          ),
          state.doctors!.doctors.length != index + 1
              ? const SizedBox.shrink()
              : state.doctors?.totalPages != null &&
                      state.doctors!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20)
                          .copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: state.page,
                          totalPages:
                              int.parse('${state.doctors?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            context.read<GetDoctorsCubit>().add(
                                  SetPageEvent(newPage),
                                );
                            context.read<GetDoctorsCubit>().add(
                                  GetAllDoctorsEvent(),
                                );
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.doctors!.doctors.length,
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
            style: TextStyle(
                fontSize: 22,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Doctor will appear here',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
