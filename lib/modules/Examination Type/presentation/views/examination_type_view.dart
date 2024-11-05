import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Examination%20Type/presentation/views/widgets/add_examination_type.dart';
import 'package:ocurithm/modules/Examination%20Type/presentation/views/widgets/examination_type_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../../data/repos/examination_type_repo_impl.dart';
import '../manager/examination_type_cubit.dart';
import '../manager/examination_type_state.dart';

class ExaminationTypeView extends StatelessWidget {
  const ExaminationTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExaminationTypeCubit(ExaminationTypeRepoImpl())..getExaminationTypes(),
      child: BlocBuilder<ExaminationTypeCubit, ExaminationTypeState>(
        builder: (context, state) => CustomScaffold(
          title: "Examination Types",
          actions: [
            IconButton(
              onPressed: () {
                showFormPopup(context, ExaminationTypeCubit.get(context));
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
                  ExaminationTypeCubit.get(context).page = 1;
                  ExaminationTypeCubit.get(context).searchController.clear();
                  await ExaminationTypeCubit.get(context).getExaminationTypes();
                } catch (e) {
                  log(e.toString());
                }
              },
              indicatorBuilder: (BuildContext context, IndicatorController controller) {
                return Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ExaminationTypeCubit.get(context).connection != false
                      ? ExaminationTypeViewBody()
                      : NoInternet(
                          onPressed: () {
                            ExaminationTypeCubit.get(context).getExaminationTypes();
                          },
                        ))),
        ),
      ),
    );
  }
}
