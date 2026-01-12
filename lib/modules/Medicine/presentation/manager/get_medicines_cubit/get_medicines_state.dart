part of 'get_medicines_cubit.dart';

abstract class GetMedicinesState {}

class GetMedicinesInitial extends GetMedicinesState {}

class GetMedicinesLoading extends GetMedicinesState {}

class GetMedicinesLoaded extends GetMedicinesState {
  final List<Medicine> medicines;
  final bool hasMore;
  GetMedicinesLoaded({required this.medicines, required this.hasMore});
}

class GetMedicinesError extends GetMedicinesState {
  final String error;
  GetMedicinesError({required this.error});
}

class GetMedicinesLoadingMore extends GetMedicinesState {
  final List<Medicine> medicines;
  GetMedicinesLoadingMore({required this.medicines});
}
