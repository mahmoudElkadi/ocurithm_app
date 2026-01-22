import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/generated/l10n.dart';

import '../../../../../Main/presentation/views/main_view.dart';
import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../manger/login_cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Get.offAll(() => const MainView());
        } else if (state.isError) {
          _showPopup(context, "Login Failed",
              state.errorMessage ?? "An error occurred");
        }
      },
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      if (Theme.of(context).brightness == Brightness.light)
                        BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 1))
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TextField2(
                        controller: email,
                        radius: 20,
                        type: TextInputType.emailAddress,
                        suffixIcon: Icon(Icons.person_outline_outlined,
                            color: Colorz.primaryColor),
                        fillColor: Theme.of(context).cardColor,
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
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      if (Theme.of(context).brightness == Brightness.light)
                        BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 1.5,
                            blurRadius: 1,
                            offset: const Offset(0, 1))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TextField2(
                      controller: password,
                      radius: 20,
                      borderColor: Colorz.primaryColor,
                      required: true,
                      type: TextInputType.visiblePassword,
                      isPassword: state.obscureText,
                      onSubmit: (value) {
                        if (formKey.currentState!.validate()) {
                          context.read<LoginCubit>().add(LoginUserEvent(
                                username: email.text,
                                password: password.text,
                              ));
                        }
                      },
                      suffixIcon: GestureDetector(
                        onTap: () {
                          context
                              .read<LoginCubit>()
                              .add(ToggleObscureTextEvent());
                        },
                        child: LoginCubit.get(context).state.obscureText ==
                                false
                            ? Icon(Icons.visibility, color: Colorz.primaryColor)
                            : Icon(Icons.visibility_off,
                                color: Colorz.primaryColor),
                      ),
                      fillColor: Theme.of(context).cardColor,
                      hintText: S.of(context).password,
                    ),
                  ),
                ),
                const HeightSpacer(size: 20),
                MyElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<LoginCubit>().add(LoginUserEvent(
                              username: email.text,
                              password: password.text,
                            ));
                      }
                    },
                    boxShadow: [
                      BoxShadow(
                        color: HexColor("#3E86DD").withValues(alpha:0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius:
                        state.isLoading ? null : BorderRadius.circular(30),
                    shape:
                        state.isLoading ? BoxShape.circle : BoxShape.rectangle,
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        HexColor("#272d7a"),
                        HexColor("#3c44ab"),
                        Colorz.primaryColor,
                      ],
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                S.of(context).signin,
                                style: appStyle(
                                    context, 18, Colorz.white, FontWeight.w600),
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
          ),
        );
      },
    );
  }

  void _showPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colorz.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colorz.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
