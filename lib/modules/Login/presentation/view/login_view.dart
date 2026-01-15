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
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          body: const LoginViewBody(),
          // bottomNavigationBar: Platform.isIOS
          //     ? const SizedBox()
          //     : BottomAppBar(
          //         padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          //         height: 70,
          //         elevation: 0,
          //         color: Colors.white,
          //         child: Align(
          //           alignment: Alignment.centerRight,
          //           child: SvgPicture.asset(
          //             "assets/icons/circle.svg",
          //             height: 70,
          //           ),
          //         ),
          //       ),
        ),
      ),
    );
  }
}
