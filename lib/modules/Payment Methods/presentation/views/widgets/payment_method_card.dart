import 'package:flutter/material.dart';
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
import '../../../data/model/payment_method_model.dart';
import '../../manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';
import '../../manager/payment_method_actions_cubit/payment_method_actions_cubit.dart';
import 'payment_method_form_dialog.dart';

/// Payment Method Card - Displays individual payment method
/// Uses new cubits for actions and theme support
class PaymentMethodCard extends StatefulWidget {
  const PaymentMethodCard({
    super.key,
    required this.isLoading,
    this.paymentMethod,
  });
  final bool isLoading;
  final PaymentMethod? paymentMethod;

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
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
    final actionsCubit = context.read<PaymentMethodActionsCubit>();

    return BlocListener<PaymentMethodActionsCubit, PaymentMethodActionsState>(
      listener: (context, state) {
        // Handle delete success
        if (state.isDeleteSuccess) {
          SnackbarService.showSuccess(
            context,
            message:
                state.successMessage ?? 'Payment method deleted successfully',
          );
          // Refresh the list
          context
              .read<GetPaymentMethodsCubit>()
              .add(const GetAllPaymentMethodsEvent());
        }

        // Handle delete error
        if (state.isDeleteError) {
          SnackbarService.showError(
            context,
            message: state.errorMessage ?? 'Failed to delete payment method',
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!widget.isLoading && widget.paymentMethod != null) {
            showPaymentMethodFormDialog(
              context,
              mode: PaymentMethodFormMode.edit,
              actionsCubit: actionsCubit,
              paymentMethodId: widget.paymentMethod!.id,
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
                      color: Colors.white.withValues(alpha:0.1),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.grey.withValues(alpha:0.2),
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
                      // Title
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
                              widget.paymentMethod?.title ?? "N/A",
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
                      // Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.isLoading
                              ? _buildShimmer(Container(
                                  width: 100,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    color: Theme.of(context).cardColor,
                                  ),
                                ))
                              : Expanded(
                                  child: Text(
                                    '${widget.paymentMethod?.description ?? "N/A"} ',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: appStyle(
                                      context,
                                      18,
                                      isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey,
                                      FontWeight.w500,
                                    ),
                                  ),
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
                            title: "Delete Payment Method",
                            message:
                                "Do you want to delete ${widget.paymentMethod?.title ?? "this payment method"}?",
                            onConfirm: () {
                              Navigator.pop(
                                  context); // Close confirmation dialog
                              actionsCubit.add(DeletePaymentMethodEvent(
                                  widget.paymentMethod!.id!));
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

/// Payment Method List View - Displays list of payment methods with pagination
/// Uses GetPaymentMethodsCubit for data
class PaymentMethodListView extends StatefulWidget {
  const PaymentMethodListView({super.key});

  @override
  State<PaymentMethodListView> createState() => _PaymentMethodListViewState();
}

class _PaymentMethodListViewState extends State<PaymentMethodListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPaymentMethodsCubit, GetPaymentMethodsState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        final isEmpty = state.paymentMethods?.paymentMethods?.isEmpty ?? true;

        if (isLoading && state.paymentMethods == null) {
          return _buildLoadingList();
        } else if (isEmpty && !isLoading) {
          return _buildEmptyState();
        } else {
          return _buildPaymentMethodList(state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const PaymentMethodCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildPaymentMethodList(GetPaymentMethodsState state) {
    final paymentMethods = state.paymentMethods?.paymentMethods ?? [];
    final totalPages = state.paymentMethods?.totalPages?.toInt() ?? 0;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          PaymentMethodCard(
            paymentMethod: paymentMethods[index],
            isLoading: false,
          ),
          // Show pagination on last item if there are multiple pages
          if (index == paymentMethods.length - 1 && totalPages > 1)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 20),
              child: CustomPagination(
                currentPage: state.currentPage,
                totalPages: totalPages,
                onPageChanged: (int newPage) {
                  context
                      .read<GetPaymentMethodsCubit>()
                      .add(GetAllPaymentMethodsEvent());
                  setState(() {});
                },
              ),
            )
          else if (index == paymentMethods.length - 1)
            const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: paymentMethods.length,
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
              'No Payment Methods found',
              style: TextStyle(
                fontSize: 22,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment methods will appear here',
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
