import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Examination/presentaion/views/widgets/examination_view_body.dart';

import '../manager/examination_cubit.dart';

class MultiStepFormPage extends StatelessWidget {
  const MultiStepFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExaminationCubit()..readJson(),
      child: const MultiStepFormView(),
    );
  }
}
