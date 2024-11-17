import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/generated/l10n.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../../data/repos/login_repo_impl.dart';
import '../../manger/login cubit/login_cubit.dart';
import '../../manger/login cubit/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool obSecure = true;
    void toggle() {
      setState(() {
        obSecure = !obSecure;
      });
    }

    return BlocProvider(
      create: (context) => LoginCubit(LoginRepoImpl()),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) => Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colorz.white,
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: TextField2(
                          controller: email,
                          radius: 20,
                          type: TextInputType.emailAddress,
                          suffixIcon: Icon(Icons.person_outline_outlined, color: Colorz.primaryColor),
                          fillColor: Colors.white,
                          borderColor: Colorz.primaryColor,
                          hintText: S.of(context).username,
                          required: true,
                        )),
                  ),
                  const HeightSpacer(size: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colorz.white,
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 1.5, blurRadius: 1, offset: const Offset(0, 1))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TextField2(
                        controller: password,
                        radius: 20,
                        borderColor: Colorz.primaryColor,
                        required: true,
                        type: TextInputType.visiblePassword,
                        isPassword: LoginCubit.get(context).obscureText,
                        onSubmit: (value) {
                          if (formKey.currentState!.validate()) {
                            LoginCubit.get(context).userLogin(username: email.text, password: password.text);
                          }
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            LoginCubit.get(context).obscureText = !LoginCubit.get(context).obscureText;
                          },
                          child: LoginCubit.get(context).obscureText == false
                              ? Icon(Icons.visibility, color: Colorz.primaryColor)
                              : Icon(Icons.visibility_off, color: Colorz.primaryColor),
                        ),
                        fillColor: Colors.white,
                        hintText: S.of(context).password,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        S.of(context).forgetPassword,
                        style: appStyle(context, 16, Colorz.grey, FontWeight.w500),
                      ),
                    ),
                  ),
                  const HeightSpacer(size: 20),
                  MyElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          LoginCubit.get(context).userLogin(username: email.text, password: password.text);
                        }
                      },
                      boxShadow: [
                        BoxShadow(
                          color: HexColor("#3E86DD").withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          HexColor("#0E3366"),
                          HexColor("#174784"),
                          HexColor("#2762AA"),
                          HexColor("#3171BF"),
                          HexColor("#3E86DD"),
                          HexColor("#4A97F6"),
                        ],
                      ),
                      child: LoginCubit.get(context).isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  S.of(context).signin,
                                  style: appStyle(context, 18, Colorz.white, FontWeight.w600),
                                ),
                                const WidthSpacer(size: 10),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colorz.white,
                                  size: 15,
                                ),
                              ],
                            )),
                  const HeightSpacer(size: 20)
                ],
              ),
            )),
      ),
    );
  }
}
