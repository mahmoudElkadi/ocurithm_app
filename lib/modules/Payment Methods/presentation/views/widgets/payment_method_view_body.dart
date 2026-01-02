import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/search_fileld.dart';
import '../../manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';

import 'payment_method_card.dart';

/// Payment Method View Body - Contains search field and payment method list
/// Uses GetPaymentMethodsCubit for fetching and searching payment methods
class PaymentMethodViewBody extends StatefulWidget {
  const PaymentMethodViewBody({super.key});

  @override
  State<PaymentMethodViewBody> createState() => _PaymentMethodViewBodyState();
}

class _PaymentMethodViewBodyState extends State<PaymentMethodViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPaymentMethodsCubit, GetPaymentMethodsState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildSearchField(),
            const HeightSpacer(size: 10),
            const PaymentMethodListView(),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    final cubit = context.read<GetPaymentMethodsCubit>();

    return SearchField(
      searchController: _searchController,
      onTextFieldChanged: ()async {
        // Use debounced search from cubit
        cubit.onSearchChanged(_searchController.text);
      },
      onClose: () {
        _searchController.clear();
        cubit.onSearchChanged('');
      },
    );
  }
}
