import 'package:flutter_bloc/flutter_bloc.dart';

import 'doctor_state.dart';

class AdminDoctorCubit extends Cubit<AdminDoctorState> {
  AdminDoctorCubit() : super(AdminDoctorInitial());

  static AdminDoctorCubit get(context) => BlocProvider.of(context);
  var doctor;
}
