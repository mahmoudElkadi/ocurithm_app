import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/colors.dart';

class CalendarSliderWidget extends StatefulWidget {
  final int month;
  final int year;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  CalendarSliderWidget({
    required this.month,
    required this.year,
    required this.onDateSelected,
    this.selectedDate,
  });

  @override
  _CalendarSliderWidgetState createState() => _CalendarSliderWidgetState();
}

class _CalendarSliderWidgetState extends State<CalendarSliderWidget> {
  DateTime? selectedDate;
  late ScrollController _scrollController;
  final double itemWidth = 80.0; // Width of each date item including separator
  final double separatorWidth = 10.0; // Width of separator

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    _scrollController = ScrollController();

    // Scroll to selected date after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (selectedDate != null) {
      // Calculate the scroll position based on the day
      final double scrollPosition = (selectedDate!.day - 1) * itemWidth;

      // Get the ListView width
      final double listViewWidth = MediaQuery.of(context).size.width;

      // Center the selected date
      final double centeredPosition = scrollPosition - (listViewWidth / 2) + (itemWidth / 2);

      // Ensure we don't scroll beyond bounds
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double scrollTo = centeredPosition.clamp(0.0, maxScroll);

      // Animate to the position
      _scrollController.animateTo(
        scrollTo,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didUpdateWidget(CalendarSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      selectedDate = widget.selectedDate;
      _scrollToSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = getDaysInMonth(widget.month, widget.year);
    List<DateTime> dates = List.generate(daysInMonth, (index) => DateTime(widget.year, widget.month, index + 1));

    return Container(
      height: MediaQuery.of(context).size.height * 0.09,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          DateTime date = dates[index];
          String dayName = DateFormat('EEE').format(date).toUpperCase();
          bool isSelected = selectedDate?.day == date.day && selectedDate?.month == date.month && selectedDate?.year == date.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              widget.onDateSelected(date);
              _scrollToSelectedDate();
            },
            child: Container(
              width: MediaQuery.of(context).size.height * 0.08,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colorz.white,
                border: Border.all(color: isSelected ? Colorz.primaryColor : Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(13.0),
                boxShadow: isSelected ? [BoxShadow(color: Colorz.primaryColor.withOpacity(0.1), blurRadius: 4, spreadRadius: 2)] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.grey.shade400, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.agdasima(
                      fontSize: 17,
                      color: isSelected ? Colors.black : Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 10.0);
        },
      ),
    );
  }

  int getDaysInMonth(int month, int year) {
    final Map<int, int> monthDays = {1: 31, 2: isLeapYear(year) ? 29 : 28, 3: 31, 4: 30, 5: 31, 6: 30, 7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31};
    return monthDays[month] ?? 30;
  }

  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 == 0 && year % 400 != 0) return false;
    return true;
  }
}
