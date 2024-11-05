import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../core/widgets/text_field.dart';
import '../../manager/payment_method_cubit.dart';
import '../../manager/payment_method_state.dart';
import 'payment_method_card.dart';

class PaymentMethodViewBody extends StatefulWidget {
  const PaymentMethodViewBody({super.key});

  @override
  State<PaymentMethodViewBody> createState() => _PaymentMethodViewBodyState();
}

class _PaymentMethodViewBodyState extends State<PaymentMethodViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final cubit = PaymentMethodCubit.get(context);
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) => Column(
        children: [_buildSearchField(cubit), const HeightSpacer(size: 10), const PaymentMethodListView()],
      ),
    );
  }

  Widget _buildSearchField(PaymentMethodCubit cubit) {
    return Container(
      color: Colorz.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
        ).copyWith(bottom: 10, top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField2(
                controller: cubit.searchController,
                hintText: "Search...",
                hintStyle: TextStyle(color: Colorz.primaryColor, fontSize: 14.sp, fontWeight: FontWeight.w400),
                height: 7,
                fillColor: Colorz.primaryColor.withOpacity(0.03),
                radius: 30,
                isShadow: false,
                borderColor: Colorz.primaryColor,
                prefixIcon: Icon(Icons.search, size: 30, color: Colorz.primaryColor),
                onTextFieldChanged: (value) {
                  cubit.getPaymentMethods();
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    cubit.searchController.clear();
                    cubit.getPaymentMethods();
                  },
                  icon: Icon(Icons.close, color: Colorz.primaryColor),
                ),
                required: false,
              ),
            ),
            // const WidthSpacer(size: 5),
            // GestureDetector(
            //   onTap: () async {
            //     FocusScope.of(context).unfocus();
            //     bool isShow = false;
            //     //  isShow = await showFilterBottomSheet(context, dashboardCubit: OrderDashboardCubit.get(context));
            //     if (isShow) {
            //       setState(() {});
            //     }
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(15),
            //       color: Colorz.primaryColor.withOpacity(0.03),
            //     ),
            //     child: SvgPicture.asset(
            //       "assets/icons/filter.svg",
            //       color: Colorz.primaryColor,
            //       width: 25,
            //       height: 25,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
