
class AnalysisModel {
  AnalysisModel({
    required this.patientId,
    required this.patientName,
    required this.generatedAt,
    required this.totalExaminations,
    required this.trends,
  });

  final String? patientId;
  final String? patientName;
  final DateTime? generatedAt;
  final num? totalExaminations;
  final Trends? trends;

  factory AnalysisModel.fromJson(Map<String, dynamic> json){
    return AnalysisModel(
      patientId: json["patientId"],
      patientName: json["patientName"],
      generatedAt: DateTime.tryParse(json["generatedAt"] ?? ""),
      totalExaminations: json["totalExaminations"],
      trends: json["trends"] == null ? null : Trends.fromJson(json["trends"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "patientId": patientId,
    "patientName": patientName,
    "generatedAt": generatedAt?.toIso8601String(),
    "totalExaminations": totalExaminations,
    "trends": trends?.toJson(),
  };

}

class Trends {
  Trends({
    required this.autoRefraction,
    required this.refinedRefraction,
    required this.nearVision,
    required this.iop,
    required this.visualAcuity,
  });

  final Refraction? autoRefraction;
  final Refraction? refinedRefraction;
  final NearVision? nearVision;
  final Iop? iop;
  final VisualAcuity? visualAcuity;

  factory Trends.fromJson(Map<String, dynamic> json){
    return Trends(
      autoRefraction: json["autoRefraction"] == null ? null : Refraction.fromJson(json["autoRefraction"]),
      refinedRefraction: json["refinedRefraction"] == null ? null : Refraction.fromJson(json["refinedRefraction"]),
      nearVision: json["nearVision"] == null ? null : NearVision.fromJson(json["nearVision"]),
      iop: json["iop"] == null ? null : Iop.fromJson(json["iop"]),
      visualAcuity: json["visualAcuity"] == null ? null : VisualAcuity.fromJson(json["visualAcuity"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "autoRefraction": autoRefraction?.toJson(),
    "refinedRefraction": refinedRefraction?.toJson(),
    "nearVision": nearVision?.toJson(),
    "iop": iop?.toJson(),
    "visualAcuity": visualAcuity?.toJson(),
  };

}

class Refraction {
  Refraction({
    required this.spherical,
    required this.cylindrical,
    required this.axis,
  });

  final Axis? spherical;
  final Axis? cylindrical;
  final Axis? axis;

  factory Refraction.fromJson(Map<String, dynamic> json){
    return Refraction(
      spherical: json["spherical"] == null ? null : Axis.fromJson(json["spherical"]),
      cylindrical: json["cylindrical"] == null ? null : Axis.fromJson(json["cylindrical"]),
      axis: json["axis"] == null ? null : Axis.fromJson(json["axis"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "spherical": spherical?.toJson(),
    "cylindrical": cylindrical?.toJson(),
    "axis": axis?.toJson(),
  };

}

class Axis {
  Axis({
    required this.left,
    required this.right,
  });

  final List<Left> left;
  final List<Left> right;

  factory Axis.fromJson(Map<String, dynamic> json){
    return Axis(
      left: json["left"] == null ? [] : List<Left>.from(json["left"]!.map((x) => Left.fromJson(x))),
      right: json["right"] == null ? [] : List<Left>.from(json["right"]!.map((x) => Left.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "left": left.map((x) => x?.toJson()).toList(),
    "right": right.map((x) => x?.toJson()).toList(),
  };

}

class Left {
  Left({
    required this.value,
    required this.date,
    required this.examinationId,
  });

  final num? value;
  final DateTime? date;
  final String? examinationId;

  factory Left.fromJson(Map<String, dynamic> json){
    return Left(
      value: _parseValue(json["value"]),
      date: DateTime.tryParse(json["date"] ?? ""),
      examinationId: json["examinationId"],
    );
  }

  static num? _parseValue(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) {
      final n = double.tryParse(v);
      if (n != null) return n;
      // Handle VA specific strings based on clinical mapping
      switch (v.toUpperCase()) {
        case 'NLP':
        case 'NPL': return 0.000;
        case 'PL': return 0.001;
        case 'HM': return 0.005;
        case 'CF 1M': return 0.010;
        case 'CF 2M': return 0.020;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    "value": value,
    "date": date?.toIso8601String(),
    "examinationId": examinationId,
  };

}

class Iop {
  Iop({
    required this.primary,
    required this.secondary,
  });

  final Axis? primary;
  final Axis? secondary;

  factory Iop.fromJson(Map<String, dynamic> json){
    return Iop(
      primary: json["primary"] == null ? null : Axis.fromJson(json["primary"]),
      secondary: json["secondary"] == null ? null : Axis.fromJson(json["secondary"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "primary": primary?.toJson(),
    "secondary": secondary?.toJson(),
  };

}

class NearVision {
  NearVision({
    required this.addition,
  });

  final Axis? addition;

  factory NearVision.fromJson(Map<String, dynamic> json){
    return NearVision(
      addition: json["addition"] == null ? null : Axis.fromJson(json["addition"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "addition": addition?.toJson(),
  };

}

class VisualAcuity {
  VisualAcuity({
    required this.ucva,
    required this.bcva,
  });

  final Axis? ucva;
  final Axis? bcva;

  factory VisualAcuity.fromJson(Map<String, dynamic> json){
    return VisualAcuity(
      ucva: json["ucva"] == null ? null : Axis.fromJson(json["ucva"]),
      bcva: json["bcva"] == null ? null : Axis.fromJson(json["bcva"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "ucva": ucva?.toJson(),
    "bcva": bcva?.toJson(),
  };

}
