import 'package:flutter_riverpod/flutter_riverpod.dart';

final taxServiceProvider = Provider((ref) => TaxService());

class TaxDetails {
  final double grossIncome;
  final double taxableIncome;
  final double totalTax;
  final double netIncome;
  final List<TaxBreakdown> breakdown;

  TaxDetails({
    required this.grossIncome,
    required this.taxableIncome,
    required this.totalTax,
    required this.netIncome,
    required this.breakdown,
  });

  factory TaxDetails.empty() {
    return TaxDetails(
      grossIncome: 0.0,
      taxableIncome: 0.0,
      totalTax: 0.0,
      netIncome: 0.0,
      breakdown: [],
    );
  }
}

class TaxBreakdown {
  final String bracket;
  final String rate;
  final double amount;

  TaxBreakdown({
    required this.bracket,
    required this.rate,
    required this.amount,
  });
}

class TaxService {
  /// Calculates tax based on the Nigeria Tax Act 2025 (Effective Jan 2026)
  /// [annualGrossIncome]: Total yearly earnings.
  /// [pension]: Optional annual pension contribution (usually 8% of basic/housing/transport).
  /// [nhf]: Optional National Housing Fund (usually 2.5% of basic).
  /// [nhis]: Optional National Health Insurance Scheme.
  /// [annualRent]: Optional annual rent paid to calculate the new Rent Relief.
  TaxDetails calculateTax({
    required double annualGrossIncome,
    double pension = 0.0,
    double nhf = 0.0,
    double nhis = 0.0,
    double annualRent = 0.0,
  }) {
    if (annualGrossIncome <= 0) return TaxDetails.empty();

    // 1. Calculate Rent Relief: 20% of rent, capped at ₦500,000
    final rentRelief = (annualRent * 0.20) > 500000 ? 500000.0 : (annualRent * 0.20);

    // 2. Calculate Taxable Income (Gross minus statutory deductions and rent relief)
    // Note: The first ₦800k is handled by the 0% bracket, not as a deduction from gross.
    final totalDeductions = pension + nhf + nhis + rentRelief;
    double taxableIncome = annualGrossIncome - totalDeductions;
    if (taxableIncome < 0) taxableIncome = 0;

    double totalTax = 0;
    List<TaxBreakdown> breakdown = [];
    double remaining = taxableIncome;

    // 2026 Tax Brackets (Annual)
    final List<Map<String, dynamic>> brackets = [
      {'limit': 800000.0, 'rate': 0.00, 'label': 'First ₦800,000 (Tax Free)'},
      {'limit': 2200000.0, 'rate': 0.15, 'label': 'Next ₦2,200,000'},
      {'limit': 9000000.0, 'rate': 0.18, 'label': 'Next ₦9,000,000'},
      {'limit': 13000000.0, 'rate': 0.21, 'label': 'Next ₦13,000,000'},
      {'limit': 25000000.0, 'rate': 0.23, 'label': 'Next ₦25,000,000'},
      {'limit': double.infinity, 'rate': 0.25, 'label': 'Above ₦50,000,000'},
    ];

    for (var b in brackets) {
      if (remaining <= 0) break;

      final double limit = b['limit'];
      final double rate = b['rate'];
      final String label = b['label'];

      double amountInBracket = (remaining > limit) ? limit : remaining;
      double taxForBracket = amountInBracket * rate;

      totalTax += taxForBracket;
      breakdown.add(TaxBreakdown(
        bracket: label,
        rate: '${(rate * 100).toInt()}%',
        amount: taxForBracket,
      ));

      remaining -= amountInBracket;
    }

    return TaxDetails(
      grossIncome: annualGrossIncome,
      taxableIncome: taxableIncome,
      totalTax: totalTax,
      netIncome: annualGrossIncome - totalTax - (pension + nhf + nhis),
      breakdown: breakdown,
    );
  }
}