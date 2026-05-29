import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_bloc.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_event.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_state.dart';

void showPaymentAmountSheet(
  BuildContext context, {
  required String jobId,
  VoidCallback? onSuccess,
}) {
  final dashboardBloc = context.read<ProfessionalDashboardBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => BlocProvider.value(
      value: dashboardBloc,
      child: _PaymentAmountSheet(
        jobId: jobId,
        pageContext: context,
        onSuccess: onSuccess,
      ),
    ),
  );
}

class _PaymentAmountSheet extends StatefulWidget {
  final String jobId;
  final BuildContext pageContext;
  final VoidCallback? onSuccess;

  const _PaymentAmountSheet({
    required this.jobId,
    required this.pageContext,
    this.onSuccess,
  });

  @override
  State<_PaymentAmountSheet> createState() => _PaymentAmountSheetState();
}

class _PaymentAmountSheetState extends State<_PaymentAmountSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: BlocConsumer<ProfessionalDashboardBloc, ProfessionalDashboardState>(
          listener: (ctx, state) {
            if (state is PaymentAmountSubmitted) {
              Navigator.pop(context);
              widget.onSuccess?.call();
              if (widget.pageContext.mounted) {
                showSuccessSnackbar(widget.pageContext, 'Amount submitted. Waiting for customer confirmation.');
              }
            }
          },
          builder: (ctx, state) {
            final isLoading = state is RequestActionLoading || state is PaymentAmountSubmitting;
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Set Agreed Amount',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF062B4D)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the final cash amount agreed with the customer.',
                    style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Amount (JD)',
                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF062B4D)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE87722), width: 2),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final amount = double.parse(_amountController.text.trim());
                              final bloc = context.read<ProfessionalDashboardBloc>();
                              bloc.add(UpdateStatus(widget.jobId, 'Completed'));
                              await Future.delayed(const Duration(milliseconds: 800));
                              if (mounted) bloc.add(SubmitPaymentAmountEvent(widget.jobId, amount));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87722),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Submit Amount',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
