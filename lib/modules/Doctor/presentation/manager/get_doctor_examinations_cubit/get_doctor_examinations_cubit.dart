import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../Patient/data/model/patient_examination.dart';
import '../../../data/repos/doctor_repo.dart';
import '../../../../../core/Network/shared.dart';

part 'get_doctor_examinations_state.dart';
part 'get_doctor_examinations_event.dart';

class GetDoctorExaminationsBloc
    extends Bloc<GetDoctorExaminationsEvent, GetDoctorExaminationsState> {
  final DoctorRepo doctorRepo;
  String? _currentDoctorId;

  GetDoctorExaminationsBloc(this.doctorRepo)
      : super(const GetDoctorExaminationsState()) {
    on<SetDoctorIdEvent>(_onSetDoctorId);
    on<FetchExaminationsEvent>(_onFetchExaminations);
    on<SetPageEvent>(_onSetPage);
    on<SetFiltersEvent>(_onSetFilters);
    on<ResetFiltersEvent>(_onResetFilters);
  }

  void _onSetDoctorId(
      SetDoctorIdEvent event, Emitter<GetDoctorExaminationsState> emit) {
    _currentDoctorId = event.doctorId;
    add(FetchExaminationsEvent(refresh: true));
  }

  Future<void> _onFetchExaminations(FetchExaminationsEvent event,
      Emitter<GetDoctorExaminationsState> emit) async {
    if (_currentDoctorId == null) {
      // Try getting from cache if not set explicitly
      final user = CacheHelper.getUser('user');
      _currentDoctorId = user?.id;
    }

    if (_currentDoctorId == null) {
      emit(state.copyWith(
        status: GetDoctorExaminationsStatus.error,
        errorMessage: 'Doctor ID not found',
      ));
      return;
    }

    if (event.refresh) {
      emit(
          state.copyWith(page: 1, status: GetDoctorExaminationsStatus.loading));
    } else {
      emit(state.copyWith(status: GetDoctorExaminationsStatus.loading));
    }

    try {
      final result = await doctorRepo.getDoctorExaminations(
        doctorId: _currentDoctorId!,
        page: state.page,
        limit: 10,
        patientId: state.patientIdFilter,
        startDate: state.startDateFilter,
        endDate: state.endDateFilter,
      );

      if (result.success == true) {
        emit(state.copyWith(
          status: GetDoctorExaminationsStatus.success,
          examinations: result,
        ));
      } else {
        emit(state.copyWith(
          status: GetDoctorExaminationsStatus.error,
          errorMessage: 'Failed to fetch data',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GetDoctorExaminationsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSetPage(
      SetPageEvent event, Emitter<GetDoctorExaminationsState> emit) {
    if (state.page != event.page) {
      emit(state.copyWith(page: event.page));
      add(FetchExaminationsEvent());
    }
  }

  void _onSetFilters(
      SetFiltersEvent event, Emitter<GetDoctorExaminationsState> emit) {
    emit(state.copyWith(
      patientIdFilter: event.patientId,
      startDateFilter: event.startDate,
      endDateFilter: event.endDate,
      page: 1,
    ));
    add(FetchExaminationsEvent());
  }

  void _onResetFilters(
      ResetFiltersEvent event, Emitter<GetDoctorExaminationsState> emit) {
    emit(state.copyWith(
      clearPatientFilter: true,
      clearStartDateFilter: true,
      clearEndDateFilter: true,
      page: 1,
    ));
    add(FetchExaminationsEvent());
  }
}
