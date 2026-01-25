import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/confirmation_popuo.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/modules/Branch/data/model/branches_model.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/branch_actions_cubit/branch_actions_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/views/widgets/branch_form_dialog.dart';
import 'package:shimmer/shimmer.dart';

class BranchCard extends StatefulWidget {
  const BranchCard({
    super.key,
    required this.isLoading,
    this.branch,
  });
  final bool isLoading;
  final Branch? branch;

  @override
  State<BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<BranchCard> {
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
    final actionsCubit = context.read<BranchActionsCubit>();

    return GestureDetector(
      onTap: () {
        if (!widget.isLoading && widget.branch?.id != null) {
          final clinicsState = context.read<GetBranchesCubit>().state;

          showBranchFormDialog(
            context,
            mode: BranchFormMode.edit,
            actionsCubit: actionsCubit,
            branchId: widget.branch!.id,
            clinics: null, // Can pass clinics if needed
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
            // Add subtle border in dark mode for better definition
            border: isDark
                ? Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              widget.isLoading
                  ? _buildShimmer(Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ))
                  : Expanded(
                      flex: 1,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey.shade200,
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 0),
                            )
                          ],
                        ),
                        child: widget.branch?.name != null
                            ? Center(
                                child: Text(
                                  widget.branch!.name!
                                      .split("")[0]
                                      .toUpperCase(),
                                  style: appStyle(
                                    context,
                                    30,
                                    isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                    FontWeight.bold,
                                  ),
                                ),
                              )
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
                            widget.branch?.name ?? "N/A",
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              textStyle: appStyle(
                                context,
                                16,
                                Theme.of(context).textTheme.bodyLarge!.color!,
                                FontWeight.w600,
                              ).copyWith(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                    const HeightSpacer(size: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            await Clipboard.setData(ClipboardData(
                                text: widget.branch?.phone ?? "N/A"));
                            if (mounted) {
                              SnackbarService.showSuccess(
                                context,
                                message: "Phone number copied",
                              );
                            }
                          },
                          child: widget.isLoading
                              ? _buildShimmer(Container(
                                  width: 100,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Colors.white,
                                  ),
                                ))
                              : Text(
                                  widget.branch?.phone ?? "N/A",
                                  style: appStyle(
                                    context,
                                    18,
                                    isDark ? Colors.grey.shade400 : Colors.grey,
                                    FontWeight.w400,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (CacheHelper.getStringList(key: "capabilities")
                  .contains("manageBranches"))
                IconButton(
                  onPressed: () async {
                    showConfirmationDialog(
                      context: context,
                      title: "Delete Branch?",
                      message:
                          "This action cannot be undone. Are you sure you want to permanently delete this branch?",
                      confirmText: "Delete",
                      confirmColor: Colors.redAccent,
                      icon: Icons.delete_forever,
                      onConfirm: () {
                        customLoading(context, "Deleting Branch...");
                        actionsCubit.add(DeleteBranchEvent(widget.branch!.id!));
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
    );
  }
}

class BranchListView extends StatefulWidget {
  const BranchListView({Key? key}) : super(key: key);

  @override
  State<BranchListView> createState() => _BranchListViewState();
}

class _BranchListViewState extends State<BranchListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBranchesCubit, GetBranchesState>(
      builder: (context, state) {
        final cubit = context.read<GetBranchesCubit>();
        bool isLoading = state.isLoading;
        bool isEmpty = state.branches?.branches.isEmpty ?? true;

        if (isLoading) {
          return _buildLoadingList();
        } else if (isEmpty && state.isSuccess) {
          return _buildEmptyState();
        } else if (state.isSuccess) {
          return _buildBranchList(cubit, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const BranchCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildBranchList(GetBranchesCubit cubit, GetBranchesState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          BranchCard(
            branch: state.branches!.branches[index],
            isLoading: false,
          ),
          state.branches!.branches.length != index + 1
              ? const SizedBox.shrink()
              : state.branches?.totalPages != null &&
                      state.branches!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20)
                          .copyWith(bottom: 20),
                      child: CustomPagination(
                        currentPage: state.page,
                        totalPages: 0,
                        onPageChanged: (int newPage) {
                          cubit.add(SetPageEvent(newPage));
                          cubit.add(GetAllBranchesEvent());
                        },
                      ),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.branches!.branches.length,
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
              'No Branch found',
              style: TextStyle(
                fontSize: 22,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Branches will appear here',
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
