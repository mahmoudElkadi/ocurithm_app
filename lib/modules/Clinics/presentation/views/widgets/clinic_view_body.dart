import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';

import '../../../../../../core/widgets/height_spacer.dart';
import '../../manager/clinic_cubit.dart';
import '../../manager/clinic_state.dart';
import 'clinic_card.dart';

class ClinicViewBody extends StatefulWidget {
  const ClinicViewBody({super.key});

  @override
  State<ClinicViewBody> createState() => _ClinicViewBodyState();
}

class _ClinicViewBodyState extends State<ClinicViewBody> {
  @override
  Widget build(BuildContext context) {
    final cubit = ClinicCubit.get(context);
    return BlocBuilder<ClinicCubit, ClinicState>(
      builder: (context, state) => Column(
        children: [_buildSearchField(cubit), const HeightSpacer(size: 10), const ClinicListView()],
      ),
    );
  }

  Widget _buildSearchField(ClinicCubit cubit) {
    return SearchField(
        onTextFieldChanged: () => cubit.getClinics(),
        searchController: cubit.searchController,
        onClose: () {
          cubit.searchController.clear();
          cubit.getClinics();
        });
  }
}
