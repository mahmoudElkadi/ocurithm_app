import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../core/widgets/search_fileld.dart';
import '../../../../../manager/get_patients_cubit/get_patients_cubit.dart';
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
    return BlocBuilder<GetPatientsCubit, GetPatientsState>(
      builder: (context, state) => Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const PatientListView()
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final cubit = context.read<GetPatientsCubit>();
    return SearchField(
        onTextFieldChanged: ()async => cubit.onSearchChanged(searchController.text),
        searchController: searchController,
        onClose: () {
          searchController.clear();
          cubit.onSearchChanged('');
        });
  }
}
