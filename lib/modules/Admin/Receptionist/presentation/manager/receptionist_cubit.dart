import 'package:flutter_bloc/flutter_bloc.dart';

import 'receptionist_state.dart';

class AdminReceptionCubit extends Cubit<AdminReceptionState> {
  AdminReceptionCubit() : super(AdminReceptionInitial());

  static AdminReceptionCubit get(context) => BlocProvider.of(context);
  var receptionist;
}
