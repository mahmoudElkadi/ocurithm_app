import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Examination/data/repos/examination_repo_impl.dart';
import 'package:ocurithm/modules/Examination/presentaion/views/widgets/examination_view_body.dart';

import '../manager/examination_cubit.dart';

class MultiStepFormPage extends StatelessWidget {
  const MultiStepFormPage({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: BlocProvider(
        create: (_) => ExaminationCubit(ExaminationRepoImpl())
          ..readJson()
          ..setAppointment(appointment),
        child: MultiStepFormView(
          appointment: appointment,
        ),
      ),
    );
  }
}
