import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_actions_cubit/examination_actions_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/examination_pdf_service.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_one_examination_cubit/get_one_examination_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/views/examination_view/one_examination_content.dart';

class OneExaminationView extends StatefulWidget {
  const OneExaminationView({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<OneExaminationView> createState() => _OneExaminationViewState();
}

class _OneExaminationViewState extends State<OneExaminationView> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) =>
              sl<GetOneExaminationCubit>()..getExamination(widget.id),
        ),
        BlocProvider(create: (BuildContext context) => sl<ExaminationActionsCubit>()),
      ],
      child: BlocListener<ExaminationActionsCubit, ExaminationActionsState>(
        listener: (context, state) {
          if (state.status == ExaminationActionsStatus.success) {
            SnackbarService.showSuccess(context,
                message: state.message ?? "Examination deleted successfully");
            // The record no longer exists — return to the caller's list so it
            // isn't left pointing at a deleted examination.
            Get.back(result: true);
          } else if (state.status == ExaminationActionsStatus.error) {
            SnackbarService.showError(context,
                message: state.error ?? "Failed to delete examination");
          }
        },
        child: BlocBuilder<GetOneExaminationCubit, GetOneExaminationState>(
          builder: (BuildContext context, state) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colorz.primaryColor,
              title: const Text("Examination Details"),
              actions: [
                if (state.examination != null && !state.isLoading) ...[
                  IconButton(
                    onPressed: () {
                      ExaminationPdfService.generateAndPrintOneExamination(
                          state.examination!);
                    },
                    icon:
                        const Icon(Icons.print_outlined, color: Colors.white),
                  ),
                  // Matches web's canDeleteExamination gate
                  // (manageCapability || deleteExaminations).
                  if (CapabilityServices.hasCapability(
                      CapabilityKeys.deleteExaminations))
                    BlocBuilder<ExaminationActionsCubit,
                        ExaminationActionsState>(
                      builder: (context, actionsState) => IconButton(
                        onPressed:
                            actionsState.status == ExaminationActionsStatus.loading
                                ? null
                                : () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                    ),
                ],
              ],
            ),
            body: state.isLoading || state.examination == null
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colorz.primaryColor,
                  ))
                : OneExaminationContent(examination: state.examination!),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final actionsCubit = context.read<ExaminationActionsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete examination?"),
        // Wording mirrors web's confirmation (PatientDetails.tsx).
        content: const Text(
            "This will soft-delete the examination and its related data from normal views."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              actionsCubit.deleteExamination(widget.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
