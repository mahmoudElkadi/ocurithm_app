part of 'get_doctor_examinations_cubit.dart';

enum GetDoctorExaminationsStatus { initial, loading, success, error, empty }

class GetDoctorExaminationsState {
  final GetDoctorExaminationsStatus status;
  final Examinations? examinations;
  final String? errorMessage;

  // Filters and Pagination
  final int page;
  final String? patientIdFilter;
  final String? startDateFilter;
  final String? endDateFilter;
  final bool hasReachedMax;

  const GetDoctorExaminationsState({
    this.status = GetDoctorExaminationsStatus.initial,
    this.examinations,
    this.errorMessage,
    this.page = 1,
    this.patientIdFilter,
    this.startDateFilter,
    this.endDateFilter,
    this.hasReachedMax = false,
  });

  GetDoctorExaminationsState copyWith({
    GetDoctorExaminationsStatus? status,
    Examinations? examinations,
    String? errorMessage,
    int? page,
    String? patientIdFilter,
    String? startDateFilter,
    String? endDateFilter,
    bool? hasReachedMax,
  }) {
    return GetDoctorExaminationsState(
      status: status ?? this.status,
      examinations: examinations ?? this.examinations,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      patientIdFilter: patientIdFilter ?? this.patientIdFilter,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
