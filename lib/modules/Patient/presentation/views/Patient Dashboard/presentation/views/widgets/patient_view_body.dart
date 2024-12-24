import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../core/widgets/search_fileld.dart';
import '../../../../../manager/patient_cubit.dart';
import '../../../../../manager/patient_state.dart';
import 'patient_card.dart';

class PatientViewBody extends StatefulWidget {
  const PatientViewBody({super.key});

  @override
  State<PatientViewBody> createState() => _PatientViewBodyState();
}

class _PatientViewBodyState extends State<PatientViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) => Column(
        children: [_buildSearchField(PatientCubit.get(context)), const HeightSpacer(size: 10), const PatientListView()],
      ),
    );
  }

  Widget _buildSearchField(PatientCubit cubit) {
    return SearchField(
        onTextFieldChanged: () => cubit.getPatients(),
        searchController: cubit.searchController,
        onClose: () {
          cubit.searchController.clear();
          cubit.getPatients();
        });
  }
}
