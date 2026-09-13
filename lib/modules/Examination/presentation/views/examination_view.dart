import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Examination/data/repos/examination_repo.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/get_single_examination_cubit/get_single_examination_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_actions_cubit/examination_actions_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_form_cubit/examination_form_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/examination_view_body.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/examination_shimmer.dart';
import 'package:ocurithm/modules/Appointment/presentation/manager/Appointment cubit/appointment_cubit.dart';

/// How often this client tells the server it is still examining. Well inside the
/// server's 30-minute stale window, so a live screen is never taken over.
const Duration _sessionHeartbeatInterval = Duration(minutes: 5);

class MultiStepFormPage extends StatefulWidget {
  const MultiStepFormPage({
    super.key,
    required this.appointment,
    this.isSaved = false,
    this.sessionId,
  });

  final Appointment appointment;
  final bool isSaved;

  /// The lock claimed by the appointment list before this page was opened. Absent
  /// only if the caller could not claim one, in which case no heartbeat runs.
  final String? sessionId;

  @override
  State<MultiStepFormPage> createState() => _MultiStepFormPageState();
}

class _MultiStepFormPageState extends State<MultiStepFormPage> {
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();

    final sessionId = widget.sessionId;
    if (sessionId != null) {
      _heartbeatTimer = Timer.periodic(_sessionHeartbeatInterval, (_) {
        // Best-effort: a missed beat only shortens the window before the session
        // is considered stale, it never interrupts the doctor.
        sl<ExaminationRepo>()
            .heartbeatExaminationSession(sessionId: sessionId)
            .catchError((_) {});
      });
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();

    final sessionId = widget.sessionId;
    if (sessionId != null) {
      // Leaving the screen hands the appointment back immediately rather than
      // waiting out the stale window.
      sl<ExaminationRepo>()
          .closeExaminationSession(sessionId: sessionId)
          .catchError((_) {});
    }

    super.dispose();
  }

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
              cubit.setAppointment(widget.appointment);
              return cubit;
            },
          ),
          BlocProvider(
            create: (_) => sl<ExaminationActionsCubit>(),
          ),
          BlocProvider(
            create: (_) {
              final cubit = sl<GetSingleExaminationCubit>();
              if (widget.isSaved) {
                cubit.getExamination(widget.appointment.id.toString());
              }
              return cubit;
            },
          ),
          BlocProvider(
            create: (_) => sl<AppointmentCubit>(),
          ),
        ],
        child:
            BlocConsumer<GetSingleExaminationCubit, GetSingleExaminationState>(
          listener: (context, state) {
            if (state is GetSingleExaminationSuccess) {
              context
                  .read<ExaminationFormCubit>()
                  .populateFromModel(state.examination);
            }
          },
          builder: (context, state) {
            if (state is GetSingleExaminationLoading) {
              return const ExaminationFormShimmer();
            } else if (state is GetSingleExaminationError) {
              return Scaffold(
                body: NoInternet(
                  onPressed: () {
                    context
                        .read<GetSingleExaminationCubit>()
                        .getExamination(widget.appointment.id.toString());
                  },
                ),
              );
            }
            return MultiStepFormView(
              appointment: widget.appointment,
            );
          },
        ),
      ),
    );
  }
}
