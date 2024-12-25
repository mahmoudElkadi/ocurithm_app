abstract class ExaminationState {}

class ExaminationInitial extends ExaminationState {}

class ExaminationStepChanged extends ExaminationState {}
class ReadJson extends ExaminationState {}
class ChooseData extends ExaminationState {}
