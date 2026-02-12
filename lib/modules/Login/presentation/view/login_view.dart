import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Login/presentation/view/widgets/login_view_body.dart';

import '../../../../core/utils/services_locator.dart';
import '../manger/login_cubit/login_cubit.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: const Scaffold(
          body: LoginViewBody(),

        ),
      ),
    );
  }
}
