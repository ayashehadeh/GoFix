import '../../domain/entities/earning_entity.dart';

class EarningModel extends Earning {
  const EarningModel({
    required String period,
    required String label,
    required String dateRange,
    required double grossAmount,
    required int jobCount,
    double adminFeeRate = 0.15,
  }) : super(
          period: period,
          label: label,
          dateRange: dateRange,
          grossAmount: grossAmount,
          jobCount: jobCount,
          adminFeeRate: adminFeeRate,
        );

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      period: json['period'] as String? ?? '',
      label: json['label'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
      grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0.0,
      jobCount: json['jobCount'] as int? ?? 0,
      adminFeeRate: (json['adminFeeRate'] as num?)?.toDouble() ?? 0.15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'label': label,
      'dateRange': dateRange,
      'grossAmount': grossAmount,
      'jobCount': jobCount,
      'adminFeeRate': adminFeeRate,
    };
  }

  Earning toEntity() {
    return Earning(
      period: period,
      label: label,
      dateRange: dateRange,
      grossAmount: grossAmount,
      jobCount: jobCount,
      adminFeeRate: adminFeeRate,
    );
  }
}
