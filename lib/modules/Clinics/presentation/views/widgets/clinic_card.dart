import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/clinic_actions_cubit/clinic_actions_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/utils/app_style.dart';
import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/utils/snackbar_service.dart';
import '../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../core/widgets/pagination.dart';
import '../../../../../../core/widgets/width_spacer.dart';
import '../../../data/model/clinics_model.dart';
import 'clinic_form_dialog.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClinicActionsCubit.get(context);
    return GestureDetector(
      onTap: () {
        // View clinic details
        showClinicFormDialog(
          context,
          mode: ClinicFormMode.view,
          actionsCubit: context.read<ClinicActionsCubit>(),
          clinicId: widget.clinic?.id ?? "",
        );
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
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                            color: Theme.of(context).cardColor,
                          ),
                        ))
                      : Text(
                          widget.clinic?.name ?? "N/A",
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                  const HeightSpacer(size: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.isLoading
                          ? _buildShimmer(Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                color: Theme.of(context).cardColor,
                              ),
                            ))
                          : Expanded(
                              child: Text(
                                '${widget.clinic?.description ?? "N/A"} ',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: appStyle(
                                    context, 18, Colorz.grey, FontWeight.w500),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            widget.isLoading
                ? _buildShimmer(Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                    ),
                  ))
                : IconButton(
                    onPressed: () async {
                      showConfirmationDialog(
                        context: context,
                        title: "Delete Clinic?",
                        message:
                            "This action cannot be undone. Are you sure you want to permanently delete ${widget.clinic?.name ?? "this clinic"}?",
                        confirmText: "Delete",
                        confirmColor: Colors.redAccent,
                        icon: Icons.delete_forever,
                        onConfirm: () async {
                          customLoading(context, "Deleting Clinic...");
                          bool connection =
                              await InternetConnection().hasInternetAccess;
                          if (!connection) {
                            Navigator.pop(context);
                            SnackbarService.showError(
                              context,
                              message: "No Internet Connection",
                            );
                          } else {
                            cubit.add(DeleteClinicEvent(
                                widget.clinic!.id.toString()));
                          }
                        },
                      );
                    },
                    icon: Icon(Icons.delete_forever,
                        color: Colorz.redColor, size: 30.w))
          ]),
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
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
      builder: (context, state) {
        final cubit = context.read<GetClinicsCubit>();
        bool isLoading = state.isLoading;
        bool isEmpty = state.clinics?.clinics.isEmpty ?? true;
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

  Widget _buildOrderList(GetClinicsCubit cubit) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ClinicCard(
            clinic: cubit.state.clinics!.clinics[index],
            isLoading: false,
          ),
          cubit.state.clinics!.clinics.length != index + 1
              ? const SizedBox.shrink()
              : cubit.state.clinics?.totalPages != null &&
                      cubit.state.clinics!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20)
                          .copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: cubit.state.page,
                          totalPages: int.parse(
                              '${cubit.state.clinics?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            cubit.add(SetPageEvent(newPage));
                            cubit.add(GetAllClinicsEvent());
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: cubit.state.clinics!.clinics.length,
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
            Icon(Icons.inbox_outlined,
                size: 70,
                color:
                    Theme.of(context).iconTheme.color?.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'No Clinic found',
              style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Clinic will appear here',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
