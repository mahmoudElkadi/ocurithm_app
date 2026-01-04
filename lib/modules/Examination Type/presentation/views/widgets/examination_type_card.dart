import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/snackbar_service.dart';
import '../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/pagination.dart';
import '../../../../../core/widgets/width_spacer.dart';
import '../../../data/model/examination_type_model.dart';
import '../../manager/examination_type_actions_cubit/examination_type_actions_cubit.dart';
import '../../manager/get_examination_types_cubit/get_examination_types_cubit.dart';
import 'examination_type_form_dialog.dart';

/// Examination Type Card - Displays individual examination type
/// Uses new cubits for actions and theme support
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionsCubit = context.read<ExaminationTypeActionsCubit>();

    return BlocListener<ExaminationTypeActionsCubit,
        ExaminationTypeActionsState>(
      listener: (context, state) {
        // Handle delete success
        if (state.isDeleteSuccess) {
          SnackbarService.showSuccess(
            context,
            message:
                state.successMessage ?? 'Examination type deleted successfully',
          );
          // Refresh the list
          context
              .read<GetExaminationTypesCubit>()
              .add(const GetAllExaminationTypesEvent());
        }

        // Handle delete error
        if (state.isDeleteError) {
          SnackbarService.showError(
            context,
            message: state.errorMessage ?? 'Failed to delete examination type',
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!widget.isLoading && widget.examinationType != null) {
            showExaminationTypeFormDialog(
              context,
              mode: ExaminationTypeFormMode.edit,
              actionsCubit: actionsCubit,
              examinationTypeId: widget.examinationType!.id,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: isDark
                  ? Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                const WidthSpacer(size: 10),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeightSpacer(size: 5),
                      // Name
                      widget.isLoading
                          ? _buildShimmer(Container(
                              width: 170,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).cardColor,
                              ),
                            ))
                          : Text(
                              widget.examinationType?.name ?? "N/A",
                              maxLines: 2,
                              style: GoogleFonts.inter(
                                textStyle: appStyle(
                                  context,
                                  18,
                                  Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color ??
                                      Colors.black,
                                  FontWeight.w700,
                                ).copyWith(overflow: TextOverflow.ellipsis),
                              ),
                            ),
                      const HeightSpacer(size: 5),
                      // Price and Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          GestureDetector(
                            onLongPress: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      '${widget.examinationType?.price ?? "N/A"} '));
                              if (mounted) {
                                SnackbarService.showSuccess(
                                  context,
                                  message: "Price copied to clipboard",
                                );
                              }
                            },
                            child: widget.isLoading
                                ? _buildShimmer(Container(
                                    width: 100,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ))
                                : Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 16,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey,
                                      ),
                                      Text(
                                        '${widget.examinationType?.price ?? "N/A"}',
                                        style: appStyle(
                                          context,
                                          16,
                                          isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey,
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          // Duration
                          if (!widget.isLoading &&
                              widget.examinationType?.duration != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.examinationType?.duration} min',
                                  style: appStyle(
                                    context,
                                    16,
                                    isDark ? Colors.grey.shade400 : Colors.grey,
                                    FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  onPressed: widget.isLoading
                      ? null
                      : () async {
                          showConfirmationDialog(
                            context: context,
                            title: "Delete Examination Type",
                            message:
                                "Do you want to delete ${widget.examinationType?.name ?? "this examination type"}?",
                            onConfirm: () {
                              Navigator.pop(
                                  context); // Close confirmation dialog
                              actionsCubit.add(DeleteExaminationTypeEvent(
                                  widget.examinationType!.id!));
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 30.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Examination Type List View - Displays list of examination types with pagination
/// Uses GetExaminationTypesCubit for data
class ExaminationTypeListView extends StatefulWidget {
  const ExaminationTypeListView({super.key});

  @override
  State<ExaminationTypeListView> createState() =>
      _ExaminationTypeListViewState();
}

class _ExaminationTypeListViewState extends State<ExaminationTypeListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExaminationTypesCubit, GetExaminationTypesState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        final isEmpty =
            state.examinationTypes?.examinationTypes?.isEmpty ?? true;

        if (isLoading && state.examinationTypes == null) {
          return _buildLoadingList();
        } else if (isEmpty && !isLoading) {
          return _buildEmptyState();
        } else {
          return _buildExaminationTypeList(state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) =>
          const ExaminationTypeCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildExaminationTypeList(GetExaminationTypesState state) {
    final examinationTypes = state.examinationTypes?.examinationTypes ?? [];
    final totalPages = state.examinationTypes?.totalPages?.toInt() ?? 0;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ExaminationTypeCard(
            examinationType: examinationTypes[index],
            isLoading: false,
          ),
          // Show pagination on last item if there are multiple pages
          if (index == examinationTypes.length - 1 && totalPages > 1)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
              child: CustomPagination(
                currentPage: state.currentPage,
                totalPages: totalPages,
                onPageChanged: (int newPage) {
                  context
                      .read<GetExaminationTypesCubit>()
                      .add(const GetAllExaminationTypesEvent());
                  setState(() {});
                },
              ),
            )
          else if (index == examinationTypes.length - 1)
            const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: examinationTypes.length,
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeightSpacer(size: 30),
            Icon(
              Icons.inbox_outlined,
              size: 70,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Examination Types found',
              style: TextStyle(
                fontSize: 22,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Examination types will appear here',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
