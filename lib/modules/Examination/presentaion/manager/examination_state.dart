abstract class ExaminationState {}

class ExaminationInitial extends ExaminationState {}

class ExaminationStepChanged extends ExaminationState {}

class ReadJson extends ExaminationState {}

class ChooseData extends ExaminationState {}

class CircleDateChanged extends ExaminationState {}

class MakeExaminationLoading extends ExaminationState {}

class MakeExaminationSuccess extends ExaminationState {}

class MakeExaminationError extends ExaminationState {}

class MakeFinalizationLoading extends ExaminationState {}

class MakeFinalizationSuccess extends ExaminationState {}

class MakeFinalizationError extends ExaminationState {}
