class DashboardModel {
  DashboardModel({
    required this.scope,
    required this.generatedAt,
    required this.operational,
    required this.analytics,
    required this.comparisons,
  });

  final String? scope;
  final DateTime? generatedAt;
  final Operational? operational;
  final Analytics? analytics;
  final Comparisons? comparisons;

  factory DashboardModel.fromJson(Map<String, dynamic> json){
    return DashboardModel(
      scope: json["scope"],
      generatedAt: DateTime.tryParse(json["generatedAt"] ?? ""),
      operational: json["operational"] == null ? null : Operational.fromJson(json["operational"]),
      analytics: json["analytics"] == null ? null : Analytics.fromJson(json["analytics"]),
      comparisons: json["comparisons"] == null ? null : Comparisons.fromJson(json["comparisons"]),
    );
  }

}

class Analytics {
  Analytics({
    required this.period,
    required this.examinationsTrend,
    required this.completionRate,
    required this.cancellationRate,
    required this.examinationTypeDistribution,
    required this.appointmentStatusDistribution,
  });

  final Period? period;
  final List<ExaminationsTrend> examinationsTrend;
  final TionRate? completionRate;
  final TionRate? cancellationRate;
  final List<ExaminationTypeDistribution> examinationTypeDistribution;
  final List<AppointmentStatusDistribution> appointmentStatusDistribution;

  factory Analytics.fromJson(Map<String, dynamic> json){
    return Analytics(
      period: json["period"] == null ? null : Period.fromJson(json["period"]),
      examinationsTrend: json["examinationsTrend"] == null ? [] : List<ExaminationsTrend>.from(json["examinationsTrend"]!.map((x) => ExaminationsTrend.fromJson(x))),
      completionRate: json["completionRate"] == null ? null : TionRate.fromJson(json["completionRate"]),
      cancellationRate: json["cancellationRate"] == null ? null : TionRate.fromJson(json["cancellationRate"]),
      examinationTypeDistribution: json["examinationTypeDistribution"] == null ? [] : List<ExaminationTypeDistribution>.from(json["examinationTypeDistribution"]!.map((x) => ExaminationTypeDistribution.fromJson(x))),
      appointmentStatusDistribution: json["appointmentStatusDistribution"] == null ? [] : List<AppointmentStatusDistribution>.from(json["appointmentStatusDistribution"]!.map((x) => AppointmentStatusDistribution.fromJson(x))),
    );
  }

}

class AppointmentStatusDistribution {
  AppointmentStatusDistribution({
    required this.status,
    required this.count,
    required this.percentage,
  });

  final String? status;
  final num? count;
  final num? percentage;

  factory AppointmentStatusDistribution.fromJson(Map<String, dynamic> json){
    return AppointmentStatusDistribution(
      status: json["status"],
      count: json["count"],
      percentage: json["percentage"],
    );
  }

}

class TionRate {
  TionRate({
    required this.value,
    required this.trend,
    required this.previousValue,
  });

  final num? value;
  final String? trend;
  final num? previousValue;

  factory TionRate.fromJson(Map<String, dynamic> json){
    return TionRate(
      value: json["value"],
      trend: json["trend"],
      previousValue: json["previousValue"],
    );
  }

}

class ExaminationTypeDistribution {
  ExaminationTypeDistribution({
    required this.typeId,
    required this.typeName,
    required this.count,
    required this.percentage,
  });

  final String? typeId;
  final String? typeName;
  final num? count;
  final num? percentage;

  factory ExaminationTypeDistribution.fromJson(Map<String, dynamic> json){
    return ExaminationTypeDistribution(
      typeId: json["typeId"],
      typeName: json["typeName"],
      count: json["count"],
      percentage: json["percentage"],
    );
  }

}

class ExaminationsTrend {
  ExaminationsTrend({
    required this.count,
    required this.date,
  });

  final num? count;
  final DateTime? date;

  factory ExaminationsTrend.fromJson(Map<String, dynamic> json){
    return ExaminationsTrend(
      count: json["count"],
      date: DateTime.tryParse(json["date"] ?? ""),
    );
  }

}

class Period {
  Period({
    required this.startDate,
    required this.endDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  factory Period.fromJson(Map<String, dynamic> json){
    return Period(
      startDate: DateTime.tryParse(json["startDate"] ?? ""),
      endDate: DateTime.tryParse(json["endDate"] ?? ""),
    );
  }

}

class Comparisons {
  Comparisons({
    required this.branches,
    required this.clinics,
  });

  final List<Branch> branches;
  final List<Clinic> clinics;

  factory Comparisons.fromJson(Map<String, dynamic> json){
    return Comparisons(
      branches: json["branches"] == null ? [] : List<Branch>.from(json["branches"]!.map((x) => Branch.fromJson(x))),
      clinics: json["clinics"] == null ? [] : List<Clinic>.from(json["clinics"]!.map((x) => Clinic.fromJson(x))),
    );
  }

}

class Branch {
  Branch({
    required this.branchId,
    required this.branchName,
    required this.examinationCount,
  });

  final String? branchId;
  final String? branchName;
  final num? examinationCount;

  factory Branch.fromJson(Map<String, dynamic> json){
    return Branch(
      branchId: json["branchId"],
      branchName: json["branchName"],
      examinationCount: json["examinationCount"],
    );
  }

}

class Clinic {
  Clinic({
    required this.clinicId,
    required this.clinicName,
    required this.examinationCount,
  });

  final String? clinicId;
  final String? clinicName;
  final num? examinationCount;

  factory Clinic.fromJson(Map<String, dynamic> json){
    return Clinic(
      clinicId: json["clinicId"],
      clinicName: json["clinicName"],
      examinationCount: json["examinationCount"],
    );
  }

}

class Operational {
  Operational({
    required this.today,
    required this.tomorrow,
    required this.pendingFinalizations,
  });

  final Today? today;
  final Tomorrow? tomorrow;
  final num? pendingFinalizations;

  factory Operational.fromJson(Map<String, dynamic> json){
    return Operational(
      today: json["today"] == null ? null : Today.fromJson(json["today"]),
      tomorrow: json["tomorrow"] == null ? null : Tomorrow.fromJson(json["tomorrow"]),
      pendingFinalizations: json["pendingFinalizations"],
    );
  }

}

class Today {
  Today({
    required this.total,
    required this.byStatus,
  });

  final num? total;
  final ByStatus? byStatus;

  factory Today.fromJson(Map<String, dynamic> json){
    return Today(
      total: json["total"],
      byStatus: json["byStatus"] == null ? null : ByStatus.fromJson(json["byStatus"]),
    );
  }

}

class ByStatus {
  ByStatus({
    required this.scheduled,
    required this.waiting,
    required this.examining,
    required this.examined,
    required this.completed,
    required this.cancelled,
    required this.delayed,
    required this.late,
    required this.saved,
  });

  final num? scheduled;
  final num? waiting;
  final num? examining;
  final num? examined;
  final num? completed;
  final num? cancelled;
  final num? delayed;
  final num? late;
  final num? saved;

  factory ByStatus.fromJson(Map<String, dynamic> json){
    return ByStatus(
      scheduled: json["scheduled"],
      waiting: json["waiting"],
      examining: json["examining"],
      examined: json["examined"],
      completed: json["completed"],
      cancelled: json["cancelled"],
      delayed: json["delayed"],
      late: json["late"],
      saved: json["saved"],
    );
  }

}

class Tomorrow {
  Tomorrow({
    required this.total,
  });

  final num? total;

  factory Tomorrow.fromJson(Map<String, dynamic> json){
    return Tomorrow(
      total: json["total"],
    );
  }

}
