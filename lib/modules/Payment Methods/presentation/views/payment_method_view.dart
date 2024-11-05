import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Payment%20Methods/presentation/views/widgets/add_payment_method.dart';
import 'package:ocurithm/modules/Payment%20Methods/presentation/views/widgets/payment_method_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../../data/repos/payment_method_repo_impl.dart';
import '../manager/payment_method_cubit.dart';
import '../manager/payment_method_state.dart';

class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentMethodCubit(PaymentMethodRepoImpl())..getPaymentMethods(),
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
        builder: (context, state) => CustomScaffold(
          title: "Payment Methods",
          actions: [
            IconButton(
              onPressed: () {
                showFormPopup(context, PaymentMethodCubit.get(context));
              },
              icon: SvgPicture.asset(
                "assets/icons/add_branch.svg",
                color: Colorz.primaryColor,
              ),
            ),
          ],
          body: CustomMaterialIndicator(
              onRefresh: () async {
                try {
                  PaymentMethodCubit.get(context).page = 1;
                  PaymentMethodCubit.get(context).searchController.clear();
                  await PaymentMethodCubit.get(context).getPaymentMethods();
                } catch (e) {
                  log(e.toString());
                }
              },
              indicatorBuilder: (BuildContext context, IndicatorController controller) {
                return Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: PaymentMethodCubit.get(context).connection != false
                      ? PaymentMethodViewBody()
                      : NoInternet(
                          onPressed: () {
                            PaymentMethodCubit.get(context).getPaymentMethods();
                          },
                        ))),
        ),
      ),
    );
  }
}
