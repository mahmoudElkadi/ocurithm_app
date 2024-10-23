import 'package:flutter_bloc/flutter_bloc.dart';

import 'branch_state.dart';

class AdminBranchCubit extends Cubit<AdminBranchState> {
  AdminBranchCubit() : super(AdminBranchInitial());

  static AdminBranchCubit get(context) => BlocProvider.of(context);
  var branch;
}
