import 'package:equatable/equatable.dart';

class DayTemplate extends Equatable {
  final bool isAvailable;
  final String? startTime;
  final String? endTime;

  const DayTemplate({
    required this.isAvailable,
    this.startTime,
    this.endTime,
  });

  factory DayTemplate.fromMap(Map<String, dynamic> map) {
    return DayTemplate(
      isAvailable: map['isAvailable'] as bool? ?? false,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'isAvailable': isAvailable,
        'startTime': startTime,
        'endTime': endTime,
      };

  @override
  List<Object?> get props => [isAvailable, startTime, endTime];
}

class WeeklyTemplateModel extends Equatable {
  final Map<String, DayTemplate> template;

  const WeeklyTemplateModel({required this.template});

  factory WeeklyTemplateModel.fromFirestore(Map<String, dynamic> data) {
    final t = <String, DayTemplate>{};
    final map = data['template'] as Map<String, dynamic>? ?? {};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        t[key] = DayTemplate.fromMap(value);
      }
    });
    return WeeklyTemplateModel(template: t);
  }

  Map<String, dynamic> toFirestore() {
    final t = <String, dynamic>{};
    template.forEach((key, value) {
      t[key] = value.toMap();
    });
    return {'template': t};
  }

  @override
  List<Object?> get props => [template];
}
