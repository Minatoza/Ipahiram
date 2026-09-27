import 'package:flutter/material.dart';

import '../data/loan_repository.dart';
import '../models/loan.dart';
import '../theme.dart';

/// New Loan screen (proposal, Feature 1 — "Log an Item").
/// Lets the user type in what they're lending, who to, and when it's due,
/// then saves it through the repository (so it's persisted immediately).
class NewLoanScreen extends StatefulWidget {
  final LoanRepository repository;

  const NewLoanScreen({super.key, required this.repository});

  @override
  State<NewLoanScreen> createState() => _NewLoanScreenState();
}

class _NewLoanScreenState extends State<NewLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _borrowerController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  @override
  void dispose() {
    _itemController.dispose();
    _borrowerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                  surface: AppColors.surface,
                  onSurface: AppColors.onSurface,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final loan = Loan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      itemName: _itemController.text.trim(),
      borrower: _borrowerController.text.trim(),
      dateLent: DateTime.now(),
      dueDate: _dueDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    await widget.repository.addLoan(loan);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.edge),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('New Loan', style: textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FieldLabel('What are you lending?'),
                  TextFormField(
                    controller: _itemController,
                    style: textTheme.bodyMedium,
                    decoration: _inputDecoration('e.g. Drill, Phone Charger'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter an item name' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FieldLabel('Who are you lending it to?'),
                  TextFormField(
                    controller: _borrowerController,
                    style: textTheme.bodyMedium,
                    decoration: _inputDecoration('e.g. Marco'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FieldLabel('Due date'),
                  InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: _inputDecoration(null),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_dueDate), style: textTheme.bodyMedium),
                          const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FieldLabel('Note (optional)'),
                  TextFormField(
                    controller: _noteController,
                    style: textTheme.bodyMedium,
                    decoration: _inputDecoration('e.g. The white USB-C one'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.edge),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : const Text('Save Loan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
