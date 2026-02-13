part of 'make_appointment_cubit.dart';

@immutable
abstract class MakeAppointmentEvent {}

class GetClinicsEvent extends MakeAppointmentEvent {}

class GetDoctorsEvent extends MakeAppointmentEvent {
  final String? branch;

  GetDoctorsEvent({this.branch});
}

class GetBranchesEvent extends MakeAppointmentEvent {}

class GetPatientsEvent extends MakeAppointmentEvent {
  final String? search;

  GetPatientsEvent({this.search});
}

class GetPaymentMethodsEvent extends MakeAppointmentEvent {
  final String? clinic;

  GetPaymentMethodsEvent({this.clinic});
}

class GetExaminationTypesEvent extends MakeAppointmentEvent {
  final String? clinic;

  GetExaminationTypesEvent({this.clinic});
}

// class GetAppointmentsEvent extends MakeAppointmentEvent {
//   final DateTime? date;
//   final String? branch;
//   final String? doctor;
//   GetAppointmentsEvent({this.date, this.branch, this.doctor});
// }

class CreateAppointmentEvent extends MakeAppointmentEvent {
  final String note;

  CreateAppointmentEvent({required this.note});
}

class EditAppointmentEvent extends MakeAppointmentEvent {
  final MakeAppointmentModel model;

  EditAppointmentEvent({required this.model});
}

class SetDataEvent extends MakeAppointmentEvent {
  final Appointment appointment;

  SetDataEvent(this.appointment);
}

class SetPatientEvent extends MakeAppointmentEvent {
  final Patient? patient;

  SetPatientEvent(this.patient);
}

class SearchPatientsEvent extends MakeAppointmentEvent {
  final String search;

  SearchPatientsEvent(this.search);
}

class ChangeStepEvent extends MakeAppointmentEvent {
  final int step;

  ChangeStepEvent(this.step);
}

class PreviousStepEvent extends MakeAppointmentEvent {}

class ChangePageEvent extends MakeAppointmentEvent {
  final int index;
  final BuildContext context;

  ChangePageEvent({required this.index, required this.context});
}

class SetWidgetIndexEvent extends MakeAppointmentEvent {
  final int index;

  SetWidgetIndexEvent(this.index);
}

class ValidateFieldEvent extends MakeAppointmentEvent {
  final String field;
  final bool isValid;

  ValidateFieldEvent(this.field, this.isValid);
}

class SelectDoctorEvent extends MakeAppointmentEvent {
  final Doctor? doctor;

  SelectDoctorEvent(this.doctor);
}

class SelectClinicEvent extends MakeAppointmentEvent {
  final Clinic? clinic;

  SelectClinicEvent(this.clinic);
}

class SelectBranchEvent extends MakeAppointmentEvent {
  final Branch? branch;

  SelectBranchEvent(this.branch);
}

class SelectTimeEvent extends MakeAppointmentEvent {
  final DateTime? time;

  SelectTimeEvent(this.time);
}

class SelectPaymentMethodEvent extends MakeAppointmentEvent {
  final PaymentMethod? paymentMethod;

  SelectPaymentMethodEvent(this.paymentMethod);
}

class SelectExaminationTypeEvent extends MakeAppointmentEvent {
  final ExaminationType? examinationType;

  SelectExaminationTypeEvent(this.examinationType);
}

class InitialDataEvent extends MakeAppointmentEvent {}
