import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/no_internet.dart';
import '../../../../../core/widgets/width_spacer.dart';
import '../../../data/model/save_reason_model.dart';
import '../../manager/get_save_reasons_cubit/get_save_reasons_cubit.dart';
import '../../manager/save_reason_actions_cubit/save_reason_actions_cubit.dart';
import 'save_reason_form_dialog.dart';

/// One save reason in the configuration list.
class SaveReasonCard extends StatelessWidget {
  const SaveReasonCard({
    super.key,
    required this.isLoading,
    this.saveReason,
  });

  final bool isLoading;
  final SaveReason? saveReason;

  Widget _buildShimmer(BuildContext context, Widget child) {
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
    final actionsCubit = context.read<SaveReasonActionsCubit>();

    return GestureDetector(
      onTap: () {
        if (!isLoading && saveReason != null) {
          showSaveReasonFormDialog(
            context,
            mode: SaveReasonFormMode.edit,
            actionsCubit: actionsCubit,
            saveReason: saveReason,
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
                ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1)
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
              const WidthSpacer(size: 10),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeightSpacer(size: 5),
                    isLoading
                        ? _buildShimmer(
                            context,
                            Container(
                              width: 170,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          )
                        : Text(
                            saveReason?.name ?? "N/A",
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              textStyle: appStyle(
                                context,
                                18,
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black,
                                FontWeight.w700,
                              ).copyWith(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                    const HeightSpacer(size: 5),
                    isLoading
                        ? _buildShimmer(
                            context,
                            Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20)),
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          )
                        : Text(
                            'Price: ${saveReason?.price ?? 0}',
                            style: appStyle(
                              context,
                              18,
                              isDark ? Colors.grey.shade400 : Colors.grey,
                              FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        showConfirmationDialog(
                          context: context,
                          title: "Delete Save Reason",
                          message:
                              "Do you want to delete ${saveReason?.name ?? "this save reason"}?",
                          onConfirm: () {
                            actionsCubit
                                .add(DeleteSaveReasonEvent(saveReason!.id!));
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                icon: Icon(Icons.delete_forever, color: Colors.red, size: 30.w),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The save-reason list, with its loading, error and empty states.
class SaveReasonListView extends StatelessWidget {
  const SaveReasonListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSaveReasonsCubit, GetSaveReasonsState>(
      builder: (context, state) {
        final isEmpty = state.saveReasons?.saveReasons?.isEmpty ?? true;

        if (state.isLoading && state.saveReasons == null) {
          return _buildLoadingList();
        }

        if (state.noConnection && state.saveReasons == null) {
          return NoInternet(
            onPressed: () => context
                .read<GetSaveReasonsCubit>()
                .add(const GetAllSaveReasonsEvent()),
          );
        }

        if (state.isError && state.saveReasons == null) {
          return _buildErrorState(
            context,
            state.errorMessage ?? 'An error occurred',
          );
        }

        if (isEmpty && !state.isLoading) {
          return _buildEmptyState(context);
        }

        final saveReasons = state.saveReasons?.saveReasons ?? [];

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => SaveReasonCard(
            saveReason: saveReasons[index],
            isLoading: false,
          ),
          separatorBuilder: (context, index) => const HeightSpacer(size: 20),
          itemCount: saveReasons.length,
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const SaveReasonCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),
            const HeightSpacer(size: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const HeightSpacer(size: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<GetSaveReasonsCubit>()
                  .add(const GetAllSaveReasonsEvent()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              'No Save Reasons found',
              style: TextStyle(
                fontSize: 22,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Doctors will be asked to pick one when saving a visit',
              textAlign: TextAlign.center,
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
