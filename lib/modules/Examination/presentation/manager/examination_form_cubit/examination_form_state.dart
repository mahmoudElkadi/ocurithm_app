part of 'examination_form_cubit.dart';

abstract class ExaminationFormState {
  const ExaminationFormState();
}

class ExaminationFormInitial extends ExaminationFormState {}

class ExaminationFormStepChanged extends ExaminationFormState {}

class ExaminationFormUpdated extends ExaminationFormState {}

class ExaminationFormJsonLoaded extends ExaminationFormState {}
