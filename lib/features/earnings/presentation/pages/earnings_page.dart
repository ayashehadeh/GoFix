import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/earnings_bloc.dart';
import '../../domain/entities/earning_entity.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoading) {
            return _buildLoadingView();
          } else if (state is EarningsError) {
            return _buildErrorView(context, state.message);
          } else if (state is EarningsLoaded) {
            return _buildLoadedView(context, state);
          }
          context.read<EarningsBloc>().add(LoadEarningsEvent());
          return _buildLoadingView();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        _buildHeader(),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B1D3A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFF37021)),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load earnings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<EarningsBloc>().add(LoadEarningsEvent()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1D3A),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedView(BuildContext context, EarningsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EarningsBloc>().add(RefreshEarningsEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF0B1D3A),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: _buildPeriodTabs(context, state.selectedPeriod),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      children: [
                        _buildEarningsCard(state.currentEarning),
                        const SizedBox(height: 14),
                        _buildAdminNotice(state.currentEarning.adminFeeRate),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1D3A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
              ),
              const Text(
                'My Earnings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs(BuildContext context, String selectedPeriod) {
    final tabs = [
      {'id': 'daily', 'label': 'Daily'},
      {'id': 'weekly', 'label': 'Weekly'},
      {'id': 'monthly', 'label': 'Monthly'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((tab) {
          final isActive = selectedPeriod == tab['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<EarningsBloc>().add(ChangePeriodEvent(tab['id']!)),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActive
                      ? [BoxShadow(color: const Color(0xFF0B1D3A).withOpacity(0.10), blurRadius: 3, offset: const Offset(0, 1))]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  tab['label']!,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? const Color(0xFF0B1D3A) : const Color(0xFF6B7A90),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsCard(Earning earning) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1D3A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net earnings · ${earning.label}',
            style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildMoneyDisplay(earning.netAmount, size: 40, weight: FontWeight.w800, ccySize: 16),
          const SizedBox(height: 4),
          Text(
            'from ${earning.jobCount} ${earning.jobsText} · ${earning.dateRange}',
            style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.55)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 18),
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.10))),
            ),
            child: Column(
              children: [
                _buildRow('Gross collected', earning.grossAmount),
                const SizedBox(height: 10),
                _buildRow('Admin fee (${earning.adminFeePercentage}%)', earning.adminFee, negative: true, muted: true),
                const SizedBox(height: 10),
                _buildRow('Your payout', earning.netAmount, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value, {bool negative = false, bool muted = false, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: muted ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.85),
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Row(
          children: [
            if (negative) Text('−', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
            _buildMoneyDisplay(value, size: 13, weight: bold ? FontWeight.w800 : FontWeight.w600),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyDisplay(double amount, {double size = 13, FontWeight weight = FontWeight.w700, double? ccySize}) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JOD',
          style: TextStyle(
            fontSize: ccySize ?? size * 0.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white.withOpacity(ccySize != null ? 0.55 : 0.5),
            height: 1.6,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminNotice(double feeRate) {
    final percentage = (feeRate * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E6),
        border: Border.all(color: const Color(0xFFFBD8BD)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF37021), width: 1.8),
            ),
            child: const Icon(Icons.info, size: 12, color: Color(0xFFF37021)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF7A3A0E), height: 1.45),
                children: [
                  const TextSpan(text: 'GoFIX deducts '),
                  TextSpan(text: '$percentage%', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: ' from each completed job as a platform fee.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
