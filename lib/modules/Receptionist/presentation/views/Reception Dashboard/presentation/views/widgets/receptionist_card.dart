import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ocurithm/core/widgets/confirmation_popuo.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/modules/Receptionist/data/models/receptionists_model.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/get_receptionists_cubit/get_receptionists_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/manager/receptionist_actions_cubit/receptionist_actions_cubit.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/receptionist_form/receptionist_form_page.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.isLoading
          ? null
          : () async {
              // Navigate to view mode
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceptionistFormPage(
                    mode: ReceptionistFormMode.view,
                    receptionistId: widget.receptionist!.id!,
                  ),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: Colors.white.withValues(alpha:0.1))
                : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Profile Image
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
                      child: widget.receptionist?.image != null
                          ? AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.cardColor,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.receptionist?.image ??
                                          "https://via.placeholder.com/150",
                                    ),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
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
                                border: Border.all(
                                  color: theme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: widget.receptionist?.name != null
                                  ? Center(
                                      child: Text(
                                        widget.receptionist!.name!
                                            .split("")[0]
                                            .toUpperCase(),
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                    ),
              const WidthSpacer(size: 10),

              // Name and Phone
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
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                    const HeightSpacer(size: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                  text: widget.receptionist?.phone ?? "N/A"),
                            );
                            if (mounted) {
                              SnackbarService.showSuccess(
                                context,
                                message: "Copied",
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
                                  widget.receptionist?.phone ?? "N/A",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete Button
              if (CacheHelper.getStringList(key: "capabilities")
                  .contains("manageReciptionists"))
                BlocListener<ReceptionistActionsCubit,
                    ReceptionistActionsState>(
                  listener: (context, state) {
                    if (state.isDeleteSuccess) {
                      Navigator.pop(context); // Close loading
                      SnackbarService.showSuccess(
                        context,
                        message: state.successMessage ?? 'Deleted successfully',
                      );
                      // Refresh list
                      context
                          .read<GetReceptionistsCubit>()
                          .add(GetAllReceptionistsEvent());
                    } else if (state.isDeleteError) {
                      Navigator.pop(context); // Close loading
                      SnackbarService.showError(
                        context,
                        message: state.errorMessage ?? 'Failed to delete',
                      );
                    }
                  },
                  child: IconButton(
                    onPressed: () async {
                      showConfirmationDialog(
                        context: context,
                        title: "Delete Receptionist",
                        message:
                            "Do you want to Delete ${widget.receptionist?.name ?? "this Receptionist"}?",
                        onConfirm: () async {
                          customLoading(context, "");

                            // Dispatch delete event
                            context.read<ReceptionistActionsCubit>().add(
                                  DeleteReceptionistEvent(
                                      widget.receptionist!.id!),
                                );

                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
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
    return BlocBuilder<GetReceptionistsCubit, GetReceptionistsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildLoadingList();
        } else if (state.receptionists == null ||
            state.receptionists!.receptionists.isEmpty) {
          return _buildEmptyState();
        } else {
          return _buildReceptionistList(state);
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

  Widget _buildReceptionistList(GetReceptionistsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ReceptionistCard(
            receptionist: state.receptionists!.receptionists[index],
            isLoading: false,
          ),
          state.receptionists!.receptionists.length != index + 1
              ? const SizedBox.shrink()
              : state.receptionists?.totalPages != null &&
                      state.receptionists!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20)
                          .copyWith(bottom: 20),
                      child: CustomPagination(
                        currentPage: state.page,
                        totalPages: int.parse(
                            '${state.receptionists?.totalPages ?? 0}'),
                        onPageChanged: (int newPage) {
                          context.read<GetReceptionistsCubit>().add(
                                SetPageEvent(newPage),
                              );
                          context.read<GetReceptionistsCubit>().add(
                                GetAllReceptionistsEvent(),
                              );
                        },
                      ),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.receptionists!.receptionists.length,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 30),
          Icon(
            Icons.inbox_outlined,
            size: 70,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Receptionist found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Receptionists will appear here',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha:0.7),
            ),
          ),
        ],
      ),
    );
  }
}
