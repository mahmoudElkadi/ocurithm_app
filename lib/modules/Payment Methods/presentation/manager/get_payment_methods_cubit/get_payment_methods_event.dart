part of 'get_payment_methods_cubit.dart';

/// Events for GetPaymentMethodsCubit
abstract class GetPaymentMethodsEvent {
  const GetPaymentMethodsEvent();
}

/// Event to get all payment methods (first page)
class GetAllPaymentMethodsEvent extends GetPaymentMethodsEvent {
  final bool noPagination;
  const GetAllPaymentMethodsEvent({this.noPagination = false});
}

/// Event to load more payment methods (next page)
class LoadMorePaymentMethodsEvent extends GetPaymentMethodsEvent {
  const LoadMorePaymentMethodsEvent();
}

/// Event to set search query (doesn't trigger search immediately)
class SetSearchEvent extends GetPaymentMethodsEvent {
  final String query;

  const SetSearchEvent(this.query);
}

/// Event to search payment methods (triggered after debounce)
class SearchPaymentMethodsEvent extends GetPaymentMethodsEvent {
  final String query;

  const SearchPaymentMethodsEvent(this.query);
}

class SetClinicFilterEvent extends GetPaymentMethodsEvent {
  final String? clinicId;

  const SetClinicFilterEvent(this.clinicId);
}
