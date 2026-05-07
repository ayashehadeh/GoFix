/// A single day schedule sent to PUT /api/professionals/profile/working-hours
/// Backend expects: { dayLabel: "Sunday", openTime: "08:00", closeTime: "17:00" }
class WorkingHoursModel {
  final String dayLabel;
  final String openTime;
  final String closeTime;

  const WorkingHoursModel({
    required this.dayLabel,
    required this.openTime,
    required this.closeTime,
  });

  Map<String, dynamic> toJson() => {
        'dayLabel': dayLabel,
        'openTime': openTime,
        'closeTime': closeTime,
      };

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      dayLabel: json['day'] as String? ??
          json['dayLabel'] as String? ??
          '',
      openTime: json['openTime'] as String? ??
          json['open_time'] as String? ??
          '',
      closeTime: json['closeTime'] as String? ??
          json['close_time'] as String? ??
          '',
    );
  }
}
