import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/Reception%20Dashboard/presentation/views/widgets/receptionist_card.dart';

import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../core/widgets/search_fileld.dart';
import '../../../../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../../../../manger/Receptionist Details Cubit/receptionist_details_state.dart';

class ReceptionistViewBody extends StatefulWidget {
  const ReceptionistViewBody({super.key});

  @override
  State<ReceptionistViewBody> createState() => _ReceptionistViewBodyState();
}

class _ReceptionistViewBodyState extends State<ReceptionistViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceptionistCubit, ReceptionistState>(
      builder: (context, state) => Column(
        children: [
          _buildSearchField(ReceptionistCubit.get(context)),
          const HeightSpacer(size: 10),
          Expanded(
            child: CustomMaterialIndicator(
                onRefresh: () async {
                  try {
                    ReceptionistCubit.get(context).page = 1;
                    ReceptionistCubit.get(context).searchController.clear();
                    await ReceptionistCubit.get(context).getReceptionists();
                  } catch (e) {
                    log(e.toString());
                  }
                },
                indicatorBuilder: (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child: const ReceptionistListView()),
          )
        ],
      ),
    );
  }

  Widget _buildSearchField(ReceptionistCubit cubit) {
    return SearchField(
        onTextFieldChanged: () => cubit.getReceptionists(),
        searchController: cubit.searchController,
        onClose: () {
          cubit.searchController.clear();
          cubit.getReceptionists();
        });
  }
}
