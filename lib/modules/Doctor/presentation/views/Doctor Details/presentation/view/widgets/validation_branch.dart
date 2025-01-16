import '../../../../../../data/model/doctor_model.dart';

class TimeSlot {
  final String from;
  final String to;

  TimeSlot(this.from, this.to);

  int get fromMinutes => _convertTimeToMinutes(from);
  int get toMinutes => _convertTimeToMinutes(to);

  static int _convertTimeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool overlaps(TimeSlot other) {
    return fromMinutes < other.toMinutes && toMinutes > other.fromMinutes;
  }
}

class DoctorScheduleValidator {
  static Map<String, List<String>> validateBranchSchedules(List<BranchElement> branches) {
    Map<String, List<String>> conflicts = {};

    // First, organize schedules by day
    Map<String, List<BranchSchedule>> schedulesByDay = {};

    for (var branch in branches) {
      for (var day in branch.availableDays) {
        if (!schedulesByDay.containsKey(day)) {
          schedulesByDay[day] = [];
        }

        schedulesByDay[day]!.add(BranchSchedule(
            branchName: branch.branch?.name ?? 'Unknown Branch', timeSlot: TimeSlot(branch.availableFrom ?? '00:00', branch.availableTo ?? '00:00')));
      }
    }

    // Check for conflicts in each day
    for (var day in schedulesByDay.keys) {
      var daySchedules = schedulesByDay[day]!;

      for (var i = 0; i < daySchedules.length; i++) {
        for (var j = i + 1; j < daySchedules.length; j++) {
          if (daySchedules[i].timeSlot.overlaps(daySchedules[j].timeSlot)) {
            if (!conflicts.containsKey(day)) {
              conflicts[day] = [];
            }

            conflicts[day]!.add('Conflict on $day between ${daySchedules[i].branchName} '
                '(${daySchedules[i].timeSlot.from}-${daySchedules[i].timeSlot.to}) and '
                '${daySchedules[j].branchName} '
                '(${daySchedules[j].timeSlot.from}-${daySchedules[j].timeSlot.to})');
          }
        }
      }
    }

    return conflicts;
  }
}

class BranchSchedule {
  final String branchName;
  final TimeSlot timeSlot;

  BranchSchedule({
    required this.branchName,
    required this.timeSlot,
  });
}

// Extension to add validation to Doctor class
extension DoctorValidation on Doctor {
  Map<String, List<String>> validateScheduleConflicts() {
    if (branches == null || branches!.isEmpty) {
      return {};
    }

    return DoctorScheduleValidator.validateBranchSchedules(branches!);
  }
}
