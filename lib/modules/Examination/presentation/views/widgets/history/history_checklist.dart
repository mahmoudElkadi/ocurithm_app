import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/catalog/history_catalog.dart';
import '../../../manager/examination_actions_cubit/examination_actions_cubit.dart';
import '../../../manager/examination_form_cubit/examination_form_cubit.dart';
import '../navigation_view.dart';
import 'category_card.dart';
import 'other_notes_section.dart';

/// Structured History step body (step 1). Renders the legacy "Other notes"
/// section, the config-driven category checklist, and the step navigation.
/// Fully decoupled from catalog content — growing the catalog needs no change here.
class HistoryChecklist extends StatelessWidget {
  const HistoryChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationFormCubit>();

    return BlocBuilder<ExaminationFormCubit, ExaminationFormState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
              .copyWith(bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Medical History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tick the conditions that apply and fill in the details.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                const OtherNotesSection(),
                for (final category in historyCategories)
                  CategoryCard(
                    key: ValueKey('cat_${category.key}'),
                    category: category,
                  ),
                StepNavigation(
                  onPrevious: () => cubit.currentStep > 0
                      ? cubit.previousStep()
                      : Navigator.pop(context),
                  onNext: () => cubit.nextStep(),
                  isLastStep: cubit.currentStep == cubit.totalSteps - 1,
                  canGoBack: true,
                  canContinue: cubit.currentStep < cubit.totalSteps - 1,
                  onSave: () async {
                    cubit.action = "save";
                    context
                        .read<ExaminationActionsCubit>()
                        .createExamination(data: cubit.examinationData());
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
