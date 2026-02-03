part of 'get_medicines_cubit.dart';

enum GetMedicinesStatus { initial, loading, success, error, noConnection }

class GetMedicinesState {
  final GetMedicinesStatus status;
  final List<CommercialName> medicines;
  final int page;
  final String search;
  final String? errorMessage;
  final bool hasMore;
  final int totalPages;

  const GetMedicinesState({
    this.status = GetMedicinesStatus.initial,
    this.medicines = const [],
    this.page = 1,
    this.search = '',
    this.errorMessage,
    this.hasMore = false,
    this.totalPages = 1,
  });

  GetMedicinesState copyWith({
    GetMedicinesStatus? status,
    List<CommercialName>? medicines,
    int? page,
    String? search,
    String? errorMessage,
    bool? hasMore,
    int? totalPages,
  }) {
    return GetMedicinesState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      page: page ?? this.page,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
