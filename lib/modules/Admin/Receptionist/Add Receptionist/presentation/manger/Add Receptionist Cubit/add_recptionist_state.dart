class CreateReceptionistState {}

class CreateReceptionistInitial extends CreateReceptionistState {}

class ChangeIndexState extends CreateReceptionistState {}

class ValidateForm extends CreateReceptionistState {}

class ObscureText extends CreateReceptionistState {}

class CreateReceptionistLoading extends CreateReceptionistState {}

class CreateReceptionistSuccess extends CreateReceptionistState {}

class CreateReceptionistFailed extends CreateReceptionistState {}

class GetBranchLoading extends CreateReceptionistState {}

class GetBranchSuccess extends CreateReceptionistState {}

class GetBranchFailure extends CreateReceptionistState {}

class ChooseBranch extends CreateReceptionistState {}
