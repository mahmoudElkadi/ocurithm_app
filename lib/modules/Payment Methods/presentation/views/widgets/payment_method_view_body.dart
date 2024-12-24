import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/search_fileld.dart';
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
    return SearchField(
        onTextFieldChanged: () => cubit.getPaymentMethods(),
        searchController: cubit.searchController,
        onClose: () {
          cubit.searchController.clear();
          cubit.getPaymentMethods();
        });
  }
}
