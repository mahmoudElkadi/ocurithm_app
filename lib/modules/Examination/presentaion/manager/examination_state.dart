abstract class ExaminationState {}

class ExaminationInitial extends ExaminationState {}

class ExaminationStepChanged extends ExaminationState {}

class ReadJson extends ExaminationState {}

class ChooseData extends ExaminationState {}

class CircleDateChanged extends ExaminationState {}

class MakeExaminationLoading extends ExaminationState {}

class MakeExaminationSuccess extends ExaminationState {}

class MakeExaminationError extends ExaminationState {}
