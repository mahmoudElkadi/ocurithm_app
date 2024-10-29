import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/utils/app_style.dart';
import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../../core/widgets/pagination.dart';
import '../../../../../../../../../core/widgets/width_spacer.dart';
import '../../../../../../data/models/receptionists_model.dart';
import '../../../../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../../../../manger/Receptionist Details Cubit/receptionist_details_state.dart';
import '../../../../Receptionist Details/presentation/view/receptionist_details_view.dart';

class ReceptionistCard extends StatefulWidget {
  const ReceptionistCard({
    super.key,
    required this.isLoading,
    this.receptionist,
  });
  final bool isLoading;
  final Receptionist? receptionist;

  @override
  State<ReceptionistCard> createState() => _ReceptionistCardState();
}

class _ReceptionistCardState extends State<ReceptionistCard> {
  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceptionistCubit, ReceptionistState>(
      builder: (context, state) => GestureDetector(
        onTap: () {
          Get.to(() => ReceptionistDetailsView(cubit: ReceptionistCubit.get(context), id: widget.receptionist!.id!));
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
                      child: widget.receptionist?.image != null
                          ? AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  image: DecorationImage(
                                      image: NetworkImage(widget.receptionist?.image ?? "https://via.placeholder.com/150"),
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
                              child: widget.receptionist?.name != null
                                  ? Center(
                                      child: Text(widget.receptionist?.name?.split("")[0].toUpperCase() as String,
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
                            widget.receptionist?.name ?? "N/A",
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
                            await Clipboard.setData(ClipboardData(text: widget.receptionist?.phone ?? "N/A"));
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
                                  widget.receptionist?.phone ?? "N/A",
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
                    title: "Delete Receptionist",
                    message: "Do you want to Delete ${widget.receptionist?.name ?? "this Receptionist"}?",
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
                        await ReceptionistCubit.get(context).deleteReceptionist(id: widget.receptionist!.id.toString(), context: context);
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
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class ReceptionistListView extends StatefulWidget {
  const ReceptionistListView({Key? key}) : super(key: key);

  @override
  State<ReceptionistListView> createState() => _ReceptionistListViewState();
}

class _ReceptionistListViewState extends State<ReceptionistListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceptionistCubit, ReceptionistState>(
      builder: (context, state) {
        final cubit = context.read<ReceptionistCubit>();
        bool isLoading = ReceptionistCubit.get(context).receptionists == null;
        bool isEmpty = ReceptionistCubit.get(context).receptionists?.receptionists.isEmpty ?? true;
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
      itemBuilder: (context, index) => const ReceptionistCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 3,
    );
  }

  Widget _buildOrderList(ReceptionistCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ReceptionistCard(
            receptionist: cubit.receptionists!.receptionists[index],
            isLoading: false,
          ),
          cubit.receptionists!.receptionists.length != index + 1
              ? const SizedBox.shrink()
              : cubit.receptionists?.totalPages != null && cubit.receptionists!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: cubit.page,
                          totalPages: int.parse('${cubit.receptionists?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            cubit.page = newPage;
                            cubit.getReceptionists();
                            setState(() {});
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.receptionists!.receptionists.length,
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
            'No Receptionist found',
            style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Receptionist will appear here',
            style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
