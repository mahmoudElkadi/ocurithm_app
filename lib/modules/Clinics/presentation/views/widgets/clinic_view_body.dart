import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

import '../../../../../../core/widgets/height_spacer.dart';

import 'clinic_card.dart';

class ClinicViewBody extends StatefulWidget {
  const ClinicViewBody({super.key});

  @override
  State<ClinicViewBody> createState() => _ClinicViewBodyState();
}

class _ClinicViewBodyState extends State<ClinicViewBody> {

  late TextEditingController searchController;


  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = GetClinicsCubit.get(context);
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
      builder: (context, state)
        {return  Column(
        children: [_buildSearchField(cubit), const HeightSpacer(size: 10), const ClinicListView()],
      );}
    );
  }

  Widget _buildSearchField(GetClinicsCubit cubit) {
    return SearchField(
        onTextFieldChanged: () async => cubit.onSearchChanged(searchController.text),
        searchController: searchController,
        onClose: () {
          searchController.clear();
          cubit.add(ResetFiltersEvent());

        });
  }
}
