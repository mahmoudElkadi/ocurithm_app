import 'package:flutter/material.dart';

import 'appointment_model.dart';

/// Mirrors the backend's 10-value enum
/// (`common/enums/appointment-status.enum.ts`) and its state machine
/// (`ALLOWED_STATUS_TRANSITIONS` in appointments.service.ts).
///
/// Distinct from the `AppointmentUiState` enum in the appointment cubit,
/// which tracks this screen's own loading/error state, not the appointment's
/// lifecycle — the two were previously conflated under the same name.
enum AppointmentLifecycleStatus {
  scheduled,
  delayed,
  late_,
  arrived,
  cancelled,
  examining,
  waiting,
  examined,
  completed,
  saved,

  /// Anything the server sends that isn't one of the ten known values.
  /// Rendering must not crash on this — a future backend status must degrade
  /// gracefully rather than take the app down.
  unknown;

  static const _labels = {
    AppointmentLifecycleStatus.scheduled: 'Scheduled',
    AppointmentLifecycleStatus.delayed: 'Delayed',
    AppointmentLifecycleStatus.late_: 'Late',
    AppointmentLifecycleStatus.arrived: 'Arrived',
    AppointmentLifecycleStatus.cancelled: 'Cancelled',
    AppointmentLifecycleStatus.examining: 'Examining',
    AppointmentLifecycleStatus.waiting: 'Waiting',
    AppointmentLifecycleStatus.examined: 'Examined',
    AppointmentLifecycleStatus.completed: 'Completed',
    AppointmentLifecycleStatus.saved: 'Saved',
  };

  /// Tolerant of unknown values — never throws.
  static AppointmentLifecycleStatus fromString(String? raw) {
    for (final entry in _labels.entries) {
      if (entry.value == raw) return entry.key;
    }
    return AppointmentLifecycleStatus.unknown;
  }

  /// The exact string the backend expects back (`_labels`'s value), or the
  /// original unrecognised string for [unknown] so it round-trips untouched.
  String get wireValue => _labels[this] ?? 'Unknown';

  String get label => _labels[this] ?? 'Unknown';

  /// Matches web's AppointmentStatus.tsx badge variants, mapped to concrete
  /// colors since mobile has no equivalent theme-variant system.
  Color get color {
    switch (this) {
      case AppointmentLifecycleStatus.scheduled:
        return Colors.blueGrey;
      case AppointmentLifecycleStatus.delayed:
        return Colors.deepOrange;
      case AppointmentLifecycleStatus.late_:
        return Colors.orange;
      case AppointmentLifecycleStatus.arrived:
        return Colors.lightBlue;
      case AppointmentLifecycleStatus.cancelled:
        return Colors.red;
      case AppointmentLifecycleStatus.examining:
        return Colors.green;
      case AppointmentLifecycleStatus.waiting:
        return Colors.amber.shade800;
      case AppointmentLifecycleStatus.examined:
        return Colors.teal;
      case AppointmentLifecycleStatus.completed:
        return Colors.green.shade800;
      case AppointmentLifecycleStatus.saved:
        return Colors.indigo;
      case AppointmentLifecycleStatus.unknown:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentLifecycleStatus.scheduled:
        return Icons.event_outlined;
      case AppointmentLifecycleStatus.delayed:
        return Icons.hourglass_bottom;
      case AppointmentLifecycleStatus.late_:
        return Icons.access_time;
      case AppointmentLifecycleStatus.arrived:
        return Icons.login;
      case AppointmentLifecycleStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentLifecycleStatus.examining:
        return Icons.medical_services_outlined;
      case AppointmentLifecycleStatus.waiting:
        return Icons.hourglass_empty;
      case AppointmentLifecycleStatus.examined:
        return Icons.fact_check_outlined;
      case AppointmentLifecycleStatus.completed:
        return Icons.check_circle_outline;
      case AppointmentLifecycleStatus.saved:
        return Icons.save_outlined;
      case AppointmentLifecycleStatus.unknown:
        return Icons.help_outline;
    }
  }

  bool get isPreArrival =>
      this == AppointmentLifecycleStatus.scheduled ||
      this == AppointmentLifecycleStatus.delayed ||
      this == AppointmentLifecycleStatus.late_;

  bool get isClosed =>
      this == AppointmentLifecycleStatus.cancelled ||
      this == AppointmentLifecycleStatus.completed;

  // Mirrors AppointmentCard.tsx's can* booleans exactly, so mobile never
  // offers a transition the backend's state machine would reject with a 400.
  bool get canArrive => isPreArrival;
  bool get canLate =>
      this == AppointmentLifecycleStatus.scheduled ||
      this == AppointmentLifecycleStatus.delayed;
  bool get canDelay => isPreArrival;
  bool get canProceed =>
      this == AppointmentLifecycleStatus.arrived ||
      this == AppointmentLifecycleStatus.waiting ||
      this == AppointmentLifecycleStatus.saved;
  bool get canWait => this == AppointmentLifecycleStatus.examining;
  bool get canExamine =>
      this == AppointmentLifecycleStatus.examining ||
      this == AppointmentLifecycleStatus.saved;
  bool get canCancel => !isClosed;
}

class QueueMeta {
  /// 1-based position within the doctor's active queue (always dense).
  final int position;

  /// true for the doctor's currently-examining patient (green highlight on
  /// web); the next AWAITING patient in queue order gets [isNext] instead.
  final bool isExamining;
  final bool isNext;

  const QueueMeta({
    required this.position,
    this.isExamining = false,
    this.isNext = false,
  });
}

/// Statuses web's appointment-queue.ts treats as "still waiting to be seen or
/// resume" — the first of these in a doctor's queue is highlighted as next.
const _awaitingStatuses = {
  AppointmentLifecycleStatus.scheduled,
  AppointmentLifecycleStatus.delayed,
  AppointmentLifecycleStatus.late_,
  AppointmentLifecycleStatus.arrived,
  AppointmentLifecycleStatus.waiting,
};

/// Mirrors web's computeQueueMeta (appointment-queue.ts): groups the active
/// (non-closed) appointments by doctor, sorted by sequence with a datetime
/// fallback, and assigns a dense 1-based position plus a highlight per doctor.
/// Closed appointments (Completed/Cancelled) are absent from the result.
Map<String, QueueMeta> computeAppointmentQueueMeta(
    List<Appointment> appointments) {
  final byDoctor = <String, List<Appointment>>{};
  for (final a in appointments) {
    final status = AppointmentLifecycleStatus.fromString(a.status);
    if (status.isClosed) continue;
    final doctorId = a.doctor?.id ?? 'unknown';
    byDoctor.putIfAbsent(doctorId, () => []).add(a);
  }

  final result = <String, QueueMeta>{};
  for (final group in byDoctor.values) {
    group.sort((a, b) {
      final num seqA = a.sequence ?? double.infinity;
      final num seqB = b.sequence ?? double.infinity;
      final seqCompare = seqA.compareTo(seqB);
      if (seqCompare != 0) return seqCompare;
      final timeA = a.datetime?.millisecondsSinceEpoch ?? 0;
      final timeB = b.datetime?.millisecondsSinceEpoch ?? 0;
      return timeA.compareTo(timeB);
    });

    var nextAssigned = false;
    for (var i = 0; i < group.length; i++) {
      final status = AppointmentLifecycleStatus.fromString(group[i].status);
      final isExamining = status == AppointmentLifecycleStatus.examining;
      final isNext = !nextAssigned && _awaitingStatuses.contains(status);
      if (isNext) nextAssigned = true;
      if (group[i].id != null) {
        result[group[i].id!] = QueueMeta(
          position: i + 1,
          isExamining: isExamining,
          isNext: isNext,
        );
      }
    }
  }
  return result;
}
