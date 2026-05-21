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
      period: json['period'] ?? '',
      label: json['label'] ?? '',
      dateRange: json['date_range'] ?? json['dateRange'] ?? '',
      grossAmount: (json['gross_amount'] ?? json['grossAmount'] ?? 0).toDouble(),
      jobCount: json['job_count'] ?? json['jobCount'] ?? 0,
      adminFeeRate: (json['admin_fee_rate'] ?? json['adminFeeRate'] ?? 0.15).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'label': label,
      'date_range': dateRange,
      'gross_amount': grossAmount,
      'job_count': jobCount,
      'admin_fee_rate': adminFeeRate,
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
