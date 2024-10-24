class CreateDoctorState {}

class CreateDoctorInitial extends CreateDoctorState {}

class ChangeIndexState extends CreateDoctorState {}

class ValidateForm extends CreateDoctorState {}

class ObscureText extends CreateDoctorState {}

class CreateDoctorLoading extends CreateDoctorState {}

class CreateDoctorSuccess extends CreateDoctorState {}

class CreateDoctorFailed extends CreateDoctorState {}

class GetBranchLoading extends CreateDoctorState {}

class GetBranchSuccess extends CreateDoctorState {}

class GetBranchFailure extends CreateDoctorState {}

class ChooseBranch extends CreateDoctorState {}
