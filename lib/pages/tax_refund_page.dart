import 'package:expensetracker/model/ctrl_provider.dart';
import 'package:expensetracker/model/tax_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaxRefundPage extends ConsumerWidget {
  const TaxRefundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final incomes = ref.watch(incomeProvider);
    final taxService = ref.read(taxServiceProvider);
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

    final currentYear = DateTime.now().year;

    // Calculate Total Income
    final totalGrossIncome = incomes
        .where((t) => DateTime.parse(t['date']).year == currentYear && t['category'] != 'Gift')
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));

    // Calculate Deductions from Expenses
    // Mapping 'Healthcare' to NHIS and 'Bills' to Rent for demonstration
    final healthExpenses = expenses
        .where((t) => DateTime.parse(t['date']).year == currentYear && t['category'] == 'Healthcare')
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));

    final rentExpenses = expenses
        .where((t) => DateTime.parse(t['date']).year == currentYear && t['category'] == 'Bills')
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));

    // 1. Standard Tax (Assumed deducted at source based on Gross)
    final standardTaxDetails = taxService.calculateTax(annualGrossIncome: totalGrossIncome);

    // 2. Actual Tax Liability (After applying reliefs from expenses)
    final actualTaxDetails = taxService.calculateTax(
      annualGrossIncome: totalGrossIncome,
      nhis: healthExpenses,
      annualRent: rentExpenses,
    );

    final potentialRefund = standardTaxDetails.totalTax - actualTaxDetails.totalTax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Details & Refund'),
      ),
      body: totalGrossIncome == 0
          ? const Center(
              child: Text('No income recorded for this year yet.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                              Text(
                                  'Automatic calculation based on 2026 Tax Reform.',
                                  style: TextStyle(fontSize: 14, color: Theme.of(context).copyWith().colorScheme.onPrimaryFixed),
                                ),
                              const SizedBox(height: 4),
                               Text('We check your "Healthcare" and "Bills" expenses to apply NHIS and Rent reliefs.', 
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Theme.of(context).copyWith().colorScheme.onPrimaryFixed),)
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(
                    'Total Annual Income: ',
                    formatter.format(totalGrossIncome),
                    Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryCard(
                    'Standard Tax (PAYE): ',
                    formatter.format(standardTaxDetails.totalTax),
                    Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryCard(
                    'Actual Tax (After Reliefs): ',
                    formatter.format(actualTaxDetails.totalTax),
                    Colors.red,
                  ),
                  
                  const SizedBox(height: 20),
                  // Refund Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: potentialRefund > 0 ? Colors.green[50] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: potentialRefund > 0 ? Colors.green : Colors.grey[300]!,
                        width: 2
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Potential Refund',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: potentialRefund > 0 ? Colors.green[800] : Colors.grey[600],
                              ),
                            ),
                            if (potentialRefund > 0)
                              Text(
                                'You may have overpaid!',
                                style: TextStyle(fontSize: 12, color: Colors.green[700]),
                              ),
                          ],
                        ),
                        Text(
                          formatter.format(potentialRefund),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: potentialRefund > 0 ? Colors.green[700] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Tax Breakdown (Actual)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (actualTaxDetails.breakdown.isEmpty)
                    const Text('No tax to pay on this income.')
                  else
                    ...actualTaxDetails.breakdown.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).copyWith().colorScheme.onSecondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.bracket,
                                    style:  TextStyle(color: Theme.of(context).copyWith().colorScheme.onPrimary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'at ${item.rate}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                formatter.format(item.amount),
                                style:  TextStyle(
                                  color: Theme.of(context).copyWith().colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
