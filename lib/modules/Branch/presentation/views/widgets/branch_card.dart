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
import '../../../data/model/branches_model.dart';
import '../../manager/branch_cubit.dart';
import '../../manager/branch_state.dart';
import 'edit_branch.dart';

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
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = AdminBranchCubit.get(context);
    return BlocBuilder<AdminBranchCubit, AdminBranchState>(
      builder: (context, state) => GestureDetector(
        onTap: () {
          editBranch(context, AdminBranchCubit.get(context), widget.branch?.id ?? "");
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
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 0))],
                        ),
                        child: widget.branch?.name != null
                            ? Center(
                                child: Text(widget.branch?.name?.split("")[0].toUpperCase() as String,
                                    style: appStyle(context, 30, Colors.grey.shade700, FontWeight.bold)))
                            : null,
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
                            widget.branch?.name ?? "N/A",
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
                            await Clipboard.setData(ClipboardData(text: widget.branch?.phone ?? "N/A"));
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
                                  widget.branch?.phone ?? "N/A",
                                  style: appStyle(context, 18, Colorz.grey, FontWeight.w400),
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
                      title: "Delete Branch",
                      message: "Do you want to Delete this Branch?",
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
                          await cubit.deleteBranch(id: widget.branch!.id.toString(), context: context);
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

class BranchListView extends StatefulWidget {
  const BranchListView({Key? key}) : super(key: key);

  @override
  State<BranchListView> createState() => _BranchListViewState();
}

class _BranchListViewState extends State<BranchListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBranchCubit, AdminBranchState>(
      builder: (context, state) {
        final cubit = context.read<AdminBranchCubit>();
        bool isLoading = cubit.branches == null;
        bool isEmpty = cubit.branches?.branches.isEmpty ?? true;
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
      itemBuilder: (context, index) => const BranchCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildOrderList(AdminBranchCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          BranchCard(
            branch: cubit.branches!.branches[index],
            isLoading: false,
          ),
          cubit.branches!.branches.length != index + 1
              ? const SizedBox.shrink()
              : cubit.branches?.totalPages != null && cubit.branches!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: cubit.page,
                          totalPages: int.parse('${cubit.branches?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            cubit.page = newPage;
                            cubit.getBranches();
                            setState(() {});
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.branches!.branches.length,
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
              'No Branch found',
              style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Branch will appear here',
              style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
