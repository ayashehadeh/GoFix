import 'package:equatable/equatable.dart';

class Earning extends Equatable {
  final String period;
  final String label;
  final String dateRange;
  final double grossAmount;
  final int jobCount;
  final double adminFeeRate;

  const Earning({
    required this.period,
    required this.label,
    required this.dateRange,
    required this.grossAmount,
    required this.jobCount,
    this.adminFeeRate = 0.15,
  });

  double get adminFee => grossAmount * adminFeeRate;
  double get netAmount => grossAmount - adminFee;
  String get jobsText => jobCount == 1 ? 'job' : 'jobs';
  int get adminFeePercentage => (adminFeeRate * 100).toInt();

  @override
  List<Object?> get props => [period, label, dateRange, grossAmount, jobCount, adminFeeRate];
}
