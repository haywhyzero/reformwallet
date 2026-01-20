import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final bool isExpense;
  final Function(bool) onToggle;

  const CustomToggle({
    super.key,
    required this.isExpense,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: isExpense ? 0 : MediaQuery.of(context).size.width / 2 - 32,
            right: isExpense ? MediaQuery.of(context).size.width / 2 - 32 : 0,
            top: 4,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                color: isExpense ? Colors.red[400] : Colors.green[400],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(true),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: isExpense ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(false),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: !isExpense ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}