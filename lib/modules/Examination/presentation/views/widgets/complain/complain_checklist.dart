import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/catalog/complain_catalog.dart';
import '../../../manager/examination_actions_cubit/examination_actions_cubit.dart';
import '../../../manager/examination_form_cubit/examination_form_cubit.dart';
import '../navigation_view.dart';
import 'complain_option_card.dart';
import 'other_complaints_section.dart';

/// Structured Complain step body (step 0). Renders the legacy "Other complaints"
/// section, the config-driven grouped option checklist, and the step navigation.
/// Fully decoupled from catalog content — growing the catalog needs no change here.
class ComplainChecklist extends StatelessWidget {
  const ComplainChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationFormCubit>();

    return BlocBuilder<ExaminationFormCubit, ExaminationFormState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chief Complaints',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tick the presenting complaints and fill in the details.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                for (final group in complainGroups)
                  _GroupSection(
                    key: ValueKey('grp_${group.key}'),
                    group: group,
                  ),
                // Web (cc5bc25) moved this below the catalog groups.
                const OtherComplaintsSection(),
                const SizedBox(height: 8),
                StepNavigation(
                  onPrevious: () => cubit.currentStep > 0
                      ? cubit.previousStep()
                      : Navigator.pop(context),
                  onNext: () => cubit.nextStep(),
                  isLastStep: cubit.currentStep == cubit.totalSteps - 1,
                  canGoBack: true,
                  canContinue: cubit.currentStep < cubit.totalSteps - 1,
                  onSave: () async {
                    if (cubit.appointmentData != null) {
                      cubit.action = "save";
                      context
                          .read<ExaminationActionsCubit>()
                          .createExamination(data: cubit.examinationData());
                    }
                  },
                  onConfirm: () async {
                    if (cubit.appointmentData != null) {
                      cubit.action = "create";
                      context
                          .read<ExaminationActionsCubit>()
                          .createExamination(data: cubit.examinationData());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A titled group header followed by its checkable options.
class _GroupSection extends StatelessWidget {
  const _GroupSection({super.key, required this.group});

  final ComplainGroupDef group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(
            group.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        for (final option in group.options)
          ComplainOptionCard(
            key: ValueKey('opt_${option.key}'),
            option: option,
          ),
      ],
    );
  }
}
