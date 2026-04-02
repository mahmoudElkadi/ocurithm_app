part of 'get_medicines_cubit.dart';

abstract class GetMedicinesEvent {}

class FetchMedicinesEvent extends GetMedicinesEvent {
  final bool isRefresh;
  FetchMedicinesEvent({this.isRefresh = false});
}

class SetSearchEvent extends GetMedicinesEvent {
  final String search;
  SetSearchEvent(this.search);
}

class SetPageEvent extends GetMedicinesEvent {
  final int page;
  SetPageEvent(this.page);
}

class SetParentIdEvent extends GetMedicinesEvent {
  final String? parentId;
  SetParentIdEvent(this.parentId);
}

class ResetMedicineFiltersEvent extends GetMedicinesEvent {}
