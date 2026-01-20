import 'package:expensetracker/model/tax_service.dart';
import 'package:expensetracker/widget/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaxCalculatorPage extends StatefulWidget {
  const TaxCalculatorPage({super.key});

  @override
  State<TaxCalculatorPage> createState() => _TaxCalculatorPageState();
}

class _TaxCalculatorPageState extends State<TaxCalculatorPage> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _deductionController = TextEditingController();
  final TextEditingController _nhisController = TextEditingController();
  final taxService = TaxService();
  // final taxdetails = TaxDetails();
  double _taxableIcome = 0;
  double _calculatedTax = 0;
  double _netIncome = 0;
  List<TaxBreakdown> _breakdown = [];
  bool _isPension = false;
  bool _isNHF = false;
  bool _isNHIS = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _deductionController.dispose();
    _nhisController.dispose();
    super.dispose();
  }

  // Nigeria 2026 Tax Reform Brackets (Personal Income Tax)
  void _calculateTax() {
    final income = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;
    final rentRelief = double.tryParse(_deductionController.text.replaceAll(',', '')) ?? 0;
    final nhisRelief = double.tryParse(_nhisController.text.replaceAll(',', '')) ?? 0;
    double pension = 0.0;
    double nhfRelief = 0.0;
    
    if (_isPension) setState(() => pension = income * 0.08,);
    if (_isNHF) setState(() => nhfRelief = income * 0.025,);

    final taxDetails = taxService.calculateTax(
      annualGrossIncome: income,
      annualRent: rentRelief,
      pension: pension,
      nhf: nhfRelief,
      nhis: nhisRelief
    );

    setState(() {
      _taxableIcome = taxDetails.taxableIncome;
      _calculatedTax = taxDetails.totalTax;
      _netIncome = taxDetails.netIncome;
      _breakdown = taxDetails.breakdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'en_US');

    return SingleChildScrollView(
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
                  const Expanded(
                    child: Text(
                      'Based on Nigeria 2026 Tax Reform',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  'Annual Gross Income',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5,),
                IconButton(
                  onPressed: showOverlayInfo,
                  icon: const Icon(Icons.info_outline, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                hintText: '0',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _deductionController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Annual Rent Deduction (Optional)',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CheckboxMenuButton(value: _isPension, onChanged: (bool? value) {
              setState(() {
                _isPension = value!;
              });
            },
            child: const Text('Include pension contribution')
            ),
            CheckboxMenuButton(value: _isNHF, onChanged: (bool? value) {
              setState(() {
                _isNHF = value!;
              });
            },
            child: const Text('Include NHF contribution')
            ),
            CheckboxMenuButton(value: _isNHIS, onChanged: (bool? value) {
              setState(() {
                _isNHIS = value!;
              });
            },
            child: const Text('Include NHIS contribution')
            ),
            if (_isNHIS)
              TextField(
              controller: _nhisController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'National Health Insurance Scheme amount',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _calculateTax());
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child:  Text(
                  'Calculate Tax',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).copyWith().colorScheme.primaryContainer
                  ),
                ),
              ),
            ),
            if (_calculatedTax > 0) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Taxable Income:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₦${formatter.format(_taxableIcome)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white54, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Tax:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₦${formatter.format(_calculatedTax)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white54, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Net Income:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₦${formatter.format(_netIncome)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tax Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ..._breakdown.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).copyWith().colorScheme.onSecondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.bracket,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).copyWith().colorScheme.onPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.rate,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₦${formatter.format(item.amount)}',
                          style:  TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).copyWith().colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
    );
  }


void showOverlayInfo() {
  final overlay = Overlay.of(context);
  final screenWidth = MediaQuery.of(context).size.width;

  late OverlayEntry entry;

  entry = OverlayEntry(builder: (context) => 
    Stack(
      children: [
        GestureDetector(
          onTap: () {
              entry.remove();
              // entry = null;
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Positioned(
        top: 130,
        right: 16,
        width: screenWidth * 0.6,
        child: Material(
          color: Colors.white38,
          child: AnimatedOpacity(opacity: 1.0, duration: Duration(milliseconds: 300), child: Container(
            constraints: BoxConstraints(maxHeight: 300),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(),
                  blurRadius: 8,
                  offset: Offset(0, 4)
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Annual Gross Income is the total income earned by an individual or business in a year, before taxes and deductions.",
                  style: TextStyle(
                    color: Theme.of(context).copyWith().colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
          ),),
        )),]
    ));

    overlay.insert(entry);

  Future.delayed(const Duration(seconds: 5), () {
    entry.remove();
  });
}

}