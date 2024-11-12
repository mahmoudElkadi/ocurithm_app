import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/widgets/appointment_form.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/widgets/make_appointment_view_body.dart';

import '../../../../core/utils/app_style.dart';
import '../../../../core/utils/colors.dart';
import '../../../Appointment/data/models/appointment_model.dart';
import '../../data/repos/make_appointment_repo_impl.dart';
import '../manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../manager/Make Appointment cubit/make_appointment_state.dart';

class MakeAppointmentView extends StatefulWidget {
  const MakeAppointmentView({super.key, this.appointment});
  final Appointment? appointment;

  @override
  State<MakeAppointmentView> createState() => _MakeAppointmentViewState();
}

class _MakeAppointmentViewState extends State<MakeAppointmentView> with SingleTickerProviderStateMixin {
  bool appointment = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      appointment = !appointment;
      if (appointment) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MakeAppointmentCubit(MakeAppointmentRepoImpl())
        ..getDoctors()
        ..getBranches(),
      child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colorz.white,
            elevation: 0,
            title: Text("Appointments", style: appStyle(context, 20, Colorz.black, FontWeight.w600)),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: Colorz.black),
            ),
            actions: [
              IconButton(
                onPressed: _toggleView,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.view_list,
                  progress: _animation,
                  color: Colorz.black,
                ),
              ),
            ],
          ),
          body: MakeAppointmentCubit.get(context).connection != false
              ? Stack(
                  children: [
                    // Form View
                    AnimatedOpacity(
                      opacity: appointment ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: appointment,
                        child: AnimatedSlide(
                          offset: Offset(appointment ? -1.0 : 0.0, 0.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: FormDataAppointment(),
                        ),
                      ),
                    ),

                    // Calendar View
                    AnimatedOpacity(
                      opacity: appointment ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !appointment,
                        child: AnimatedSlide(
                          offset: Offset(appointment ? 0.0 : 1.0, 0.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: MakeAppointmentViewBody(
                            branch: '',
                            appointment: widget.appointment,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : NoInternet(
                  onPressed: () {
                    final cubit = MakeAppointmentCubit.get(context);
                    if (cubit.doctors == null) {
                      cubit.getDoctors();
                      cubit.getBranches();
                    }
                  },
                ),
        ),
      ),
    );
  }
}

// Optional: Custom page route transition
class SlidePageRoute extends PageRouteBuilder {
  final Widget child;
  final AxisDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = AxisDirection.right,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: _getBeginOffset(),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  Offset _getBeginOffset() {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.right:
        return const Offset(-1, 0);
      case AxisDirection.left:
        return const Offset(1, 0);
    }
  }
}
