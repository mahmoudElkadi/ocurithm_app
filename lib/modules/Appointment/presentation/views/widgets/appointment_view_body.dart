import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/Appointment cubit/appointment_cubit.dart';
import '../../manager/Appointment cubit/appointment_state.dart';

class AppointmentViewBody extends StatefulWidget {
  const AppointmentViewBody({super.key});

  @override
  State<AppointmentViewBody> createState() => _AppointmentViewBodyState();
}

class _AppointmentViewBodyState extends State<AppointmentViewBody> {
  var selectedDoctor;
  var selectedBranch;

  @override
  Widget build(BuildContext context) {
    final cubit = AppointmentCubit.get(context);
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) => SingleChildScrollView(
        child: Column(
          children: [
            const HeightSpacer(size: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownItem(
                      radius: 30,
                      color: Colorz.white,
                      isShadow: true,
                      iconData: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colorz.grey,
                        size: 20,
                      ),
                      height: 4,
                      items: cubit.branches?.branches,
                      selectedValue: selectedBranch,
                      hintText: 'Select Branch',
                      hintStyle: appStyle(context, 18, Colorz.grey, FontWeight.w600),
                      textStyle: appStyle(context, 17, Colorz.black, FontWeight.w600),
                      itemAsString: (item) => item.name.toString(),
                      onItemSelected: (item) {
                        setState(() {
                          if (item != "Not Found") {
                            // widget.cubit.chooseBranch = true;
                            selectedBranch = item.name;
                            // widget.cubit.branchId = item.id;
                            log(selectedBranch.toString());
                          }
                        });
                      },
                      isLoading: cubit.branches == null,
                    ),
                  ),
                  const WidthSpacer(size: 10),
                  Expanded(
                    child: DropdownItem(
                      radius: 30,
                      color: Colorz.white,
                      isShadow: true,
                      iconData: Icon(Icons.arrow_drop_down_circle, size: 20, color: Colorz.grey),
                      height: 6,
                      items: cubit.doctors?.doctors,
                      selectedValue: selectedDoctor,
                      hintText: 'Select Doctor',
                      hintStyle: appStyle(context, 18, Colorz.grey, FontWeight.w600),
                      textStyle: appStyle(context, 17, Colorz.black, FontWeight.w600),
                      itemAsString: (item) => item.name.toString(),
                      onItemSelected: (item) {
                        setState(() {
                          if (item != "Not Found") {
                            // widget.cubit.chooseBranch = true;
                            selectedDoctor = item.name;
                            log(selectedDoctor.toString());
                          }
                        });
                      },
                      isLoading: cubit.doctors == null,
                    ),
                  ),
                ],
              ),
            ),
            const HeightSpacer(size: 20),
            ExpandableTimeSlots(),
            const HeightSpacer(size: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(top: 17),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colorz.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colorz.grey, width: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: 13,
                        itemBuilder: (context, index) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat("hh:mm a").format(
                                        DateTime.now().add(Duration(minutes: 30 * index)),
                                      ),
                                      style: appStyle(context, 18, Colorz.blue, FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "(Ibrahim Mostafa)",
                                          style: appStyle(context, 12, Colorz.black, FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index % 3 != 2 && index != 12)
                                Positioned(
                                  right: -2,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      width: 2.7,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Colorz.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const HeightSpacer(size: 20),
          ],
        ),
      ),
    );
  }
}

class ExpandableTimeSlots extends StatefulWidget {
  const ExpandableTimeSlots({super.key});

  @override
  State<ExpandableTimeSlots> createState() => _ExpandableTimeSlotsState();
}

class _ExpandableTimeSlotsState extends State<ExpandableTimeSlots> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 17),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colorz.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colorz.grey, width: 0.3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildTimeSlots(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: Directionality.of(context) == ui.TextDirection.ltr ? 20 : null,
              right: Directionality.of(context) == ui.TextDirection.rtl ? 20 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        HexColor("#C2FDF2"),
                        HexColor("#CAF0F5"),
                        HexColor("#DAD6FC"),
                        HexColor("#DED0FE"),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  S.of(context).afternoon,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Positioned(
              right: Directionality.of(context) == ui.TextDirection.ltr ? 20 : null,
              left: Directionality.of(context) == ui.TextDirection.rtl ? 20 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        HexColor("#C2FDF2"),
                        HexColor("#CAF0F5"),
                        HexColor("#DAD6FC"),
                        HexColor("#DED0FE"),
                      ],
                    ),
                    shape: BoxShape.circle),
                child: Text(
                  4.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeSlots() {
    List<Widget> slots = [];
    int totalItems = 13;
    int i = 0;

    while (i < totalItems) {
      // Check if current index is the expanded one
      if (i == expandedIndex || (i + 1 == expandedIndex && i + 1 < totalItems)) {
        // Add the expanded item
        slots.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: _buildExpandedItem(expandedIndex!),
          ),
        );

        // Handle remaining items after expanded item
        if (i == expandedIndex) {
          // If there are more items after the expanded one
          if (i + 1 < totalItems) {
            slots.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _buildRegularItem(i + 1)),
                    const SizedBox(width: 8),
                    // Only add third item if it exists
                    if (i + 2 < totalItems) Expanded(child: _buildRegularItem(i + 2)) else const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
            // Skip the next two positions as we've handled them
            i += 3;
          } else {
            // If expanded item is the last one, just increment i
            i++;
          }
        } else if (i + 1 == expandedIndex) {
          // If second item in pair is expanded
          if (i + 2 < totalItems) {
            slots.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _buildRegularItem(i)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildRegularItem(i + 2)),
                  ],
                ),
              ),
            );
            i += 3;
          } else {
            slots.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _buildRegularItem(i)),
                    const SizedBox(width: 8),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
            i += 2;
          }
        }
      } else {
        // Add regular pair of items
        // Check if we have enough items for a pair
        if (i + 1 < totalItems) {
          slots.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: _buildRegularItem(i)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildRegularItem(i + 1)),
                ],
              ),
            ),
          );
          i += 2;
        } else {
          // Handle last single item
          slots.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: _buildRegularItem(i)),
                  const SizedBox(width: 8),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          );
          i++;
        }
      }
    }
    return slots;
  }

  Widget _buildExpandedItem(int index) {
    // Add null check for safety
    if (index >= 13) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colorz.grey, width: 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat("hh:mm a").format(
                        DateTime.now().add(Duration(minutes: 30 * index)),
                      ),
                      style: appStyle(context, 18, Colorz.redColor, FontWeight.w500),
                    ),
                    Text(
                      "(Ibrahim Mostafa)",
                      style: appStyle(context, 16, Colorz.black, FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      expandedIndex = null;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 8),
                Text(
                  "+1234567890",
                  style: appStyle(context, 14, Colorz.black, FontWeight.normal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.medical_services, size: 16),
                const SizedBox(width: 8),
                Text(
                  "General Checkup",
                  style: appStyle(context, 14, Colorz.black, FontWeight.normal),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.schedule),
                  label: const Text("Reschedule"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.redColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularItem(int index) {
    // Add null check for safety
    if (index >= 13) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colorz.grey200.withOpacity(0.7),
              spreadRadius: 2,
              blurRadius: 5,
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat("hh:mm a").format(
                  DateTime.now().add(Duration(minutes: 30 * index)),
                ),
                style: appStyle(context, 18, Colorz.redColor, FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "(Ibrahim Mostafa)",
                    style: appStyle(context, 16, Colorz.black, FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class AppointmentViewBody extends StatefulWidget {
//   const AppointmentViewBody({super.key, this.patient, required this.branch});
//   final Patient? patient;
//   final String branch;
//
//   @override
//   State<AppointmentViewBody> createState() => _AppointmentViewBodyState();
// }
//
// class _AppointmentViewBodyState extends State<AppointmentViewBody> {
//   final now = DateTime.now();
//   late BookingService bookingService;
//   late StreamController<dynamic> _controller;
//   Timer? _pollingTimer;
//   bool _disposed = false;
//
//   bool _viewOnly = false;
//
//   @override
//   void initState() {
//     super.initState();
//     bookingService = BookingService(
//       serviceName: 'Appointment Reservation',
//       serviceDuration: 10,
//       bookingEnd: DateTime(now.year, now.month, now.day, 18, 0),
//       bookingStart: DateTime(now.year, now.month, now.day, 8, 0),
//     );
//
//     _controller = StreamController<dynamic>.broadcast();
//
//     // Call fetchInitialData when the screen is opened
//     fetchInitialData(branch: widget.branch, date: DateTime.now().toString());
//   }
//
//   List<dynamic> appointments = [];
//   bool isFirst = true;
//   Future<void> fetchInitialData({required String date, required String branch}) async {
//     if (_disposed) return;
//
//     Map<String, dynamic> data = {
//       "date": date,
//       "branch": widget.branch,
//       "patient": widget.patient?.id,
//     };
//     log("data ${data.toString()}");
//
//     var dio = Dio(BaseOptions(
//       connectTimeout: const Duration(minutes: 2),
//       receiveTimeout: const Duration(minutes: 2),
//     ));
//
//     try {
//       var response = await dio.get(
//         "${Config.baseUrl}appointments",
//         data: data,
//         options: Options(
//           headers: {"Accept": "application/json", "Content-Type": "application/json", "Cookie": "ocurithmToken=${CacheHelper.getData(key: 'token')}"},
//           validateStatus: (status) {
//             return status! <= 500;
//           },
//         ),
//       );
//       log(response.realUri.toString());
//       if (isFirst) {
//         isFirst = false;
//         fetchInitialData(date: date, branch: widget.branch);
//       }
//       if (_disposed) return;
//       log(response.data.toString());
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = response.data;
//
//         // Remove appointments that are no longer present
//
//         // Add new appointments
//         appointments = response.data['appointments'];
//
//         _controller.add(appointments);
//       } else {
//         throw Exception('Failed to load appointments');
//       }
//     } catch (e) {
//       if (_disposed) return;
//
//       log('Error fetching data: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _disposed = true;
//     _controller.close();
//     _pollingTimer?.cancel();
//     super.dispose();
//   }
//
//   Stream<dynamic>? getBookingStream({
//     required String branch,
//     required DateTime start,
//     required DateTime end,
//   }) {
//     // Start polling
//     _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       fetchInitialData(branch: widget.branch, date: start.toIso8601String());
//     });
//
//     return _controller.stream;
//   }
//
//   Future<dynamic> uploadBooking({
//     required String branch,
//     required String examinationType,
//     required BookingService newBooking,
//     required Patient patient,
//   }) async {
//     var dio = Dio();
//
//     try {
//       Map<String, dynamic> data = {
//         "branch_id": widget.branch,
//         "examination_type": examinationType,
//         "start": newBooking.bookingStart.toIso8601String(),
//         "end": newBooking.bookingEnd.toIso8601String(),
//         "patient_id": patient.id,
//         "branch_name": patient.branch?.name,
//         "full_name": patient.name,
//         "phone": patient.phone,
//       };
//       log('Uploading booking data: $data');
//
//       var response = await dio.post(
//         "${Config.baseUrl}appointment",
//         data: data,
//         options: Options(
//           validateStatus: (status) {
//             return status! < 500;
//           },
//         ),
//       );
//       log('Response: ${response.data.toString()}');
//
//       if (response.statusCode == 200) {
//         return 'Booking uploaded successfully';
//       } else if (response.data.toString().contains("Conflicting appointments found")) {
//         isFirst = true;
//         fetchInitialData(date: DateTime.now().toString(), branch: widget.branch);
//         return 'Error uploading booking';
//       } else {
//         return 'Server Error';
//       }
//     } catch (e) {
//       log('Error uploading booking: $e');
//     }
//   }
//
//   List<Map<String, dynamic>> dateTimeRanges = [];
//
//   List<Map<String, dynamic>> convertStreamResultToDateTimeRanges({
//     required dynamic streamResult,
//   }) {
//     List<Map<String, dynamic>> dateTimeRanges = [];
//
//     if (streamResult is List<dynamic>) {
//       for (var item in streamResult) {
//         dateTimeRanges.add({
//           "Time": DateTimeRange(
//             start: DateTime.parse(item["start"]),
//             end: DateTime.parse(item["end"]),
//           ),
//           "phoneNumber": item["phone"],
//           "name": item["full_name"],
//           "manualId": item["manual_id"],
//           "examination_type": item["examination_type"],
//           "branch": item["branch_name"],
//         });
//       }
//     } else {
//       // Handle the case where streamResult is not a List
//       log('Invalid streamResult format');
//     }
//
//     return dateTimeRanges;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         HeightSpacer(size: 10.h),
//         Expanded(
//           child: BookingCalendar(
//             bookingService: bookingService,
//             convertStreamResultToDateTimeRanges: convertStreamResultToDateTimeRanges,
//             getBookingStream: getBookingStream,
//             uploadBooking: uploadBooking,
//             hideBreakTime: false,
//             loadingWidget: const Text('Fetching data...'),
//             uploadingWidget: const CircularProgressIndicator(),
//             locale: 'en',
//             startingDayOfWeek: StartingDayOfWeek.saturday,
//             wholeDayIsBookedWidget: const Text('Sorry, for this day everything is booked'),
//             branch: "1",
//             viewOnly: _viewOnly,
//             patient: Patient(),
//             availableSlotTextStyle: const TextStyle(
//               fontSize: 13,
//             ),
//             bookedSlotTextStyle: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 13,
//             ),
//             selectedSlotTextStyle: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 13,
//             ),
//             availableSlotColor: Colorz.blue,
//           ),
//         ),
//       ],
//     );
//   }
// }
