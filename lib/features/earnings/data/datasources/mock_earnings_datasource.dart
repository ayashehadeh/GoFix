import '../models/earning_model.dart';
import 'earnings_remote_datasource.dart';

class MockEarningsDataSource implements EarningsRemoteDataSource {
  @override
  Future<Map<String, EarningModel>> getEarnings() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'daily': EarningModel(
        period: 'daily',
        label: 'Today',
        dateRange: 'Thu, May 21',
        grossAmount: 180.0,
        jobCount: 3,
        adminFeeRate: 0.15,
      ),
      'weekly': EarningModel(
        period: 'weekly',
        label: 'This Week',
        dateRange: 'May 18 – May 21',
        grossAmount: 1240.0,
        jobCount: 18,
        adminFeeRate: 0.15,
      ),
      'monthly': EarningModel(
        period: 'monthly',
        label: 'This Month',
        dateRange: 'May 2026',
        grossAmount: 4860.0,
        jobCount: 64,
        adminFeeRate: 0.15,
      ),
    };
  }
}
