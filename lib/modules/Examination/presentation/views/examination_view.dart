import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/get_single_examination_cubit/get_single_examination_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_actions_cubit/examination_actions_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_form_cubit/examination_form_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/examination_view_body.dart';

class MultiStepFormPage extends StatelessWidget {
  const MultiStepFormPage(
      {super.key, required this.appointment, this.isSaved = false});

  final Appointment appointment;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              final cubit = sl<ExaminationFormCubit>();
              cubit.readJson();
              cubit.setAppointment(appointment);
              return cubit;
            },
          ),
          BlocProvider(
            create: (_) => sl<ExaminationActionsCubit>(),
          ),
          BlocProvider(
            create: (_) {
              final cubit = sl<GetSingleExaminationCubit>();
              if (isSaved) {
                cubit.getExamination(appointment.id.toString());
              }
              return cubit;
            },
          ),
        ],
        child:
            BlocListener<GetSingleExaminationCubit, GetSingleExaminationState>(
          listener: (context, state) {
            if (state is GetSingleExaminationSuccess) {
              context
                  .read<ExaminationFormCubit>()
                  .populateFromModel(state.examination);
            }
          },
          child: MultiStepFormView(
            appointment: appointment,
          ),
        ),
      ),
    );
  }
}
