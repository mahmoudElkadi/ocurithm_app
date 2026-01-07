part of 'get_one_examination_cubit.dart';

@immutable
abstract class GetOneExaminationEvent {}

class GetOneExaminationByIdEvent extends GetOneExaminationEvent {
  final String id;
  GetOneExaminationByIdEvent(this.id);
}
