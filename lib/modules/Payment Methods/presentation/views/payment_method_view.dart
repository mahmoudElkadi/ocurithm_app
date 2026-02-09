import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';

import 'package:ocurithm/core/utils/snackbar_service.dart';

import '../manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';
import '../manager/payment_method_actions_cubit/payment_method_actions_cubit.dart';
import 'widgets/payment_method_form_dialog.dart';
import 'widgets/payment_method_view_body.dart';

/// Payment Methods View - Displays list of payment methods
/// Uses new cubits: GetPaymentMethodsCubit and PaymentMethodActionsCubit
class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GetPaymentMethodsCubit>()
            ..add(const GetAllPaymentMethodsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<PaymentMethodActionsCubit>(),
        ),
      ],
      child: BlocListener<PaymentMethodActionsCubit, PaymentMethodActionsState>(
        listener: (context, state) {
          // Handle Error
          if (state.isError) {
            SnackbarService.showError(
              context,
              message: state.errorMessage ?? 'An error occurred',
            );
          }

          // Handle No Connection
          if (state.noConnection) {
            SnackbarService.showWarning(
              context,
              message: state.errorMessage ?? 'No internet connection',
            );
          }

          // Handle Success
          if (state.isSuccess) {
            SnackbarService.showSuccess(
              context,
              message: state.successMessage ?? 'Operation successful',
            );

            // Refresh the list on any successful action
            context
                .read<GetPaymentMethodsCubit>()
                .add(const GetAllPaymentMethodsEvent());
          }
        },
        child: Builder(
          builder: (context) {
            return CustomScaffold(
              title: "Payment Methods",
              actions: [
                IconButton(
                  onPressed: () {
                    showPaymentMethodFormDialog(
                      context,
                      mode: PaymentMethodFormMode.add,
                      actionsCubit: context.read<PaymentMethodActionsCubit>(),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/add_branch.svg",
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
              body: CustomMaterialIndicator(
                onRefresh: () async {
                  context
                      .read<GetPaymentMethodsCubit>()
                      .add(const GetAllPaymentMethodsEvent());
                },
                indicatorBuilder:
                    (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child:  SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: PaymentMethodViewBody(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
