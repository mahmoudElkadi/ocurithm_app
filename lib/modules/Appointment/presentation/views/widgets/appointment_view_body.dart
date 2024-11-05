import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
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
            const HeightSpacer(size: 10),
            const ExpandableTimeSlots(
              title: "Morning",
              image: "assets/icons/morning.svg",
            ),
            const HeightSpacer(size: 10),
            const ExpandableTimeSlots(
              title: "Afternoon",
              image: "assets/icons/afternoon.svg",
            ),
            const HeightSpacer(size: 10),
            const ExpandableTimeSlots(
              title: "Evening",
              image: "assets/icons/evening.svg",
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableTimeSlots extends StatefulWidget {
  const ExpandableTimeSlots({super.key, this.title, this.image});
  final String? title;
  final String? image;

  @override
  State<ExpandableTimeSlots> createState() => _ExpandableTimeSlotsState();
}

class _ExpandableTimeSlotsState extends State<ExpandableTimeSlots> {
  int? expandedIndex;
  bool isExpanded = false;

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  List<Color> getThemeColors(String theme) {
    switch (theme.toLowerCase()) {
      case 'afternoon':
        return [
          HexColor("#C2FDF2"),
          HexColor("#CAF0F5"),
          HexColor("#DAD6FC"),
          HexColor("#DED0FE"),
        ];
      case 'morning':
        return [HexColor("#FDF598"), HexColor("#FCE7A9"), HexColor("#FBD5BF"), HexColor("#FAC0D8"), Colors.pink.shade300];

      case 'evening':
        return [
          HexColor("#F8F8F8"),
          HexColor("#F0F0F0"),
          HexColor("#E8E8E8"),
        ];

      default:
        return [
          HexColor("#C2FDF2"),
          HexColor("#CAF0F5"),
          HexColor("#DAD6FC"),
          HexColor("#DED0FE"),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: toggleExpansion,
          child: Stack(
            children: [
              // Main Container
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
                      children: isExpanded ? _buildTimeSlots() : [], // Only show slots when expanded
                    ),
                  ),
                ),
              ),

              // Afternoon Label
              AnimatedPositioned(
                left: Directionality.of(context) == ui.TextDirection.ltr ? 20 : null,
                right: Directionality.of(context) == ui.TextDirection.rtl ? 20 : null,
                top: isExpanded ? 0 : 29,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  padding: EdgeInsets.fromLTRB(isExpanded ? 10 : 0, 5, isExpanded ? 20 : 0, 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: isExpanded
                            ? getThemeColors(widget.title ?? "Afternoon")
                            : [
                                Colorz.white,
                                Colorz.white,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        widget.image ?? "assets/icons/afternoon.svg",
                        width: 25,
                        height: 25,
                      ),
                      const WidthSpacer(size: 5),
                      Text(
                        widget.title ?? "Afternoon",
                        style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              // Number Circle
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: Directionality.of(context) == ui.TextDirection.rtl ? 20 : null,
                right: Directionality.of(context) == ui.TextDirection.ltr ? 20 : null,
                top: isExpanded ? 0 : 28,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: isExpanded ? Colors.transparent : Colors.black, width: 0.3),
                      gradient: isExpanded
                          ? LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                              colors: [
                                HexColor("#C2FDF2"),
                                HexColor("#CAF0F5"),
                                HexColor("#DAD6FC"),
                                HexColor("#DED0FE"),
                              ],
                            )
                          : null,
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

class GradientColors {
  static List<Color> getGradientByType(String type) {
    switch (type.toLowerCase()) {
      case 'afternoon':
        return [
          HexColor("#C2FDF2"),
          HexColor("#CAF0F5"),
          HexColor("#DAD6FC"),
          HexColor("#DED0FE"),
        ];

      case 'morning':
        return [
          HexColor("#FFE4B5"), // Light golden
          HexColor("#FFA07A"), // Light salmon
          HexColor("#FF8C69"), // Salmon
          HexColor("#FF7F50"), // Coral
        ];

      case 'evening':
        return [
          HexColor("#4B0082"), // Indigo
          HexColor("#483D8B"), // Dark slate blue
          HexColor("#6A5ACD"), // Slate blue
          HexColor("#7B68EE"), // Medium slate blue
        ];

      case 'night':
        return [
          HexColor("#191970"), // Midnight blue
          HexColor("#000080"), // Navy
          HexColor("#00008B"), // Dark blue
          HexColor("#0000CD"), // Medium blue
        ];

      case 'available':
        return [
          HexColor("#98FB98"), // Pale green
          HexColor("#90EE90"), // Light green
          HexColor("#7FFF00"), // Chartreuse
          HexColor("#32CD32"), // Lime green
        ];

      case 'booked':
        return [
          HexColor("#FFB6C1"), // Light pink
          HexColor("#FF69B4"), // Hot pink
          HexColor("#FF1493"), // Deep pink
          HexColor("#DB7093"), // Pale violet red
        ];

      case 'selected':
        return [
          HexColor("#E6E6FA"), // Lavender
          HexColor("#D8BFD8"), // Thistle
          HexColor("#DDA0DD"), // Plum
          HexColor("#DA70D6"), // Orchid
        ];

      default:
        return [
          HexColor("#C2FDF2"),
          HexColor("#CAF0F5"),
          HexColor("#DAD6FC"),
          HexColor("#DED0FE"),
        ];
    }
  }

  // Helper method for getting gradient with different directions
  static LinearGradient getGradient({
    required String type,
    AlignmentGeometry begin = Alignment.centerRight,
    AlignmentGeometry end = Alignment.centerLeft,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: getGradientByType(type),
    );
  }
}
