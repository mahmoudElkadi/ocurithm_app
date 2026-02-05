import 'package:ocurithm/modules/Make_Appointment/data/models/make_appointment_model.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../../../core/api/api_constants.dart';
import '../../../Appointment/data/models/appointment_model.dart';
import 'make_appointment_repo.dart';

class MakeAppointmentRepoImpl implements MakeAppointmentRepo {
  final ApiHandler _apiHandler = ApiHandler();


  @override
  Future<Appointment> makeAppointment({required MakeAppointmentModel model}) async {
    try {
      final response = await _apiHandler.post<Appointment>(
        ApiConstants.appointments,
        data: model.toJson(),
        cancelKey: 'makeAppointment',
        fromJson: (json) => Appointment.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to create appointment');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Appointment> editAppointment({required MakeAppointmentModel model, required String id}) async {
    try {
      final response = await _apiHandler.put<Appointment>(
        '${ApiConstants.appointments}/${model.id}',
        data: model.toJson(),
        cancelKey: 'editAppointment',
        fromJson: (json) => Appointment.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to update appointment');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppointmentModel> getAllAppointment({DateTime? date, String? branch, String? doctor}) async {
    try {
      Map<String, dynamic> query = {
        if (date != null) "startDate": DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc().toIso8601String(),
        if (date != null) "endDate": DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String(),
        if (doctor != null) "doctor": doctor,
        if (branch != null) "branch": branch
      };

      final response = await _apiHandler.get<AppointmentModel>(
        ApiConstants.appointments,
        queryParameters: query,
        cancelKey: 'getAllAppointment',
        fromJson: (json) => AppointmentModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed fetch appointments');
      }
    } catch (e) {
      rethrow;
    }
  }
}
